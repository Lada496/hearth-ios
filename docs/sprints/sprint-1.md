# Sprint 1 — Foundation (Jun 29–Jul 12)

**Goal:** a demo where you hold a mic button, "speak", and a **mock** translated message
appears in the rotated dual-pane UI. Everything real comes later; the architecture and the
look land now.

Read first: `../PRD.md`, `../adr/ADRs.md`, `../design/UI-SPEC.md`, `CLAUDE.md`.

## Tasks

### 1.1 — Domain model · Owner A · agent-safe
Port `reference/frontend/types.ts` to `Hearth/Domain/`:
- `Message` (id, speaker, originalText, translatedText, sourceLanguage, targetLanguage, timestamp)
- `Speaker` enum (`.resident` / `.worker` — replaces top/bottom)
- `Language` (code, name, flag, tier) — seed data from
  `reference/frontend/lib/hearth-translation-service.ts:20-42` + `SupportPanel.tsx:17-40`,
  filtered to launch languages
- `SessionPhase` enum mirroring `RecordingState`: `.idle`, `.recording(Speaker)`,
  `.transcribing(Speaker)`, `.translating(Speaker)`
**Acceptance:** compiles, unit tests for Language seed-data integrity (codes unique, tiers set).

### 1.2 — Engine protocols + mocks 🔴 blocks everything · Owner A · agent-safe, all review
`Hearth/Engines/`: async throwing protocols —
```swift
protocol SpeechToText  { func transcribe(_ audio: AudioBuffer) async throws -> (text: String, language: Language?, confidence: Double) ; func prepare() async throws }
protocol TranslationEngine { func translate(_ text: String, from: Language, to: Language) async throws -> String ; func prepare() async throws }
protocol TextToSpeech  { func speak(_ text: String, language: Language) async throws ; var supports: (Language) -> Bool { get } }
```
(Refine signatures in the PR — then FROZEN per ADR rules.) `MockSTT`, `MockTranslator`,
`MockTTS` with configurable delay + failure injection.
**Acceptance:** ViewModels can be built and tested without any model file present.

### 1.3 — ConversationViewModel · Owner B with A · agent-safe
Port the state machine from `reference/frontend/hooks.ts` (`useConversation`, lines 35–254).
Preserve every guard: no start while non-idle, stop ignored on speaker mismatch, empty
transcript no-op, per-step error → user-readable message + reset to idle. Add: session
resident-language state (port the singleton logic from
`reference/frontend/lib/hearth-translation-service.ts:120-145` INTO the ViewModel — no globals).
**Acceptance:** ≥10 unit tests against mocks covering the guards and the happy path both directions.

### 1.4 — DesignSystem · Owner B · agent-safe
`Hearth/DesignSystem/`: all §1–§2 tokens from UI-SPEC as `Color`/`Font` extensions; bundle
Nunito + Playfair Display TTFs (OFL).
**Acceptance:** a swatch debug view rendering every token, screenshot in PR.

### 1.5 — ConversationView skeleton · Owner B · agent-safe (screenshot-reviewed)
Per UI-SPEC §4: rotated top pane, divider, bottom pane, MicButton (§4a) with full
recording/pulse animation, message bubbles (§4b), processing dots (§4c). Wired to the
ViewModel with mock engines.
**Acceptance:** side-by-side vs `screenshots/translation.png` review passes (§7); both mic
buttons drive mock messages; disabled states correct.

### 1.6 — Landing + app shell · Owner B · agent-safe
LandingView per UI-SPEC §3; `HearthApp` + router (landing → conversation); launch-time
device RAM check with friendly unsupported-device screen (ADR-005).
**Acceptance:** matches `screenshots/landing.png`; fade transition.

### 1.7 — AudioSessionManager · Owner C · **human-owned**
`AVAudioSession` + `AVAudioEngine`: hold-to-record producing 16 kHz mono PCM buffers;
category switching record↔playback; phone-call interruption ends recording cleanly;
mic-permission flow with Settings deep-link on denial.
**Acceptance:** device-tested (note in PR): record → buffer count sane; interruption test
performed; permission-denied path screenshotted.

## Exit criteria
- [ ] Mock-powered conversation demo on a physical device, both directions
- [ ] UI passes screenshot comparison
- [ ] CI green; all merges via reviewed PRs
