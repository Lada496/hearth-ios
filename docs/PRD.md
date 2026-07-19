# Hearth iOS — Product Requirements Document (August Build)

**Status:** Rebaselined 2026-07-19 · **Build target:** installable internal build by
2026-08-31 · **Public release date:** TBD

## 1. Product

Hearth is a privacy-first, fully offline voice translation app for a shelter worker and a
resident using one iPhone face to face. No accounts, data collection, persistence of
conversation content, or network access.

The August build proves the complete product shape and on-device integration. It uses the
standard Tiny-Aya Earth Q4 model as a provisional translator. The team is not fine-tuning the
model or claiming that its translations are accurate enough for any launch language yet.

## 2. Users

| Persona | Side of screen | Assumptions |
|---|---|---|
| Worker | Bottom, normal orientation | Speaks English and owns the phone |
| Resident | Top, rotated 180° | Language is detected from speech; must need little instruction |

## 3. Language behavior during development

The final launch-language list is deliberately deferred and does not block implementation.

- English is the worker language for the August build.
- WhisperKit returns a resident-language code with each transcription. The session stores that
  code and passes it to the translator; views must not contain language-specific branches.
- Tiny-Aya Earth translates between English and the detected resident language when it can.
- `AVSpeechSynthesizer` speaks a translation only when iOS exposes a matching voice. Otherwise
  the same translation is shown in large type. No permanent Tier 1/Tier 2 table is encoded yet.
- Languages used in previews, mocks, unit tests, and smoke tests are test fixtures only. They
  are not launch commitments or evidence of translation quality.
- Before the voice pipeline is integrated, debug/test composition may inject one resident-
  language fixture to exercise typed translation. The production UI must not present that
  fixture as a supported-language choice.
- A public supported-language list, manual language picker, model tuning, fluent-speaker
  validation, and language-specific quality thresholds wait for the target-language decision.

Language detection removes the final list from the main UI and data-flow dependency, but it
does not remove language metadata: translation direction, TTS voice lookup, diagnostics, and a
future manual override still require a normalized language code.

## 4. August build scope

1. Landing screen and app shell matching `docs/design/UI-SPEC.md`.
2. Dual-pane conversation screen with the resident pane rotated 180°.
3. Typed turns through injected mock engines, then Tiny-Aya Earth locally. A worker reply
   requires resident-language metadata from prior detection; debug builds may inject a fixture.
4. Hold-to-record voice input through `AudioSessionManager` and WhisperKit language detection.
5. Runtime output choice: system TTS when a matching voice exists, large text otherwise.
6. Loading, processing, empty-input, permission, and recoverable-error states.
7. Tap-to-replay when speech is available.
8. End-session and five-minute-background wipes of all conversation content.
9. Short onboarding, privacy/about/settings content, and the required accessibility pass.

## 5. Deferred until after the August build

- Final target languages and any marketed supported-language list
- Translation-quality acceptance, model fine-tuning, and comparative bake-offs
- Language-specific TTS tiers and the manual language sheet
- App Store submission, external TestFlight, listing assets, and release date
- Transcript history, support prompts, harmful-language detection, accounts, analytics,
  notifications, and all networking

## 6. Non-functional requirements

| Requirement | August target |
|---|---|
| Offline | All runtime features work in airplane mode from first launch |
| Privacy | Data Not Collected; CI rejects networking APIs; content remains in memory only |
| Translation | Tiny-Aya Earth runs locally; accuracy is observed but is not an August gate |
| Performance | Record load time and end-to-end latency; no UI watchdog stall |
| App size | At most 3.5 GB with human-managed bundled model artifacts |
| Devices | iOS 17+, at least 6 GB RAM; unsupported devices receive an explanation, not a crash |
| Memory | No crash or jetsam during a ten-minute smoke conversation on a supported device |
| Accessibility | VoiceOver labels, worker-side Dynamic Type, AA contrast, 44 pt targets |

## 7. August success criteria

- A clean build and unit-test run succeeds without model files present.
- A supported physical iPhone runs a five-turn typed and voice smoke conversation in airplane
  mode using locally bundled engines.
- The landing and conversation screens pass comparison against the approved screenshots.
- Ending or timing out a session leaves no conversation content behind.
- Known translation mistakes are recorded as validation evidence, not silently converted into
  launch-language claims.
