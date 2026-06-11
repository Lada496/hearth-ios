"use client";

import { useWaveform } from "@/hooks";
import styles from "./Waveform.module.css";

interface WaveformProps {
  active: boolean;
  barCount?: number;
}

export function Waveform({ active, barCount = 12 }: WaveformProps) {
  const bars = useWaveform(active, barCount);

  return (
    <div className={styles.container}>
      <div className={styles.waveform}>
        {bars.map((height, i) => (
          <div
            key={i}
            className={styles.bar}
            style={{ height: `${height}px` }}
          />
        ))}
      </div>
    </div>
  );
}
