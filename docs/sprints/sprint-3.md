# Sprint 3 — Local Typed Translation (Aug 5–13)

**Goal:** replace the mock translator for typed turns with provisional Tiny-Aya Earth running
fully on-device. Translation accuracy is recorded but is not an acceptance gate.

## Tasks

### 3.1 — Lock prompt and output-cleaning behavior · Owner A · agent-safe · [#15](https://github.com/Lada496/hearth-ios/issues/15)
Resolve issue #15, parameterize source/target language names or codes, prevent answer-like model
responses, and cover cleanup behavior with fixtures. No prompt tuning beyond this contract.

### 3.2 — TinyAyaEarthEngine · Owner A · human-led core · [#20](https://github.com/Lada496/hearth-ios/issues/20)
Implement `TranslationEngine` over the allowed llama.cpp package and human-provided Q4 model.
Model load and generation must stay off the main thread. Agents must not add or download weights.

### 3.3 — Wire typed turns to Tiny-Aya Earth · Owner A/B · agent-safe · [#33](https://github.com/Lada496/hearth-ios/issues/33)
Replace only the translator mock in the composition root. Keep STT/TTS mocked and preserve the
mock-only test path. A debug-only injected resident-language fixture may exercise both request
directions before STT lands; it must not appear as a production support claim or picker.

### 3.4 — Model loading and failure UX · Owner B · agent-safe · [#28](https://github.com/Lada496/hearth-ios/issues/28)
Show preparation progress, retryable load failure, and usable non-model UI. Do not fake numeric
progress if the engine cannot report it.

### 3.5 — Session privacy lifecycle · Owner A · agent-safe · [#21](https://github.com/Lada496/hearth-ios/issues/21)
End-session clears messages and language metadata. Backgrounding for more than five minutes does
the same. Unit tests use an injected clock and never persist conversation content.

## Exit criteria

- A supported device completes typed local translations in airplane mode.
- CI tests continue to run without model files.
- UI stays responsive during model load and generation.
