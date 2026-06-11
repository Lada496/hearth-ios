"use client";

import { useState, useCallback, useRef, useEffect } from "react";
import type {
  TranslationResult,
  RecordingState,
  Speaker,
  TranslationService,
  DetectedLanguage,
} from "@/types";

// ─── useConversation ───
// Manages the full conversation state: messages, recording, translation, playback.
function makeDetectedLanguage(code: string, confidence = 0.9) {
  return { code: code.split("-")[0].toLowerCase(), flag: "🇬🇧", confidence };
}
interface UseConversationReturn {
  messages: TranslationResult[];
  recordingState: RecordingState;
  playingId: string | null;
  error: string | null;
  startRecording: (speaker: Speaker) => Promise<void>;
  stopRecording: (speaker: Speaker) => Promise<void>;
  sendMessage: (
    text: string,
    speaker: Speaker,
    autoPlay?: boolean
  ) => Promise<void>;
  submitText: (text: string, speaker: Speaker) => Promise<void>;
  playMessage: (messageId: string, viewer: Speaker) => Promise<void>;
  clearConversation: () => void;
  dismissError: () => void;
}

export function useConversation(
  service: TranslationService
): UseConversationReturn {
  const [messages, setMessages] = useState<TranslationResult[]>([]);
  const [recordingState, setRecordingState] = useState<RecordingState>({
    status: "idle",
  });
  const [playingId, setPlayingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const recordingHandleRef = useRef<any>(null);

  // Keep a ref in sync with recordingState so callbacks always see
  // the latest value without needing it in their dependency arrays.
  const recordingStateRef = useRef(recordingState);
  recordingStateRef.current = recordingState;

  const startRecording = useCallback(
    async (speaker: Speaker) => {
      if (recordingStateRef.current.status !== "idle") return;

      try {
        setError(null);
        setRecordingState({ status: "recording", speaker });
        const handle = await service.startRecording();
        recordingHandleRef.current = handle;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Failed to start recording";
        setError(message);
        setRecordingState({ status: "idle" });
      }
    },
    [service]
  );

  const stopRecording = useCallback(
    async (speaker: Speaker) => {
      const currentState = recordingStateRef.current;
      if (
        currentState.status !== "recording" ||
        currentState.speaker !== speaker
      ) {
        return;
      }

      const handle = recordingHandleRef.current;
      if (!handle) return;
      recordingHandleRef.current = null;

      try {
        setRecordingState({ status: "processing", speaker });

        // 1. Stop recording → get transcript + detected language
        const recordingResult = await service.stopRecording(handle);

        if (!recordingResult.transcript.trim()) {
          setRecordingState({ status: "idle" });
          return;
        }

        // 2. Translate the transcript
        const translateResult = await service.translate({
          text: recordingResult.transcript,
          speaker, // ← add this
          sourceLanguage: recordingResult.detectedLanguage.code,
        });

        // 3. Build the message
        const message: TranslationResult = {
          id: `msg-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
          speaker,
          detectedLanguage: recordingResult.detectedLanguage,
          targetLanguage: translateResult.targetLanguage,
          originalText: recordingResult.transcript,
          translatedText: translateResult.translatedText,
          timestamp: Date.now(),
        };

        setMessages((prev) => [...prev, message]);
        setRecordingState({ status: "idle" });
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Translation failed";
        setError(message);
        setRecordingState({ status: "idle" });
      }
    },
    [service]
  );

  const submitText = useCallback(
    async (text: string, speaker: Speaker) => {
      if (!text.trim() || recordingStateRef.current.status !== "idle") return;

      setError(null);
      setRecordingState({ status: "processing", speaker });

      try {
        // top = resident side → pass non-"en" so service routes to _residentTranslate
        // bottom = worker side → pass "en" so service routes to _workerTranslate
        const sourceLanguage = speaker === "bottom" ? "en" : "und"; // "und" = undetermined

        const translateResult = await service.translate({
          text,
          sourceLanguage,
        });

        const detectedLang: DetectedLanguage =
          translateResult.detectedSourceLanguage ?? {
            code: speaker === "bottom" ? "en" : "und",
            flag: speaker === "bottom" ? "🇬🇧" : "🌐",
            confidence: 1,
          };

        const message: TranslationResult = {
          id: `msg-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
          speaker,
          detectedLanguage: detectedLang,
          targetLanguage: translateResult.targetLanguage,
          originalText: text,
          translatedText: translateResult.translatedText,
          timestamp: Date.now(),
        };

        setMessages((prev) => [...prev, message]);
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "Translation failed";
        setError(message);
      } finally {
        setRecordingState({ status: "idle" });
      }
    },
    [service]
  );

  const playMessage = useCallback(
    async (messageId: string, viewer: Speaker) => {
      const msg = messages.find((m) => m.id === messageId);
      if (!msg || playingId) return;

      const isMyMessage = msg.speaker === viewer;
      const text = isMyMessage ? msg.originalText : msg.translatedText;
      const langCode = isMyMessage ? msg.detectedLanguage.code : msg.targetLanguage.code;

      try {
        setPlayingId(messageId);
        await service.speak(text, langCode);
      } catch (err) {
        console.warn("TTS playback failed:", err);
      } finally {
        setPlayingId(null);
      }
    },
    [messages, playingId, service]
  );

  const sendMessage = useCallback(
    async (text: string, speaker: Speaker, autoPlay = false) => {
      if (recordingStateRef.current.status !== "idle") return;
      setRecordingState({ status: "processing", speaker });
      try {
        const translateResult = await service.translate({
          text,
          sourceLanguage: "en",
          speaker,
        });
        const message: TranslationResult = {
          id: `msg-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
          speaker,
          detectedLanguage: makeDetectedLanguage("en"),
          targetLanguage: translateResult.targetLanguage,
          originalText: text,
          translatedText: translateResult.translatedText,
          timestamp: Date.now(),
        };
        setMessages((prev) => [...prev, message]);
        setRecordingState({ status: "idle" });
        if (autoPlay) {
          try {
            setPlayingId(message.id);
            await service.speak(
              message.translatedText,
              message.targetLanguage.code
            );
          } catch {
          } finally {
            setPlayingId(null);
          }
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to send message");
        setRecordingState({ status: "idle" });
      }
    },
    [service]
  );

  const clearConversation = useCallback(() => {
    setMessages([]);
    setRecordingState({ status: "idle" });
    setPlayingId(null);
  }, []);

  const dismissError = useCallback(() => setError(null), []);

  return {
    messages,
    recordingState,
    playingId,
    error,
    startRecording,
    stopRecording,
    sendMessage,
    submitText,
    playMessage,
    clearConversation,
    dismissError,
  };
}

// ─── useWaveform ───
// Generates animated waveform bar heights for the recording visualization.

export function useWaveform(active: boolean, barCount: number = 12) {
  const [bars, setBars] = useState<number[]>(Array(barCount).fill(4));
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    if (active) {
      intervalRef.current = setInterval(() => {
        setBars(
          Array(barCount)
            .fill(0)
            .map(() => Math.random() * 24 + 5)
        );
      }, 90);
    } else {
      if (intervalRef.current) clearInterval(intervalRef.current);
      setBars(Array(barCount).fill(4));
    }

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [active, barCount]);

  return bars;
}

// ─── usePWA ───
// Tracks PWA install state and provides install prompt.

interface PWAState {
  isOnline: boolean;
  canInstall: boolean;
  isStandalone: boolean;
  promptInstall: () => Promise<void>;
}

export function usePWA(): PWAState {
  const [isOnline, setIsOnline] = useState(true);
  const [canInstall, setCanInstall] = useState(false);
  const [isStandalone, setIsStandalone] = useState(false);
  const deferredPromptRef = useRef<any>(null);

  useEffect(() => {
    // Online/offline tracking
    setIsOnline(navigator.onLine);
    const goOnline = () => setIsOnline(true);
    const goOffline = () => setIsOnline(false);
    window.addEventListener("online", goOnline);
    window.addEventListener("offline", goOffline);

    // Standalone detection
    setIsStandalone(
      window.matchMedia("(display-mode: standalone)").matches ||
        (window.navigator as any).standalone === true
    );

    // Install prompt
    const handleBeforeInstall = (e: Event) => {
      e.preventDefault();
      deferredPromptRef.current = e;
      setCanInstall(true);
    };
    window.addEventListener("beforeinstallprompt", handleBeforeInstall);

    return () => {
      window.removeEventListener("online", goOnline);
      window.removeEventListener("offline", goOffline);
      window.removeEventListener("beforeinstallprompt", handleBeforeInstall);
    };
  }, []);

  const promptInstall = useCallback(async () => {
    if (!deferredPromptRef.current) return;
    deferredPromptRef.current.prompt();
    const result = await deferredPromptRef.current.userChoice;
    if (result.outcome === "accepted") {
      setCanInstall(false);
    }
    deferredPromptRef.current = null;
  }, []);

  return { isOnline, canInstall, isStandalone, promptInstall };
}

// ─── useTranscripts ───
// Manages saved transcripts in localStorage.

import { makeStore, StorageFullError } from "@/lib/transcriptStore";
import type { SavedTranscript } from "@/types";

type SaveResult =
  | { ok: true }
  | { ok: false; reason: "empty" | "storage_full" | "unavailable" };

export interface UseTranscriptsReturn {
  transcripts: SavedTranscript[];
  saveTranscript(messages: TranslationResult[]): SaveResult;
  deleteTranscript(id: string): void;
  storageError: string | null;
  dismissStorageError: () => void;
}

function makeTranscript(messages: TranslationResult[]): SavedTranscript {
  const now = new Date();
  const weekday = now.toLocaleDateString("en-GB", { weekday: "short" });
  const day = now.getDate();
  const month = now.toLocaleDateString("en-GB", { month: "short" });
  const hours = String(now.getHours()).padStart(2, "0");
  const minutes = String(now.getMinutes()).padStart(2, "0");
  const title = `Session \u2013 ${weekday} ${day} ${month}, ${hours}:${minutes}`;
  return {
    id: crypto.randomUUID(),
    title,
    savedAt: Date.now(),
    messages,
  };
}

let _store: ReturnType<typeof makeStore> | null = null;

function getStore() {
  if (typeof window === "undefined") return null;
  if (!_store) _store = makeStore(window.localStorage);
  return _store;
}

export function useTranscripts(): UseTranscriptsReturn {
  const [transcripts, setTranscripts] = useState<SavedTranscript[]>([]);
  const [storageError, setStorageError] = useState<string | null>(null);

  useEffect(() => {
    const store = getStore();
    if (!store) return;
    try {
      setTranscripts(store.getAll());
    } catch {
      setStorageError("Could not load saved transcripts");
    }
  }, []);

  const saveTranscript = useCallback(
    (messages: TranslationResult[]): SaveResult => {
      if (messages.length === 0) return { ok: false, reason: "empty" };
      const store = getStore();
      if (!store) return { ok: false, reason: "unavailable" };
      try {
        store.add(makeTranscript(messages));
        setTranscripts(store.getAll());
        return { ok: true };
      } catch (err) {
        if (err instanceof StorageFullError) {
          return { ok: false, reason: "storage_full" };
        }
        return { ok: false, reason: "unavailable" };
      }
    },
    []
  );

  const deleteTranscript = useCallback((id: string) => {
    const store = getStore();
    if (!store) return;
    try {
      store.remove(id);
      setTranscripts(store.getAll());
    } catch (err) {
      setStorageError(
        err instanceof Error ? err.message : "Could not delete transcript"
      );
    }
  }, []);

  const dismissStorageError = useCallback(() => setStorageError(null), []);

  return { transcripts, saveTranscript, deleteTranscript, storageError, dismissStorageError };
}
