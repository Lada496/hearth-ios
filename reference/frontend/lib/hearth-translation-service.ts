/**
 * HearThTranslationService
 *
 * STT:  Whisper via FastAPI /process     (language detection + transcript)
 * MT:   Aya via FastAPI /translate       (translation only, no lang detection)
 * TTS:  Web SpeechSynthesis (Phase 0)
 */

import type {
  TranslationService,
  RecordingHandle,
  RecordingResult,
  TranslateParams,
  TranslateResult,
  DetectedLanguage,
} from "@/types";

// ─── Region model keys ────────────────────────────────────────────────────────

const LANGUAGE_FLAGS: Record<string, string> = {
  en: "🇬🇧",
  es: "🇪🇸",
  ar: "🇸🇦",
  uk: "🇺🇦",
  fr: "🇫🇷",
  zh: "🇨🇳",
  yue: "🇭🇰", // Cantonese
  pa: "🇮🇳", // Punjabi
  fa: "🇮🇷", // Farsi / Persian
  vi: "🇻🇳", // Vietnamese
  am: "🇪🇹",
  tl: "🇵🇭",
  de: "🇩🇪",
  pt: "🇧🇷",
  ru: "🇷🇺",
  ja: "🇯🇵",
  ko: "🇰🇷",
  hi: "🇮🇳",
  sw: "🇰🇪",
  so: "🇸🇴",
  ti: "🇪🇷",
};

function getFlag(langCode: string): string {
  const base = langCode.split("-")[0].toLowerCase();
  return LANGUAGE_FLAGS[langCode] || LANGUAGE_FLAGS[base] || "🌐";
}

function makeDetectedLanguage(
  code: string,
  confidence: number = 0.9
): DetectedLanguage {
  return {
    code: code.split("-")[0].toLowerCase(),
    flag: getFlag(code),
    confidence,
  };
}

export type RegionKey = "global" | "earth" | "fire" | "water";

export const REGION_LABELS: Record<RegionKey, string> = {
  global: "Auto",
  earth: "Earth",
  fire: "Fire",
  water: "Water",
};

export const REGION_DESCRIPTIONS: Record<RegionKey, string> = {
  global: "All 70 languages",
  earth: "Africa + West Asia",
  fire: "South Asia",
  water: "Asia-Pacific",
};

// ─── Language code → full name (mirrors server.py) ───────────────────────────

const LANG_CODE_TO_NAME: Record<string, string> = {
  en: "English",
  fr: "French",
  ar: "Arabic",
  so: "Somali",
  ti: "Tigrinya",
  om: "Oromo",
  am: "Amharic",
  es: "Spanish",
  pt: "Portuguese",
  de: "German",
  it: "Italian",
  nl: "Dutch",
  ru: "Russian",
  zh: "Chinese",
  ja: "Japanese",
  ko: "Korean",
  hi: "Hindi",
  ur: "Urdu",
  fa: "Persian",
  tr: "Turkish",
  sw: "Swahili",
  ha: "Hausa",
  yo: "Yoruba",
  ig: "Igbo",
  vi: "Vietnamese",
  th: "Thai",
  id: "Indonesian",
  ms: "Malay",
  tl: "Filipino",
  bn: "Bengali",
  ta: "Tamil",
  uk: "Ukrainian",
  pl: "Polish",
  el: "Greek",
  he: "Hebrew",
  fi: "Finnish",
  sv: "Swedish",
};

// ─── Session state (module-level singleton) ───────────────────────────────────

let _residentLanguage: DetectedLanguage | null = null;
let _residentLanguageName: string | null = null;
let _regionKey: RegionKey = "global";

export function getResidentLanguage(): DetectedLanguage | null {
  return _residentLanguage;
}
export function setRegionKey(key: RegionKey): void {
  _regionKey = key;
}
export function getRegionKey(): RegionKey {
  return _regionKey;
}
export function clearSession(): void {
  _residentLanguage = null;
  _residentLanguageName = null;
}

export function setResidentLanguageManual(name: string, code: string, flag: string): void {
  _residentLanguage = {
    code,
    flag,
    confidence: 1,
  };
  _residentLanguageName = name;
}

// ─── localStorage helpers (safe for SSR) ─────────────────────────────────────

function storedToken(): string {
  try {
    return localStorage.getItem("hearth_hf_token") || "";
  } catch {
    return "";
  }
}
function storedServer(): string {
  try {
    return (
      localStorage.getItem("hearth_server") ||
      process.env.NEXT_PUBLIC_BACKEND_URL ||
      "http://localhost:8000"
    );
  } catch {
    return process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000";
  }
}

// ─── Recording state ──────────────────────────────────────────────────────────

interface ActiveRecording {
  mediaRecorder: MediaRecorder;
  audioChunks: Blob[];
}

let activeRecording: ActiveRecording | null = null;
let recordingCounter = 0;

// ─── HearThTranslationService ─────────────────────────────────────────────────

export class HearThTranslationService implements TranslationService {
  private get base(): string {
    return storedServer();
  }

  // ── STT: start ──────────────────────────────────────────────────────────────

  async startRecording(): Promise<RecordingHandle> {
    if (activeRecording) throw new Error("Already recording");

    const id = `rec-${++recordingCounter}`;
    console.log(`[HearTh] startRecording → ${id}`);

    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    console.log(
      `[HearTh] mic acquired:`,
      stream.getAudioTracks().map((t) => t.label)
    );

    const mimeType = MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
      ? "audio/webm;codecs=opus"
      : MediaRecorder.isTypeSupported("audio/webm")
      ? "audio/webm"
      : "audio/mp4";

    console.log(`[HearTh] mimeType: ${mimeType}`);
    const mediaRecorder = new MediaRecorder(stream, { mimeType });
    const audioChunks: Blob[] = [];

    mediaRecorder.ondataavailable = (e) => {
      if (e.data.size > 0) audioChunks.push(e.data);
      console.log(`[HearTh] chunk: ${e.data.size} bytes`);
    };
    mediaRecorder.onstart = () => console.log(`[HearTh] MediaRecorder started`);
    mediaRecorder.onstop = () =>
      console.log(
        `[HearTh] MediaRecorder stopped, chunks: ${audioChunks.length}`
      );
    mediaRecorder.onerror = (e) =>
      console.error(`[HearTh] MediaRecorder error:`, e);

    mediaRecorder.start(100);
    activeRecording = { mediaRecorder, audioChunks };
    return { id };
  }

  // ── STT: stop → POST to Whisper ─────────────────────────────────────────────

  async stopRecording(_handle: RecordingHandle): Promise<RecordingResult> {
    if (!activeRecording) throw new Error("No active recording");
    console.log(`[HearTh] stopRecording called`);

    const rec = activeRecording;
    activeRecording = null;

    await new Promise<void>((resolve) => {
      rec.mediaRecorder.onstop = () => resolve();
      rec.mediaRecorder.stop();
    });
    rec.mediaRecorder.stream.getTracks().forEach((t) => t.stop());

    console.log(`[HearTh] total chunks: ${rec.audioChunks.length}`);
    if (rec.audioChunks.length === 0) {
      throw new Error("No audio captured — please try again.");
    }

    const audioBlob = new Blob(rec.audioChunks, {
      type: rec.mediaRecorder.mimeType,
    });
    console.log(
      `[HearTh] blob: ${audioBlob.size} bytes, type: ${audioBlob.type}`
    );

    const form = new FormData();
    form.append("audio", audioBlob, "recording.webm");

    console.log(`[HearTh] POST ${this.base}/process`);
    const res = await fetch(`${this.base}/process`, {
      method: "POST",
      headers: { "X-HF-Token": storedToken() },
      body: form,
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: res.statusText }));
      throw new Error(err.detail || "Whisper transcription failed");
    }

    const data = await res.json();
    console.log(`[HearTh] /process response:`, data);

    const detectedCode: string = data.detected_language ?? "en";
    return {
      transcript: data.transcript,
      detectedLanguage: {
        code: detectedCode,
        flag: getFlag(detectedCode),
        confidence: 0.95,
      },
      audioBlob,
    };
  }

  // ── Translation ──────────────────────────────────────────────────────────────

  async translate(params: TranslateParams): Promise<TranslateResult> {
    const isWorker = params.speaker === "bottom"; // ← use speaker, not language code
    return isWorker
      ? this._workerTranslate(params.text)
      : this._residentTranslate(params.text, params.sourceLanguage);
  }

  // Resident → Aya translates to English.
  //
  // Talk mode: sttDetectedCode is a real code from Whisper (e.g. "zh", "ar").
  //            We pass the known language name; backend just translates.
  //
  // Type mode: sttDetectedCode is "und".
  //            Backend auto-detects the language and returns its name.
  //            We store whatever name the server sends back — not the "Unknown"
  //            we sent in, which was the original bug.
  private async _residentTranslate(
    text: string,
    sttDetectedCode: string
  ): Promise<TranslateResult> {
    const isUndetermined = sttDetectedCode === "und";
    const sttDetectedName = isUndetermined
      ? "Unknown"
      : LANG_CODE_TO_NAME[sttDetectedCode] ?? sttDetectedCode;

    const res = await fetch(`${this.base}/detect-and-translate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-HF-Token": storedToken(),
      },
      body: JSON.stringify({
        text,
        model_key: _regionKey,
        detected_language_code: sttDetectedCode,
        detected_language_name: sttDetectedName,
      }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: res.statusText }));
      const detail = err.detail;
      const message =
        typeof detail === "object" && detail?.message
          ? detail.message
          : detail || "Translation failed";
      throw new Error(message);
    }

    const data = await res.json();
    console.log(`[HearTh] /detect-and-translate response:`, data);

    // ── Key fix: always use the name the SERVER returns, not what we sent. ──
    // In talk mode these are the same. In type mode the server runs Aya
    // auto-detect and returns the real language name (e.g. "Chinese").
    const resolvedLanguageName: string = data.detected_language;

    // Code: trust Whisper in talk mode; in type mode we stay "und" for now
    // because Aya doesn't reliably return ISO codes. The name is enough for
    // the /translate direction.
    const resolvedCode: string = isUndetermined
      ? sttDetectedCode // "und" — we don't have a better code
      : data.detected_language_code;

    // Only update session state if we got a real language name back
    if (
      resolvedLanguageName &&
      resolvedLanguageName.toLowerCase() !== "unknown"
    ) {
      _residentLanguageName = resolvedLanguageName;
      _residentLanguage = {
        code: resolvedCode,
        flag: getFlag(resolvedCode),
        confidence: 0.95,
      };
    }

    return {
      translatedText: data.translation,
      targetLanguage: makeDetectedLanguage("en"),
      detectedSourceLanguage: _residentLanguage ?? {
        code: resolvedCode,
        flag: getFlag(resolvedCode),
        confidence: 0.95,
      },
    };
  }

  // Worker (English) → Aya translates to resident's language.
  // Throws a user-friendly error if resident hasn't spoken/typed yet.
  private async _workerTranslate(text: string): Promise<TranslateResult> {
    if (!_residentLanguage || !_residentLanguageName) {
      throw new Error(
        "Have the resident speak or type first so their language can be detected."
      );
    }

    const res = await fetch(`${this.base}/translate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-HF-Token": storedToken(),
      },
      body: JSON.stringify({
        text,
        model_key: _regionKey,
        target_lang: _residentLanguageName, // ← now always a real name like "Chinese"
      }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: res.statusText }));
      const detail = err.detail;
      const message =
        typeof detail === "object" && detail?.message
          ? detail.message
          : detail || "Translation failed";
      throw new Error(message);
    }

    const data = await res.json();
    console.log(`[HearTh] /translate response:`, data);

    return {
      translatedText: data.translation,
      targetLanguage: _residentLanguage,
    };
  }

  // ── TTS: browser SpeechSynthesis (Phase 0) ───────────────────────────────────

  async speak(text: string, languageCode: string): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!("speechSynthesis" in window)) {
        reject(new Error("SpeechSynthesis not supported"));
        return;
      }

      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = languageCode;
      utterance.rate = 0.9;

      const voices = speechSynthesis.getVoices();

      const FEMALE_VOICES = [
        "samantha",
        "flo",
        "sandy",
        "shelley",
        "grandma",
        "alice",
        "alva",
        "amélie",
        "amira",
        "anna",
        "carmit",
        "catherine",
        "damayanti",
        "daria",
        "ellen",
        "helena",
        "ioana",
        "joana",
        "kanya",
        "karen",
        "kathy",
        "kyoko",
        "lana",
        "laura",
        "lekha",
        "lesya",
        "linh",
        "luciana",
        "marie",
        "martha",
        "meijia",
        "melina",
        "milena",
        "moira",
        "montse",
        "mónica",
        "nora",
        "paulina",
        "sara",
        "satu",
        "sinji",
        "tessa",
        "tina",
        "tingting",
        "tünde",
        "vani",
        "yuna",
        "zosia",
        "zuzana",
        "google uk english female",
      ];

      const isFemale = (v: SpeechSynthesisVoice) =>
        FEMALE_VOICES.some((f) => v.name.toLowerCase().includes(f));

      const langCode = languageCode.toLowerCase().startsWith("zh")
        ? "zh"
        : languageCode.toLowerCase();

      const langVoices = voices.filter((v) =>
        v.lang.toLowerCase().startsWith(langCode)
      );

      const match =
        langVoices.find(isFemale) || langVoices[0] || voices.find(isFemale);

      console.log("[HearTh] selected voice:", match?.name, match?.lang);
      console.log(
        "[HearTh] lang voices:",
        langVoices.map((v) => v.name)
      );

      if (match) utterance.voice = match;

      utterance.onend = () => resolve("");
      utterance.onerror = (e) => reject(new Error(`TTS error: ${e.error}`));
      speechSynthesis.cancel();
      speechSynthesis.speak(utterance);
    });
  }
}

// ─── Singleton ────────────────────────────────────────────────────────────────

let _instance: HearThTranslationService | null = null;

export function getHearThService(): HearThTranslationService {
  if (!_instance) _instance = new HearThTranslationService();
  return _instance;
}
