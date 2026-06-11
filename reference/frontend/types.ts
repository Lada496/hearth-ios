// ─── Core domain types ───

export type Speaker = "top" | "bottom";

export interface DetectedLanguage {
  /** ISO 639-1 code, e.g. "es", "ar", "en" */
  code: string;
  /** Flag emoji for display */
  flag: string;
  /** Confidence score 0-1 from the detection engine */
  confidence: number;
}

export interface TranslationResult {
  /** Unique message ID (UUID or timestamp-based) */
  id: string;
  /** Which mic was used */
  speaker: Speaker;
  /** Detected source language */
  detectedLanguage: DetectedLanguage;
  /** Target language the text was translated into */
  targetLanguage: DetectedLanguage;
  /** Original spoken text (transcription) */
  originalText: string;
  /** Translated text */
  translatedText: string;
  /** Timestamp of when the message was created */
  timestamp: number;
  /** Optional: audio blob URL for playback of the translation */
  ttsAudioUrl?: string;
}

export interface SavedTranscript {
  /** UUID v4 — assigned at save time */
  id: string;
  /** Auto-generated: "Session – Mon 14 Jul, 09:32" */
  title: string;
  /** Unix ms timestamp of when the transcript was saved */
  savedAt: number;
  /** Copy of the messages array at save time */
  messages: TranslationResult[];
}

// ─── Recording state machine ───

export type RecordingState =
  | { status: "idle" }
  | { status: "recording"; speaker: Speaker }
  | { status: "processing"; speaker: Speaker };

// ─── Speech recognition / translation service interface ───
// Implement this interface to connect your backend.

export interface TranslationService {
  /**
   * Start recording audio from the microphone.
   * Returns a handle to stop recording later.
   */
  startRecording(): Promise<RecordingHandle>;

  /**
   * Stop recording and get back the audio + detected language.
   */
  stopRecording(handle: RecordingHandle): Promise<RecordingResult>;

  /**
   * Translate text from one language to another.
   * This is where your on-device LLM or API call goes.
   */
  translate(params: TranslateParams): Promise<TranslateResult>;

  /**
   * Generate text-to-speech audio for a given text and language.
   * Returns a blob URL that can be played with <audio>.
   */
  speak(text: string, languageCode: string): Promise<string>;
}

export interface RecordingHandle {
  /** Opaque handle ID */
  id: string;
}

export interface RecordingResult {
  /** Transcribed text from speech */
  transcript: string;
  /** Detected language of the speech */
  detectedLanguage: DetectedLanguage;
  /** Raw audio blob (for potential replay) */
  audioBlob?: Blob;
}

export interface TranslateParams {
  text: string;
  sourceLanguage: string;
  targetLanguage?: string; // if omitted, auto-detect best target
  speaker?: Speaker;
}

export interface TranslateResult {
  translatedText: string;
  targetLanguage: DetectedLanguage;
  /** Set when the source language was auto-detected by the backend */
  detectedSourceLanguage?: DetectedLanguage;
}

// ─── TTS playback state ───

export interface PlaybackState {
  /** ID of the message currently being played, or null */
  playingId: string | null;
}

// ─── PWA / service worker ───

export interface PWAStatus {
  isInstalled: boolean;
  isOnline: boolean;
  canInstall: boolean;
  updateAvailable: boolean;
}
