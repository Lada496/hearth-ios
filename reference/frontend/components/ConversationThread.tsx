"use client";

import { useRef, useEffect, useState } from "react";
import { SpeakerIcon, PlayingIcon, MicIcon } from "./Icons";
import { Waveform } from "./Waveform";
import type { TranslationResult, Speaker } from "@/types";
import styles from "./ConversationThread.module.css";

const LANGUAGE_NAMES: Record<string, string> = {
  am: "አማርኛ",           ar: "العربية",         eu: "Euskara",
  bn: "বাংলা",           bg: "Български",       my: "မြန်မာဘာသာ",
  ca: "Català",          zh: "普通话",           hr: "Hrvatski",
  cs: "Čeština",         da: "Dansk",           nl: "Nederlands",
  en: "English",         et: "Eesti",           fi: "Suomi",
  fr: "Français",        gl: "Galego",          de: "Deutsch",
  el: "Ελληνικά",        gu: "ગુજરાતી",          ha: "Hausa",
  he: "עברית",           hi: "हिन्दी",           hu: "Magyar",
  ig: "Igbo",            id: "Bahasa Indonesia", ga: "Gaeilge",
  it: "Italiano",        ja: "日本語",           jv: "Basa Jawa",
  km: "ខ្មែរ",            ko: "한국어",           lo: "ລາວ",
  lv: "Latviešu",        lt: "Lietuvių",        mg: "Malagasy",
  ms: "Bahasa Melayu",   mt: "Malti",           mr: "मराठी",
  ne: "नेपाली",           no: "Norsk",           fa: "فارسی",
  pl: "Polski",          pt: "Português",       pa: "ਪੰਜਾਬੀ",
  ro: "Română",          ru: "Русский",         sr: "Српски",
  sn: "ChiShona",        sk: "Slovenčina",      sl: "Slovenščina",
  es: "Español",         sw: "Kiswahili",       sv: "Svenska",
  tl: "Filipino",        ta: "தமிழ்",            te: "తెలుగు",
  th: "ไทย",             tr: "Türkçe",          uk: "Українська",
  ur: "اردو",            vi: "Tiếng Việt",      cy: "Cymraeg",
  wo: "Wolof",           xh: "isiXhosa",        yo: "Yorùbá",
  zu: "isiZulu",         yue: "廣東話",          so: "Soomaali",
  ti: "ትግርኛ",
};

// Look up a language's display name from its code, in its own script where possible
function getLanguageName(code: string): string {
  const base = code.split("-")[0].toLowerCase();
  if (base === "und") return "Undefined";
  return LANGUAGE_NAMES[base] ?? code.toUpperCase();
}

interface ConversationThreadProps {
  messages: TranslationResult[];
  viewer: Speaker;
  playingId: string | null;
  isRecording: boolean;
  isProcessing: boolean;
  onPlay: (id: string, viewer: Speaker) => void;
}

// Show the latest conversation message, with its language badge and playback button
export function ConversationThread({
  messages,
  viewer,
  playingId,
  isRecording,
  isProcessing,
  onPlay,
}: ConversationThreadProps) {
  const textRef = useRef<HTMLSpanElement>(null);
  const btnRef = useRef<HTMLButtonElement>(null);
  const [wrapped, setWrapped] = useState(false);

  useEffect(() => {
    // Detect whether the play button has wrapped onto its own line
    function check() {
      if (!textRef.current || !btnRef.current) return;
      const textBottom = textRef.current.getBoundingClientRect().bottom;
      const btnTop = btnRef.current.getBoundingClientRect().top;
      setWrapped(btnTop > textBottom - 4);
    }
    check();
    const observer = new ResizeObserver(check);
    if (textRef.current) observer.observe(textRef.current);
    return () => observer.disconnect();
  }, [messages]);

  if (isRecording) return <Waveform active={true} />;

  if (isProcessing) {
    return (
      <div className={styles.processingOverlay}>
        <div className={styles.dot} />
        <div className={styles.dot} />
        <div className={styles.dot} />
      </div>
    );
  }

  const latest = messages[messages.length - 1] ?? null;

  if (!latest) {
    return (
      <div className={styles.empty}>
        <MicIcon size={32} />
      </div>
    );
  }

  const isMyMessage = latest.speaker === viewer;
  const text = isMyMessage ? latest.originalText : latest.translatedText;
  const lang = isMyMessage ? latest.detectedLanguage : latest.targetLanguage;
  const isPlaying = playingId === latest.id;

  return (
    <div className={styles.view}>
      <div className={styles.langBadge}>
        {lang.flag} {getLanguageName(lang.code)}
      </div>
      <div className={styles.textRow}>
        <span ref={textRef} className={styles.text}>{text}</span>
        <button
          ref={btnRef}
          className={`${styles.playBtn} ${isPlaying ? styles.playing : ""} ${wrapped ? styles.playBtnWrapped : ""}`}
          onClick={() => onPlay(latest.id, viewer)}
          aria-label="Play aloud"
        >
          {isPlaying ? <PlayingIcon size={25} /> : <SpeakerIcon size={25} />}
        </button>
      </div>
    </div>
  );
}
