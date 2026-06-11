"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import styles from "./page.module.css";

export default function LandingPage() {
  const router = useRouter();
  const [leaving, setLeaving] = useState(false);

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
