# Hearth iOS — UI-First Production Roadmap

Companion to `PRD.md`, `adr/ADRs.md`, and the task details in `sprints/`.

**Rebaselined:** 2026-07-19 · **Current milestone:** internal August build ·
**Public release:** deliberately unscheduled

## 1. Rebaseline decision

Target-language selection is no longer on the August critical path. The team will build the
product around normalized language codes and injected engine protocols, using Tiny-Aya Earth
without Hearth-specific fine-tuning as the provisional local translator.

This changes validation order, not Hearth's privacy architecture:

- UI, state management, typed translation, audio, and lifecycle work proceed now.
- WhisperKit supplies the resident source-language code for voice turns.
- TTS behavior is based on whether the device has a voice for that code; text is the fallback.
- Translation accuracy and final language support are evaluated later with fluent speakers.
- The August deliverable is an internal build. App Store work resumes after a release decision.

## 2. Guardrails for implementation

1. No networking, analytics, content persistence, or new dependencies.
2. Final-language assumptions may not appear in views or engine protocols.
3. Preview/test language values must be named as fixtures, not `supportedLanguages`.
4. Release code depends on protocols; SwiftUI previews and unit tests use mocks.
5. Tiny-Aya model files remain human-managed and uncommitted in agent work.
6. Each PR stays near 400 changed lines and implements one ticket only.
7. Physical-device, audio-session, model-memory, signing, and distribution work remains
   human-owned even when an agent prepares code or checklists.

## 3. Dependency order

| Gate | Work unlocked | May run in parallel |
|---|---|---|
| Repository guardrails | All product changes | Design-system work after the Xcode target is stable |
| Supporting-screen spec | Device gate, loading, onboarding, settings | Foundation work |
| Language-neutral domain | Engine contracts, message UI | Fixture-only previews |
| Frozen engine contracts + mocks | ViewModel and real engine adapters | Audio and model device investigations |
| Design system | Landing and conversation components | ViewModel work |
| Conversation ViewModel + UI components | Mock-powered integrated UI | Tiny-Aya adapter |
| Tiny-Aya adapter | Typed local conversation | Loading UI and privacy lifecycle |
| Audio manager + WhisperKit + System TTS | Voice conversation | Onboarding and settings |
| Integrated voice loop | Accessibility and final device verification | Documentation cleanup |

Critical path:

`repo → domain → protocols/mocks → ViewModel + conversation UI → Tiny-Aya typed loop → voice loop → August verification`

The final-language decision is outside this graph. The audio/model owners should still start
their physical-device lanes early because agents and simulators cannot complete those gates.

## 4. Schedule

GitHub title prefixes are execution phases: P0 foundation, P1 mock UI, P2 typed local
translation, P3 voice integration, and P4 polish/verification. Within a phase, the explicit
“Depends on” links in each issue take precedence over issue number or assignee.

| Sprint | Dates | Outcome |
|---|---|---|
| 1 | Jul 19–26 | Guardrails, language-neutral foundation, design system, app shell |
| 2 | Jul 27–Aug 4 | Complete conversation UI driven by mocks |
| 3 | Aug 5–13 | Typed two-way conversation through local Tiny-Aya Earth |
| 4 | Aug 14–23 | Voice input, detected language, TTS/text fallback, full loop |
| 5 | Aug 24–31 | Onboarding, settings, accessibility, offline device build |

Tasks may start before their named sprint when their dependencies are complete. Sprint numbers
describe the expected integration order, not a reason to leave an unblocked human lane idle.

## 5. Team ownership

| Role | Owns | August evidence |
|---|---|---|
| A — AI Engines | Protocol review, Tiny-Aya adapter, prompt/cleanup | Local typed translation and device timings |
| B — UI | Design system and `Features/*` | Screenshot comparison and mock-powered flow |
| C — Speech & Audio | Audio session, WhisperKit, system TTS | Physical-device voice loop and interruption notes |
| D — Release & Quality | CI, privacy checks, build verification | Reproducible internal build; no App Store work yet |

## 6. August definition of done

- CI builds and tests without model weights and enforces the networking ban.
- UI matches `landing.png` and `translation.png`, excluding prototype features cut by the spec.
- Mocks exercise every state and error path without loading ML models.
- A human installs the model-enabled build on a supported iPhone and tests in airplane mode.
- Typed and voice turns work in both directions for smoke-test inputs.
- TTS support is discovered at runtime; missing voices fall back to readable large text.
- End-session and background timeout erase in-memory content.
- Results do not claim that any language is production-supported or accurately translated.

## 7. Risks and containment

| Risk | Containment |
|---|---|
| Tiny-Aya is slow or unstable | Keep UI/mock path independent; record device results; do not block UI delivery |
| WhisperKit language detection is weak | Surface detected code for diagnostics; defer marketed support claims |
| No iOS TTS voice exists | Use large text automatically; do not maintain premature tiers |
| Engine protocols drift | Freeze after two-human review; adapters absorb model changes |
| Remaining time is short | Typed local loop is the first integration milestone; voice and polish build on it |
| Agents overreach | Ticket file boundaries, explicit non-goals, mock-only tests, human device gates |

## 8. After August

Humans choose target languages using shelter relevance, model support, Whisper results, TTS
availability, and fluent-speaker evaluation. Only then should the team add a public supported-
language catalog, manual language sheet, fine-tuning plan, quality thresholds, external beta,
App Store assets, and a release date.
