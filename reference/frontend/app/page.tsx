"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { clearSession } from "@/lib/hearth-translation-service";
import styles from "./page.module.css";

// Landing page shown before starting a translation session
export default function LandingPage() {
  const router = useRouter();
  const [leaving, setLeaving] = useState(false);

  // Arriving at the landing page always means a fresh start — clear any
  // resident language left over from a previous session (client-side
  // navigation doesn't reload the JS module state on its own)
  useEffect(() => {
    clearSession();
  }, []);

  // Fade out and navigate to the translation screen
  function handleStart() {
    setLeaving(true);
    setTimeout(() => router.push("/translate"), 200);
  }

  return (
    <main className={`${styles.page} ${leaving ? styles.fadeOut : ""}`}>
      <h1 className={styles.title}>Hearth</h1>
      <p className={styles.subtitle}>Real-time translation, face to face</p>
      <button className={styles.cta} onClick={handleStart}>
        Start conversation
      </button>
    </main>
  );
}
