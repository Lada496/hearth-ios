# Sprint 2 — Mock-Powered Conversation UI (Jul 27–Aug 4)

**Goal:** complete the signature UI and interaction state without real audio or model files.
Read `../design/UI-SPEC.md` and compare every UI PR with the approved screenshots.

## Tasks

### 2.1 — Dual-pane conversation shell · Owner B · agent-safe · [#19](https://github.com/Lada496/hearth-ios/issues/19)
Build equal resident/worker panes, rotate the entire resident pane, add the glass divider, and
use fixture content in previews only.

### 2.2 — Message presentation · Owner B · agent-safe · [#25](https://github.com/Lada496/hearth-ios/issues/25)
Implement latest-message display, message bubbles, entry motion, and speech/text capability
indicators. Do not call a speech engine from the view. Verify bubbles render non-Latin
scripts (Arabic, Ethiopic, CJK, Devanagari, etc.) correctly via iOS's automatic font-fallback
cascade (UI-SPEC.md §2) — test with more than Latin-script fixture text before calling this
done.

### 2.3 — Conversation controls · Owner B · agent-safe · [#26](https://github.com/Lada496/hearth-ios/issues/26)
Implement hold-to-record mic visuals, disabled states, pulse rings, and processing dots as
reusable views. Gesture callbacks are injected; no audio work is in scope.

### 2.4 — Text input bar · Owner B · agent-safe · [#27](https://github.com/Lada496/hearth-ios/issues/27)
Implement collapsed/expanded input, multiline limit, send/disabled behavior, and rotated-pane
keyboard handling. It emits text only.

### 2.5 — Conversation ViewModel · Owner A/B · agent-safe · [#9](https://github.com/Lada496/hearth-ios/issues/9)
Port the reference state machine against mocks. Preserve concurrency guards, empty-input
behavior, readable errors, session language metadata, and idle recovery with unit tests.

### 2.6 — Bind the conversation UI to mocks · Owner B · agent-safe · [#31](https://github.com/Lada496/hearth-ios/issues/31)
Connect the completed components to the ViewModel. Both typed and simulated mic actions must
exercise happy, processing, disabled, and error states.

## Exit criteria

- A complete two-person conversation can be demonstrated with mocks.
- Views contain no engine implementations or final-language branches.
- Screenshot comparison passes for landing and conversation.
