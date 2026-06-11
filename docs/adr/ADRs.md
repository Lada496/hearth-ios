# Architecture Decision Records

Status legend: ✅ accepted · 🔬 accepted pending Sprint 0 validation · Changing any ADR
requires a PR approved by two team members.

---

## ADR-001 ✅ — No backend: the app is 100% on-device

**Context.** The prototype's FastAPI server (`reference/backend/main.py`) exists only to host
Whisper and proxy to HuggingFace's cloud Inference API. Hard requirements: zero connectivity
operation, zero recurring cost, privacy-first for a vulnerable population.
**Decision.** Delete the backend entirely. All STT, translation, and TTS run on the iPhone.
**Consequences.** No auth/CORS/hosting/ops; App Review simpler; privacy label "Data Not
Collected" is provably true (CI bans networking APIs). Cost: all models must fit the per-app
memory ceiling (~3 GB on 6 GB-RAM devices).
**Rejected.** Self-hosted server (cost, connectivity); hybrid (complexity, weakens privacy claim).

## ADR-002 ✅ — STT: WhisperKit with multilingual `small` model

**Context.** Prototype used server-side `openai-whisper` `small` (`main.py:50`) for transcript
+ language detection. Tier 2 languages (Swahili, Somali, Amharic, Hausa) need STT; Apple's
`SFSpeechRecognizer` / iOS 26 `SpeechAnalyzer` don't support them.
**Decision.** [WhisperKit](https://github.com/argmaxinc/WhisperKit) (MIT), CoreML, `small`
multilingual (~500 MB), bundled. Language detection replaces the `/process` endpoint.
**Consequences.** ANE-accelerated, maintained Swift API. `small` is the accuracy floor for
low-resource languages; `base` is the fallback if memory profiling forces it (quality loss —
measure first).
**Rejected.** Raw whisper.cpp (more glue, no CoreML/ANE path); Apple Speech (language coverage).

## ADR-003 🔬 — Translation: one Tiny Aya model, Q4 GGUF, via llama.cpp — with a named fallback

**Context.** Prototype called 4 `CohereLabs/tiny-aya-*` variants via HF cloud. On-device is
mandatory. Unknowns (NOT resolvable from the prototype repo): parameter count, GGUF
convertibility, on-device tokens/sec, exact license text.
**Decision.** Ship **only `tiny-aya-global`**, 4-bit quantized GGUF, via the llama.cpp Swift
bindings. Port the prompt + output-cleaning logic verbatim from `reference/backend/main.py:81-146`
(the prefix-strip list encodes real model behavior). Drop the earth/fire/water picker.
**Validation gate (Sprint 0, decide by Jul 5):** runs on a 6 GB iPhone, ≥ target latency,
quality ≥ Google Translate on ≥3 candidate languages, license permits free-app distribution.
**Fallback if gate fails:** Apple Translation framework (iOS 17.4+, on-device, free) for
Tier 1 languages only. Ship date protected; low-resource differentiation lost. Both engines
implement the same `TranslationEngine` protocol, so the swap is a one-line DI change.
**License note.** Aya models are CC-BY-NC. Hearth is free and non-commercial — compliant —
but attribution is required in Settings → About. Verify exact Tiny Aya terms in Sprint 0.

## ADR-004 ✅ — SwiftUI + MVVM, single app target, no architecture frameworks

**Context.** 4 students new to iOS, ~130 total person-hours, ~6 screens, agent-heavy workflow.
**Decision.** SwiftUI; MVVM with plain `@Observable` view models; engine access through
protocols injected via `init`; `async/await` only.
**Why.** Closest conceptual map to the React code being ported (`useConversation` →
`ConversationViewModel`; `types.ts` → Domain structs; `RecordingState` union → Swift enum).
Mocks make all UI work parallelizable and testable without models loaded.
**Rejected.** TCA / Clean Architecture layering (learning + ceremony cost dwarfs benefit at
this scale); UIKit (steeper curve, no benefit for custom-drawn UI).

## ADR-005 ✅ — Minimum device: 6 GB RAM, iOS 17.0+

**Decision.** Supported: iPhone 12 Pro/Pro Max, 13 Pro/Pro Max, 14/14 Plus and ALL newer.
Recommended (marketing): iPhone 15 Pro+. Unsupported (4 GB RAM — app memory ceiling ~2 GB
cannot hold Whisper + LLM): iPhone 11, 12, 12 mini, 13, 13 mini, SE all gens.
**Enforcement.** Launch-time RAM check with a friendly explanation screen (App Review
requires no-crash on any installable device); App Store description states requirements.

## ADR-006 ✅ — No persistence of conversation content

**Decision.** Messages exist in memory only; wiped on end-session and on >5 min background.
`UserDefaults` only for onboarding-seen + last manual language. No SwiftData/CoreData/Keychain.
**Why.** Matches privacy promise; transcript history is cut from v1; deletes an entire
workstream. v2 transcript feature would add encrypted storage behind a staff PIN.

## ADR-007 ✅ — SPM only; closed dependency allowlist

**Decision.** Allowed packages: **WhisperKit**, **llama.cpp Swift package**. Nothing else —
no analytics, no crash SDKs (Xcode Organizer suffices), no UI kits. Agents may not add
dependencies; humans may, only by amending this ADR in a reviewed PR.
**Why.** Primary defense against agent-introduced dependency sprawl and supply-chain surface.

## ADR-008 ✅ — Models ship inside the app bundle

**Decision.** whisper-small CoreML + tiny-aya Q4 GGUF live in `Hearth/Resources/Models/`,
inside the app binary. Total app ≤ 3.5 GB.
**Why.** Apple hosts the download for free (zero recurring cost); app is fully functional
offline from first launch (hard requirement). Cost: large initial Wi-Fi download — acceptable;
state it in the App Store description.
**Rejected.** First-launch download from HuggingFace CDN (violates offline-from-install;
fragile in App Review; third-party bandwidth terms can change).
