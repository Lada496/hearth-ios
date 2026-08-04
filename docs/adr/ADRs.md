# Architecture Decision Records

Status legend: ✅ accepted · 🔬 accepted pending Sprint 0 validation · Changing any ADR
requires a PR approved by two team members.

---

## ADR-001 ✅ — No backend: the app is 100% on-device

**Context.** The original prototype used a FastAPI server only to host Whisper and proxy to
HuggingFace's cloud Inference API. Hard requirements: zero connectivity
operation, zero recurring cost, privacy-first for a vulnerable population.
**Decision.** Delete the backend entirely. All STT, translation, and TTS run on the iPhone.
**Consequences.** No auth/CORS/hosting/ops; App Review simpler; privacy label "Data Not
Collected" is provably true (CI bans networking APIs). Cost: all models must fit the per-app
memory ceiling (~3 GB on 6 GB-RAM devices).
**Rejected.** Self-hosted server (cost, connectivity); hybrid (complexity, weakens privacy claim).

## ADR-002 ✅ — STT: WhisperKit with multilingual `small` model

**Context.** The prototype used server-side `openai-whisper` `small` for transcript
and language detection. Hearth needs broad multilingual coverage even though the final launch-
language list is deferred; Apple's `SFSpeechRecognizer` / iOS 26 `SpeechAnalyzer` do not cover
several languages under consideration.
**Decision.** [WhisperKit](https://github.com/argmaxinc/WhisperKit) (MIT), CoreML, `small`
multilingual (~500 MB), bundled. Language detection replaces the `/process` endpoint.
**Consequences.** ANE-accelerated, maintained Swift API. `small` is the accuracy floor for
low-resource languages; `base` is the fallback if memory profiling forces it (quality loss —
measure first).
**Rejected.** Raw whisper.cpp (more glue, no CoreML/ANE path); Apple Speech (language coverage).

## ADR-003 🔬 — Translation: one Tiny-Aya Earth model, Q4 GGUF, via llama.cpp

**Context.** Prototype called 4 `CohereLabs/tiny-aya-*` variants via HF cloud. On-device is
mandatory. Unknowns (NOT resolvable from the prototype repo): parameter count, GGUF
convertibility, on-device tokens/sec, exact license text. Apple Translation worked in Airplane
Mode only after language assets were downloaded/prepared; fresh Airplane Mode without downloaded
assets failed, so it does not satisfy the offline-from-first-launch goal as the planned v1 path.
**Decision.** Use **only `tiny-aya-earth`** as the provisional translation engine, 4-bit
quantized GGUF, via the llama.cpp Swift bindings. Development fixtures are useful for integration,
but final language support is not an engine-implementation prerequisite. Implement the prompt
and output-cleaning contract in `docs/specs/aya-spike.md` (the prefix-strip list encodes real
model behavior observed during the prototype spike).
Drop the earth/fire/water/global picker.
**August integration gate:** Tiny-Aya Earth runs on a supported iPhone, stays responsive, and
fits the app-size/memory budget. The license must permit Hearth's free non-commercial use.
Translation accuracy is explicitly not an August gate and remains unvalidated until the team
chooses target languages and recruits fluent speakers.
**Fallback if gate fails:** Apple Translation framework (iOS 17.4+, on-device, free) for
languages with prepared Apple assets only. Low-resource differentiation would be lost. Both engines
implement the same `TranslationEngine` protocol, so the swap is a one-line DI change.
**License note.** Aya models are CC-BY-NC. Hearth is free and non-commercial — compliant —
but attribution is required in Settings → About.

## ADR-004 ✅ — SwiftUI + MVVM, single app target, no architecture frameworks

**Context.** 4 students new to iOS, ~130 total person-hours, ~6 screens, agent-heavy workflow.
**Decision.** SwiftUI; MVVM with plain `@Observable` view models; engine access through
protocols injected via `init`; `async/await` only.
**Why.** The prototype migration established a direct conceptual map from conversation state to
`ConversationViewModel`, domain structs, and `SessionPhase`. Mocks make all UI work
parallelizable and testable without models loaded.
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
