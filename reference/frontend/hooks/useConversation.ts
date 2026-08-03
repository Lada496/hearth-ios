"use client";

import { useState, useCallback, useRef } from "react";
import type {
  TranslationResult,
  RecordingState,
  Speaker,
  TranslationService,
  DetectedLanguage,
} from "@/types";
import { getFlag } from "@/lib/hearth-translation-service";

// Build a DetectedLanguage object from a raw language code
function makeDetectedLanguage(code: string, confidence = 0.9) {
  const normalized = code.split("-")[0].toLowerCase();
  return { code: normalized, flag: getFlag(normalized), confidence };
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

// Manage the full conversation: recording, translation, playback, and history
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
  // the latest value without needing it in their dependency arrays
  const recordingStateRef = useRef(recordingState);
  recordingStateRef.current = recordingState;

  // Start capturing microphone audio for the given speaker
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

  // Stop recording, transcribe, translate, and append the resulting message
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
          speaker,
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

  // Translate typed text (as opposed to spoken/recorded audio)
  const submitText = useCallback(
    async (text: string, speaker: Speaker) => {
      if (!text.trim() || recordingStateRef.current.status !== "idle") return;

      setError(null);
      setRecordingState({ status: "processing", speaker });

      try {
        // Top = resident side → pass non-"en" so service routes to _residentTranslate
        // Bottom = worker side → pass "en" so service routes to _workerTranslate
        const sourceLanguage = speaker === "bottom" ? "en" : "und"; // "und" = undetermined

        const translateResult = await service.translate({
          text,
          sourceLanguage,
          speaker,
        });

        const detectedLang: DetectedLanguage =
          translateResult.detectedSourceLanguage ?? {
            code: speaker === "bottom" ? "en" : "und",
            flag: speaker === "bottom" ? getFlag("en") : "🌐",
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

  // Play a message's audio aloud via TTS, in the appropriate language for the viewer
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

  // Send a pre-written English message (e.g. a Support panel prompt), optionally auto-playing it
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

  // Reset the conversation back to an empty, idle state
  const clearConversation = useCallback(() => {
    setMessages([]);
    setRecordingState({ status: "idle" });
    setPlayingId(null);
  }, []);

  // Clear the current error message
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
