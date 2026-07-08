# Hearth iOS — Product Requirements Document (v1 MVP)

**Status:** Approved 2026-06-10 · **Ship target:** App Store, end of August 2026

## 1. Product

Hearth is a privacy-first, **fully offline** voice translation app that lets a shelter worker
and a resident who share no common language hold a real two-way conversation on one iPhone,
passed or laid flat between them. No accounts. No data collection. No network — ever.

Built with and for The Bloom Group (low-barrier women's shelter, Vancouver). Differentiator:
on-device Tiny Aya (Cohere) translation tuned for low-resource languages that mainstream
tools handle poorly.

## 2. Users

| Persona | Side of screen | Assumptions |
|---|---|---|
| **Worker** (shelter staff) | Bottom (normal orientation) | Speaks English, owns the phone, medium digital literacy |
| **Resident** | Top (rotated 180°) | Any supported language; low digital literacy; possibly in crisis; must need zero instruction |

## 3. Language support (tiered)

Final list confirmed by the Sprint 0 bake-off. Candidates:

| Tier | Languages | Experience |
|---|---|---|
| 1 — full voice loop | Arabic, Mandarin, Japanese (+ English) | speak → translate → **spoken aloud** |
| 2 — voice in, text out | 2–3 of: Swahili, Hausa, Amharic | resident speaks; reply is **displayed large-type**, not spoken (iOS has no TTS voices for these) |

Selection criteria: Tiny Aya quality ≥ mainstream tools on FLORES samples; Whisper STT support;
relevance to shelter populations.

## 4. v1 user stories (in scope)

1. **Dual-pane conversation.** Top half rotated 180° for the resident, bottom for the worker —
   replicating the prototype (`docs/design/screenshots/translation.png`).
2. **Resident speaks:** hold top mic → on-device Whisper transcribes + detects language →
   Tiny Aya translates to English → both panes update.
3. **Worker responds:** hold bottom mic or type → English translated to the resident's session
   language → Tier 1: auto-spoken via TTS; Tier 2: large-type display.
4. **Tap any bubble to replay** its audio (Tier 1) .
5. **Manual language fallback:** if detection confidence is low or wrong, worker opens a
   language sheet (flag + name list) and sets the resident's language for the session.
6. **End session:** one button wipes the conversation from memory. Backgrounding >5 min also wipes.
7. **Onboarding:** ≤3 icon-driven screens (hold-to-talk, pass the phone, privacy promise),
   shown once.
8. **Settings:** About, open-source/model attributions (Aya CC-BY-NC, WhisperKit), privacy
   statement, supported-language list with tier badges.

## 5. Explicitly OUT of scope for v1

- Transcript save/history (prototype's `transcriptStore` feature) — cut
- Support prompt library — cut (stretch for v2)
- Harmful-language detection — cut; *optional stretch:* silently skip translation on keyword
  hit (port of `reference/backend/aggression.py`), with **no alert, no SMS, no blocking message**
- Region/model picker (Auto/Earth/Fire/Water) — ship ONE Tiny Aya model
- Accounts, analytics, crash SDKs, notifications, any network feature

## 6. Non-functional requirements

| Requirement | Target |
|---|---|
| Offline | 100% of functionality in airplane mode, from first launch |
| Privacy label | "Data Not Collected" — enforced by CI ban on networking APIs |
| Latency (release mic → translation visible, 10 s utterance) | ≤ 8 s on iPhone 15 Pro · ≤ 15 s on minimum device |
| App size | ≤ 3.5 GB (App Store limit 4 GB); models bundled |
| Devices | iOS 17.0+, ≥6 GB RAM: iPhone 12 Pro/Pro Max, 13 Pro/Pro Max, 14 and all newer. 4 GB devices (11, 12, 12 mini, 13, 13 mini, SE) unsupported — graceful explanation screen, no crash |
| Memory | No jetsam kill during a 10-minute conversation on a 6 GB device |
| Accessibility | VoiceOver labels everywhere; Dynamic Type on worker pane; WCAG AA contrast (prototype already achieves AAA — keep it); ≥44 pt touch targets |
| Cost | $0 recurring beyond the $99/yr Apple Developer Program |

## 7. Success criteria (presentation, end of August)

- App is live on the public App Store.
- A first-time user pair completes a 5-turn conversation with zero verbal instruction.
- Demo runs in airplane mode on stage.
