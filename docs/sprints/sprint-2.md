# Sprint 2 — Real STT (Jul 13–26)

**Goal:** in airplane mode, speak French (or Arabic, Swahili…) into the device and see the
correct transcript with the correct detected language in the UI. Translation stays mocked.

## Tasks

### 2.1 — WhisperKitSTT engine · Owner C · agent-safe, device-test review
Implement `SpeechToText` with WhisperKit `small` (bundled model per ADR-008). Expose
detection confidence. Reject sub-1 s utterances with a typed error → UI shows "Hold the
button and speak". Lazy `prepare()` with progress callback for the loading UX.
**Acceptance:** airplane-mode transcripts for all launch languages from live mic; unit tests
for the error paths (mock the WhisperKit layer).

### 2.2 — Wire STT into ConversationViewModel · Owner A · agent-safe
Replace `MockSTT`. Flow per PRD story 2: record → transcribe → (mock-)translate → message.
Low-confidence detection (< threshold, tune empirically) or unsupported language →
surface "set language manually" affordance.
**Acceptance:** existing ViewModel tests still pass with mocks; new tests for low-confidence path.

### 2.3 — LanguageSheet · Owner B · agent-safe
UI-SPEC §4e. Sets the session resident language; reachable from the center divider; shows
current session language + tier badge in the divider.
**Acceptance:** manual selection overrides detection for subsequent turns.

### 2.4 — Model loading UX · Owner B · agent-safe
First-launch warm-up screen (Whisper load takes seconds): progress indication in Hearth's
visual language, never a blank screen. Subsequent launches: background prepare with the UI
usable for typing.
**Acceptance:** cold-start to usable < 10 s on min device (record actual figure).

### 2.5 — Typed input path · Owner B · agent-safe
Port TextInputBar (UI-SPEC §4d) behavior: worker types English → (mock) translate; resident
types → language detection deferred to translation engine (Sprint 3) — for now route through
manual session language.
**Acceptance:** both input bars functional; collapse/expand animation per spec.

### 2.6 — Internal TestFlight · Owner D · human-owned
First signed build to internal testers (the team).
**Acceptance:** all 4 members run the build on their own iPhones.

## Exit criteria
- [ ] Airplane-mode speech → correct transcript + language flag on device, all launch languages
- [ ] Internal TestFlight build installed by whole team
- [ ] Latency: mic-release → transcript visible measured and recorded per device
