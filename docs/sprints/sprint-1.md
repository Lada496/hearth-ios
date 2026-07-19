# Sprint 1 — Guardrails and Foundation (Jul 19–26)

**Goal:** create stable, language-neutral seams so UI and engine work can proceed safely in
parallel. Read `../PRD.md`, `../ROADMAP.md`, `../adr/ADRs.md`, and `../../AGENTS.md` first.

## Tasks

### 1.1 — Finish repository guardrails · Owner D · agent-safe · [#4](https://github.com/Lada496/hearth-ios/issues/4)
Keep the existing Xcode scaffold. Add build/test CI, SwiftLint, the networking-API ban, and
documented branch protection. Do not touch signing or model resources.

### 1.2 — Language-neutral domain model · Owner A · agent-safe · [#7](https://github.com/Lada496/hearth-ios/issues/7)
Add `Message`, `Speaker`, `Language`, and `SessionPhase`. `Language` stores normalized code,
display name, and optional flag but no launch tier. Seed data exists only as preview/test
fixtures and must be named accordingly.

### 1.3 — Freeze engine protocols and mocks · Owner A · agent-safe, two-human review · [#8](https://github.com/Lada496/hearth-ios/issues/8)
Define async `SpeechToText`, `TranslationEngine`, and `TextToSpeech` contracts plus configurable
mocks. Protocols accept runtime language metadata and contain no fixed language list.

### 1.4 — Design system · Owner B · agent-safe · [#10](https://github.com/Lada496/hearth-ios/issues/10)
Implement all UI-SPEC color and font tokens, bundle approved fonts, and provide a debug swatch
preview. Views must not hard-code spec values.

### 1.5 — App shell and landing · Owner B · agent-safe · [#18](https://github.com/Lada496/hearth-ios/issues/18)
Implement routing and the landing screen against the design tokens and screenshot. Do not add
conversation behavior or device checks in this ticket.

### 1.6 — Device capability gate · Owner B/D · agent-safe, human device check · [#24](https://github.com/Lada496/hearth-ios/issues/24)
Show a friendly unsupported-device screen before model preparation on devices below the ADR-005
memory floor. Do not change deployment target, signing, or entitlements.

### 1.7 — Supporting-screen and error-copy spec · Owner B/Product · agent-safe, human review · [#23](https://github.com/Lada496/hearth-ios/issues/23)
Specify unsupported-device, model-loading/failure, onboarding, settings, and shared recoverable
error states before agents implement screens not already covered by the UI spec.

## Exit criteria

- CI guardrails are active.
- Protocols and mocks build without model files.
- Landing screen is reachable and screenshot-reviewed.
- No production code claims a final language list.
