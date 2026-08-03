"use client";

import { useState, useRef, useEffect } from "react";

// Generate animated waveform bar heights for the recording visualization
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
