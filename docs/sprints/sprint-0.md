# Sprint 0 — Spike & Decide (Jun 15–28)

**Goal:** kill the unknowns. No product code; everything here is throwaway-or-keep research
plus repo/tooling setup. **The sprint exists to make the ADR-003 GO/NO-GO decision by Jul 5.**

Read first: `../PRD.md`, `../adr/ADRs.md`.

## Tasks

### 0.1 — Tiny Aya on-device spike 🔴 critical path · Owner A · human-led, agent-assisted
Validate ADR-003. Steps:
1. Determine `CohereLabs/tiny-aya-global` parameter count and architecture; verify exact
   license text permits redistribution inside a free app (record findings).
2. Convert to GGUF (llama.cpp `convert_hf_to_gguf.py`); quantize Q4_K_M.
3. Run in a minimal iOS test app via the llama.cpp Swift package on a real iPhone
   (best available + oldest team device). Record tokens/sec, peak memory, model load time.
4. Quality bake-off: ~30 FLORES-200 sentences for each candidate language in **PRD §3
   (current Tier 1 + Tier 2 lists)** — Tiny Aya vs Google Translate, blind-judged by the
   team. Port the prompt from `reference/backend/main.py:81-114` for this.
**Acceptance:** `docs/specs/aya-spike.md` contains: license verdict, perf table per device,
quality table per language, GO/NO-GO recommendation with the fallback plan if NO-GO.

### 0.2 — WhisperKit spike · Owner C · agent-assisted
Minimal app: hold button → record → WhisperKit `small` transcribe + language detect, in
airplane mode. Test clips: English + the PRD §3 candidate languages (record teammates /
use Common Voice samples).
**Acceptance:** transcripts + detected codes logged; `small` vs `base` accuracy note;
load-time and memory figures in `docs/specs/whisper-spike.md`.

### 0.3 — TTS voice audit · Owner C · agent-safe
On a real device (iOS 17 and latest), dump `AVSpeechSynthesisVoice.speechVoices()`; check
downloadable voices in Settings → Accessibility → Spoken Content for every candidate
language.
**Acceptance:** table in `docs/specs/tts-audit.md` → confirms final Tier 1 / Tier 2 split;
PRD §3 updated.

### 0.4 — Repo & CI bootstrap · Owner D · agent-safe (human reviews CLAUDE.md)
Xcode project (iOS 17 target, SwiftUI lifecycle), SwiftLint (no-force-unwrap rule), GitHub
Actions: build + test on PR (macOS runner), plus a grep step failing the build on
`URLSession|Network.framework|NWConnection`. Branch protection on `main` (1 review + green CI).
**Acceptance:** a trivial PR shows CI pass/fail correctly; repo settings screenshot in PR.

### 0.5 — Apple Developer Program enrollment · Owner D · human-only
Enroll ($99). Create App Store Connect app record; reserve the name "Hearth"
(backup "Hearth Translate").
**Acceptance:** TestFlight-capable account; bundle ID registered.

### 0.6 — Design study · Owner B · agent-assisted
Read `../design/UI-SPEC.md` against the prototype screenshots; flag gaps/ambiguities as
issues. Start the SwiftUI learning path (Apple "Develop in Swift" essentials).
**Acceptance:** UI-SPEC issues filed or "no gaps" sign-off; B can build a static mock of the
landing screen.

## Exit criteria
- [ ] ADR-003 decided (GO with Tiny Aya / fallback to Apple Translation) — recorded in ADRs.md
- [ ] Launch languages fixed in PRD §3 (3–5 + English, tiers assigned)
- [ ] Device floor confirmed on real hardware (ADR-005 amended if needed)
- [ ] CI green on `main`; CLAUDE.md live
- [ ] Apple Developer enrollment complete

## Risks
Spike drags → **timebox: decide on day 10 with whatever data exists.** A NO-GO is a valid,
planned outcome — the fallback engine ships behind the same protocol.
