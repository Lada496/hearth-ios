# Hearth iOS — Production Roadmap

Companion to `PRD.md` (what) and `adr/ADRs.md` (how). This file covers migration, team,
schedule, risks, and release. Sprint task detail lives in `sprints/`.

## 1. The central design tension (resolved)

iOS has **no system TTS voices for sub-Saharan African languages**; the African languages
with great iOS TTS (Arabic, French, Portuguese) are ones mainstream tools already handle.
Resolution: **tiered language support** (PRD §3) — Tier 1 full voice loop, Tier 2 voice-in /
large-type-out. This keeps the low-resource differentiation AND a voice UX, honestly.

## 2. Migration map (prototype → iOS)

| Prototype component | Fate | iOS counterpart |
|---|---|---|
| `reference/frontend/types.ts` domain model | **Port 1:1** | `Hearth/Domain/` structs & enums |
| `reference/frontend/hooks.ts` `useConversation` state machine | **Port** (the TS is the spec) | `ConversationViewModel` |
| Prompt + output cleaning, `reference/backend/main.py:81-146` | **Port verbatim** | `TinyAyaEngine` prompt builder |
| Dual-rotated split UI (`translate-page.tsx` + CSS) | **Rebuild** per `design/UI-SPEC.md` | `ConversationView` |
| Server Whisper + MediaRecorder plumbing | **Rebuild** | WhisperKit + `AudioSessionManager` |
| Aya via HuggingFace cloud | **Rebuild** | llama.cpp GGUF on-device (ADR-003) |
| Browser SpeechSynthesis TTS | **Rebuild** | `AVSpeechSynthesizer` with tier logic |
| `aggression.py` keyword filter | Optional stretch port (silent skip only) | `SafetyFilter` |
| `SupportPanel.tsx:17-40` language list | **Refactor** | LanguageSheet data |
| FastAPI app, CORS, Twilio, HF tokens, Next proxy routes, `WebSpeechTranslationService`, region picker, sw.js, transcript store/overlay, prompt library | **Removed** | — |

## 3. Team & ownership (4 people × 2–3 h/week — agent-heavy by necessity)

| | A — AI Engines | B — UI | C — Speech & Audio | D — Release & Quality |
|---|---|---|---|---|
| Owns | `Engines/Translation`, model conversion, bake-off, ADR-003 gate | `Features/*`, DesignSystem, accessibility | `Audio/`, `Engines/SpeechToText`, `Engines/TextToSpeech` | repo/CI, TestFlight, App Store Connect, privacy, App Review |
| Success | ≤8 s round-trip on 15 Pro; bake-off table published | stranger completes a conversation uninstructed; UI matches spec | STT survives a phone-call interruption | app live by Aug 28 |

Critical path: Sprint 0 spike (A) → engine protocols frozen → integration → TestFlight (D)
→ App Review. B works fully in parallel against mock engines from day one.
Review rules: 1 human review per PR from the owning vertical; protocol changes need 2.

## 4. Schedule (2-week sprints)

| Sprint | Dates | Theme | Exit criteria |
|---|---|---|---|
| 0 | Jun 15–28 | Spike & decide | ADR-003 GO/fallback decided; languages fixed; repo+CI live; Apple Dev enrolled |
| 1 | Jun 29–Jul 12 | Foundation | mock-powered conversation demo in rotated dual-pane UI; CI green |
| 2 | Jul 13–26 | Real STT | airplane-mode speech → transcript + detected language on device |
| 3 | Jul 27–Aug 9 | Translation + TTS | full conversation loop in ≥3 languages offline; latency measured |
| 4 | Aug 10–16 | Hardening + beta | memory-safe on 6 GB device; TestFlight external beta out Aug 14 |
| 5 | Aug 17–28 | Submit & buffer | **submit Aug 20**; approved + released; presentation uses store build |

## 5. AI-agent usage policy

**Agent-safe (~70%):** domain/ViewModel ports (paste the TS source into the prompt — it's an
executable spec), all SwiftUI views (review vs screenshots), mocks, unit tests, TTS engine,
sheets/onboarding/settings, CI YAML, App Store copy drafts.
**Human-owned (~30%):** Tiny Aya spike + engine core, AVAudioSession lifecycle, memory and
latency profiling, ADRs, signing/provisioning, privacy labels, App Review comms, language
selection.
Anti-drift: `CLAUDE.md` hard rules; networking grep-ban in CI; frozen protocols; closed
dependency list; ≤400-line PRs; spec-before-code in `docs/specs/`.

## 6. Risk register

| Risk | P | Impact | Mitigation |
|---|---|---|---|
| Tiny Aya won't run / too slow on-device | M-H | Critical | Sprint 0 timebox; Apple Translation fallback behind same protocol (ADR-003) |
| Tiny Aya quality < Google on chosen languages | M | High | bake-off *selects* languages where it wins; publish honest comparison |
| Team capacity (2–3 h/wk is optimistic) | H | High | agent-heavy plan; ruthless scope; Sprint 5 is pure buffer; every feature has a ship-without answer |
| App Review rejection (big binary, niche UX, first submission) | M | High | submit Aug 20 = one rejection cycle of buffer; thorough review notes; TestFlight beta review as early warning |
| Jetsam on 6 GB devices | M | Medium | Q4 quant, lazy load, unload Whisper during LLM if needed; Instruments gate Sprint 4; worst case raise floor to 8 GB |
| TTS gap for flagship low-resource langs | certain | Medium | tier design + expectation-setting UI badge |
| Apple enrollment delay | L | High if late | enroll week 1 |
| Aya license ambiguity | L | Medium | verify text in Sprint 0; attribution screen; app is free |

## 7. App Store release checklist (owner: D)

1. **Week 1:** enroll Apple Developer Program ($99/yr, individual account is fine).
2. Xcode automatic signing throughout — no manual provisioning.
3. App Store Connect record early: reserve name "Hearth" (backup: "Hearth Translate"),
   bundle ID `org.hearthapp.hearth` (or similar).
4. Privacy: one-page policy on GitHub Pages (free) stating nothing leaves the device;
   nutrition label "Data Not Collected"; plain-language `NSMicrophoneUsageDescription`.
5. TestFlight: internal from Sprint 2; external beta (mini-review) by Aug 14.
6. Review notes: explain the intentional 180° pane, the offline design, test phrases for a
   solo reviewer, and why the binary is large (bundled on-device models).
7. Accessibility pass before submission (VoiceOver, Dynamic Type, contrast).
8. No analytics/crash SDKs — Xcode Organizer crash reports only (consistent with privacy label).
9. Submit by **Aug 20**; respond to rejections within 24 h; manual release (not phased).

## 8. v2 parking lot (do not build in v1)

Transcript history (encrypted, staff PIN, retention settings — the prototype's
`transcriptStore` + kiro spec are the blueprint), support prompt library (content already
written in `reference/frontend/components/SupportPanel.tsx`), harmful-language handling
done right (context-aware, never blocks disclosures), region model variants, code-switching,
iPad side-by-side layout, additional languages as iOS TTS coverage grows.
