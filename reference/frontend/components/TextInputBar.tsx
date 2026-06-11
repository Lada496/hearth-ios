"use client";

import { useState, useRef, useCallback, useEffect } from "react";
import type { Speaker } from "@/types";
import styles from "./TextInputBar.module.css";

function KeyboardIcon() {
  return (
    <svg width="45" height="45" viewBox="0 0 40 40" fill="currentColor" aria-hidden>
      <path d="M20 5H4c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm-9 3h2v2h-2V8zm0 3h2v2h-2v-2zM8 8h2v2H8V8zm0 3h2v2H8v-2zm-1 2H5v-2h2v2zm0-3H5V8h2v2zm9 7H8v-2h8v2zm0-4h-2v-2h2v2zm0-3h-2V8h2v2zm3 3h-2v-2h2v2zm0-3h-2V8h2v2z" />
    </svg>
  );
}

function ChevronDownIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <polyline points="6 9 12 15 18 9" />
    </svg>
  );
}

function SendIcon() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z" />
    </svg>
  );
}

interface TextInputBarProps {
  speaker: Speaker;
  onSubmit: (text: string, speaker: Speaker) => Promise<void>;
  isDisabled?: boolean;
}

export function TextInputBar({ speaker, onSubmit, isDisabled }: TextInputBarProps) {
  const [text, setText] = useState("");
  const [open, setOpen] = useState(false);
  const taRef = useRef<HTMLTextAreaElement>(null);

  const placeholder = speaker === "top" ? "Type in any language…" : "Type in English…";

  useEffect(() => {
    if (open) taRef.current?.focus();
  }, [open]);

  const handleSubmit = useCallback(async () => {
    const value = text.trim();
    if (!value || isDisabled) return;
    setText("");
    if (taRef.current) taRef.current.style.height = "auto";
    await onSubmit(value, speaker);
  }, [text, isDisabled, onSubmit, speaker]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        handleSubmit();
      }
    },
    [handleSubmit]
  );

  const handleChange = useCallback((e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setText(e.target.value);
    const ta = e.target;
    ta.style.height = "auto";
    ta.style.height = `${Math.min(ta.scrollHeight, 96)}px`;
  }, []);

  return (
    <div className={styles.bar}>
      <button
        className={`${styles.toggle} ${open ? styles.toggleOpen : ""}`}
        onClick={() => setOpen((o) => !o)}
        aria-label={open ? "Hide text input" : "Show text input"}
        aria-expanded={open}
      >
        {open ? <ChevronDownIcon /> : <KeyboardIcon />}
      </button>

      <div className={`${styles.collapsible} ${open ? styles.collapsibleOpen : ""}`}>
        <div className={styles.inner}>
          <div className={styles.inputCard}>
            <textarea
              ref={taRef}
              className={styles.input}
              value={text}
              placeholder={placeholder}
              rows={1}
              disabled={isDisabled}
              onChange={handleChange}
              onKeyDown={handleKeyDown}
            />
            <button
              className={styles.sendBtn}
              onClick={handleSubmit}
              disabled={!text.trim() || isDisabled}
              aria-label="Send"
            >
              <SendIcon />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
