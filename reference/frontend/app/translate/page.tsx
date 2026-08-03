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
  RegionPicker,
} from "@/components";
import { getHearThService } from "@/lib/hearth-translation-service";
import styles from "./page.module.css";

// Icon for the "view saved transcripts" button
function TranscriptIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm7 16H5V5h2v3h10V5h2v14z" />
    </svg>
  );
}

// Main translation screen: talk/support tabs, conversation threads, and transcripts
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
  const [bottomInputOpen, setBottomInputOpen] = useState(false);

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

  const isProcessing = recordingState.status === "processing";
  const recordingSpeaker =
    recordingState.status !== "idle" ? recordingState.speaker : null;

  // Send a tapped support prompt as a worker message and switch to the talk tab
  function handlePromptSelect(text: string) {
    sendMessage(text, "bottom", false);
    setActiveTab("talk");
  }

  // Clear the conversation when the region picker starts a new session
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
              onOpenChange={setBottomInputOpen}
            />
            {/* Transcript controls — pinned to bottom-right, out of flow */}
            <div
              className={`${styles.transcriptControls} ${
                bottomInputOpen ? styles.transcriptControlsRaised : ""
              }`}
            >
              <SaveButton
                onSave={() => saveTranscript(messages)}
                onClear={clearConversation}
              />
              <button
                className={`${styles.transcriptBtn} tooltipEnd`}
                aria-label="View saved transcripts"
                data-tooltip="View transcripts"
                onClick={() => setShowOverlay(true)}
              >
                <TranscriptIcon />
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
