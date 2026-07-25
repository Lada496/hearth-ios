# Sprint 4 — Voice Loop and Runtime Capabilities (Aug 14–23)

**Goal:** connect live speech input and capability-based output without choosing launch
languages. The audio/model owners may start these tasks earlier when dependencies are ready.

## Tasks

### 4.1 — WhisperKit device spike · Owner C · human device test · [#2](https://github.com/Lada496/hearth-ios/issues/2)
Validate recording-to-transcript and language-code output with several smoke fixtures. Report
latency, memory, and failures without classifying any language as supported.

### 4.2 — AudioSessionManager · Owner C · human-owned · [#13](https://github.com/Lada496/hearth-ios/issues/13)
Produce 16 kHz mono PCM, handle permission denial, interruptions, and record/playback handoff.
Physical-device evidence is required.

### 4.3 — WhisperKitSTT adapter · Owner C · agent-safe glue, human device review · [#22](https://github.com/Lada496/hearth-ios/issues/22)
Implement the frozen protocol with the bundled multilingual model. Keep framework details behind
an adapter so unit tests use fakes and no weights.

### 4.4 — System TTS and text fallback · Owner C/B · agent-safe · [#32](https://github.com/Lada496/hearth-ios/issues/32)
Choose the best installed voice for the runtime language code. Return unsupported when none
exists; the ViewModel then exposes large text instead of a play action.

### 4.5 — Wire the full voice loop · Owner A/C · agent-safe, human device review · [#34](https://github.com/Lada496/hearth-ios/issues/34)
Connect press-and-hold audio, STT detection, Tiny-Aya translation, optional TTS, replay, errors,
and record/playback exclusion. Preserve the typed path.

## Exit criteria

- A supported iPhone completes both conversation directions in airplane mode.
- Missing TTS voices produce readable text, not an error.
- No result is described as proof of production translation quality.
