"use client";

import { useCallback } from "react";
import { MicIcon, StopIcon } from "./Icons";
import type { Speaker } from "@/types";
import styles from "./MicButton.module.css";

interface MicButtonProps {
  speaker: Speaker;
  isRecording: boolean;
  isDisabled: boolean;
  onStart: (speaker: Speaker) => void;
  onStop: (speaker: Speaker) => void;
  /** If true, the button + pulse rings are rotated 180deg */
  flipped?: boolean;
}

export function MicButton({
  speaker,
  isRecording,
  isDisabled,
  onStart,
  onStop,
  flipped = false,
}: MicButtonProps) {
  const vibrate = (pattern: number | number[]) => {
    if (typeof navigator !== "undefined" && navigator.vibrate) {
      navigator.vibrate(pattern);
    }
  };

  const handlePointerDown = useCallback(
    (e: React.PointerEvent) => {
      e.preventDefault();
      if (!isDisabled) {
        vibrate(30);
        onStart(speaker);
      }
    },
    [isDisabled, onStart, speaker]
  );

  const handlePointerUp = useCallback(
    (e: React.PointerEvent) => {
      e.preventDefault();
      vibrate(20);
      onStop(speaker);
    },
    [onStop, speaker]
  );

  const handlePointerLeave = useCallback(
    (e: React.PointerEvent) => {
      e.preventDefault();
      if (isRecording) onStop(speaker);
    },
    [isRecording, onStop, speaker]
  );

  return (
    <div
      className={styles.zone}
      style={flipped ? { transform: "rotate(180deg)" } : undefined}
    >
      <div className={styles.wrap}>
        {isRecording && (
          <>
            <div className={styles.pulse} />
            <div className={styles.pulse} />
            <div className={styles.pulse} />
          </>
        )}
        <button
          className={`${styles.btn} ${isRecording ? styles.recording : ""} ${isDisabled ? styles.disabled : ""}`}
          onPointerDown={handlePointerDown}
          onPointerUp={handlePointerUp}
          onPointerLeave={handlePointerLeave}
          onContextMenu={(e) => e.preventDefault()}
          aria-label={isRecording ? "Stop recording" : "Start recording"}
        >
          {isRecording ? <StopIcon size={24} /> : <MicIcon size={24} />}
        </button>
      </div>
    </div>
  );
}
