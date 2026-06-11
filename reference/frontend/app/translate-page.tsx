"use client";

import { useState, useRef } from "react";
import { useConversation, useTranscripts } from "@/hooks";
import {
  MicButton,
  ConversationThread,
  SupportPanel,
  TextInputBar,
  SaveButton,
  TranscriptOverlay,
} from "@/components";
import { RegionPicker } from "@/components/RegionPicker";
import { getHearThService } from "@/lib/hearth-translation-service";
import styles from "./page.module.css";

export default function AppPage() {
  const hearthServiceRef = useRef<ReturnType<typeof getHearThService> | null>(
    null
  );
  if (!hearthServiceRef.current) {
    hearthServiceRef.current = getHearThService();
  }
  const hearthService = hearthServiceRef.current;
  const [activeTab, setActiveTab] = useState<"talk" | "support">("talk");
  const [showOverlay, setShowOverlay] = useState(false);

  const {
    messages,
    recordingState,
    playingId,
    error,
    startRecording,
    stopRecording,
    submitText,
    playMessage,
    sendMessage,
    clearConversation,
    dismissError,
  } = useConversation(hearthService);

  const {
    transcripts,
    saveTranscript,
    deleteTranscript,
    storageError,
    dismissStorageError,
  } = useTranscripts();

  const isRecording = recordingState.status === "recording";
  const isProcessing = recordingState.status === "processing";
  const recordingSpeaker =
    recordingState.status !== "idle" ? recordingState.speaker : null;

  function handlePromptSelect(text: string) {
    sendMessage(text, "bottom", true);
    setActiveTab("talk");
  }

  function handleClearSession() {
    clearConversation();
  }

  return (
    <main className={styles.shell}>
      {/* Error toast */}
      {error && (
        <div className={styles.errorToast} onClick={dismissError}>
          {error}
        </div>
      )}
      {storageError && (
        <div className={styles.errorToast} onClick={dismissStorageError}>
          {storageError}
        </div>
      )}

      {/* Persistent tab bar — top right */}
      <div className={styles.persistentTab}>
        <div className={styles.tabBar}>
          <div
            className={`${styles.slider} ${
              activeTab === "support" ? styles.sliderRight : ""
            }`}
          />
          <button
            className={`${styles.tab} ${
              activeTab === "talk" ? styles.tabActive : ""
            }`}
            onClick={() => setActiveTab("talk")}
          >
            Talk
          </button>
          <button
            className={`${styles.tab} ${
              activeTab === "support" ? styles.tabActive : ""
            }`}
            onClick={() => setActiveTab("support")}
          >
            Support
          </button>
        </div>
      </div>

      <div className={styles.tabsWrapper}>
        {/* Talk panel */}
        <div className={`${styles.tabContent} ${activeTab === "talk" ? styles.tabVisible : styles.tabHidden}`}>
          {/* Top half — rotated conversation (resident side) */}
          <div className={`${styles.half} ${styles.top}`}>
            <ConversationThread
              messages={messages}
              viewer="top"
              playingId={playingId}
              isRecording={recordingSpeaker === "top"}
              isProcessing={isProcessing}
              onPlay={playMessage}
            />
            <MicButton
              speaker="top"
              isRecording={recordingSpeaker === "top"}
              isDisabled={recordingSpeaker === "bottom" || isProcessing}
              onStart={startRecording}
              onStop={stopRecording}
            />
            <TextInputBar
              speaker="top"
              onSubmit={submitText}
              isDisabled={recordingState.status !== "idle"}
            />
          </div>

          {/* Center divider with RegionPicker */}
          <div className={styles.centerDivider}>
            <RegionPicker onClearSession={handleClearSession} />
          </div>

          {/* Bottom half — normal orientation (worker side) */}
          <div className={styles.half}>
            {showOverlay && (
              <TranscriptOverlay
                transcripts={transcripts}
                onDelete={deleteTranscript}
                onClose={() => setShowOverlay(false)}
              />
            )}
            <ConversationThread
              messages={messages}
              viewer="bottom"
              playingId={playingId}
              isRecording={recordingSpeaker === "bottom"}
              isProcessing={isProcessing}
              onPlay={playMessage}
            />
            <MicButton
              speaker="bottom"
              isRecording={recordingSpeaker === "bottom"}
              isDisabled={recordingSpeaker === "top" || isProcessing}
              onStart={startRecording}
              onStop={stopRecording}
            />
            <TextInputBar
              speaker="bottom"
              onSubmit={submitText}
              isDisabled={recordingState.status !== "idle"}
            />
            {/* Transcript controls — pinned to bottom-right, out of flow */}
            <div className={styles.transcriptControls}>
              <SaveButton
                onSave={() => saveTranscript(messages)}
                onClear={clearConversation}
              />
              <button
                className={styles.transcriptBtn}
                aria-label="View saved transcripts"
                onClick={() => setShowOverlay(true)}
              >
                📋
              </button>
            </div>
          </div>
        </div>

        {/* Support panel */}
        <div className={`${styles.tabContent} ${activeTab === "support" ? styles.tabVisible : styles.tabHidden}`}>
          <SupportPanel key={activeTab} onSelect={handlePromptSelect} />
        </div>
      </div>
    </main>
  );
}
