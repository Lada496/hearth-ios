# Sprint 3 — Translation + TTS: the full loop (Jul 27–Aug 9)

**Goal:** complete conversation loop, both directions, in ≥3 languages, in airplane mode,
within PRD latency targets. This is the make-or-break sprint.

## Tasks

### 3.1 — TinyAyaEngine 🔴 critical path · Owner A · human-owned core, agent-safe glue
Implement `TranslationEngine` over llama.cpp with the Sprint-0 GGUF. Port prompt + output
cleaning **verbatim** from `reference/backend/main.py:81-146` (prefix-strip list and
`" or "`-split included), then tune only with evidence. Lazy load with progress; explicit
`unload()` for memory pressure handling.
**Acceptance:** en↔ar/fr/pt (+ Tier 2 langs) within PRD latency on min device; output-cleaning
unit tests using the prefix list as fixtures; memory figures recorded.
**If Sprint 0 was NO-GO:** implement `AppleTranslationEngine` instead (same protocol),
Tier 1 languages only; PRD language table updated.

### 3.2 — SystemTTS engine · Owner C · agent-safe
`AVSpeechSynthesizer` implementation: best-quality installed voice per language
(prefer `.enhanced`/`.premium`), rate ~0.9× default per prototype. Tier 2 → `supports()`
false → ViewModel routes to large-type display instead. Skip the prototype's female-voice
name list; select by quality.
**Acceptance:** Tier 1 messages auto-speak; replay via bubble play button; audio session
hands off record↔playback cleanly (with C's AudioSessionManager).

### 3.3 — Tier 2 large-type display · Owner B · agent-safe
When TTS unsupported: render the translation as a prominent large-type card (UI-SPEC center
display style, 24 pt+) with a small "text reply" badge instead of a play button.
**Acceptance:** Swahili conversation is fully usable without audio output.

### 3.4 — End-to-end wiring + session lifecycle · Owner A · agent-safe
Replace last mocks. End-session wipe; >5 min background wipe (ADR-006); auto-set session
language from first resident utterance (port logic from
`reference/frontend/lib/hearth-translation-service.ts:301-371`).
**Acceptance:** full-loop UI test (mock engines) green in CI; manual device run both directions.

### 3.5 — Memory guard · Owner A+C · human-owned
Decide and implement coexistence strategy for Whisper + LLM on 6 GB devices (keep both
loaded vs unload Whisper during generation). Instruments run documented.
**Acceptance:** 10-minute conversation on min device, no jetsam; figures in `docs/specs/memory.md`.

### 3.6 — Settings screen · Owner B/D · agent-safe
About, attributions (Aya CC-BY-NC, WhisperKit MIT, llama.cpp MIT, Nunito/Playfair OFL),
privacy statement, supported languages with tiers, device info.
**Acceptance:** every bundled third-party artifact attributed.

## Exit criteria
- [ ] Airplane-mode full conversation in ≥3 languages on two device generations
- [ ] Latency within PRD §6 targets (record table)
- [ ] No mock engines left in the release build
