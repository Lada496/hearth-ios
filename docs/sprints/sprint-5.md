# Sprint 5 — Submit & Buffer (Aug 17–28)

**Goal:** app approved and live on the App Store; presentation demo runs the store build.
This sprint is deliberately light — it absorbs beta feedback and one App Review rejection cycle.

## Tasks

### 5.1 — Beta feedback triage · Owner all · human-led
Fix only: crashes, blockers, translation-quality embarrassments in launch languages.
Everything else → v2 parking lot (`ROADMAP.md` §8).

### 5.2 — App Review submission · Owner D · human-owned · **deadline Aug 20**
Review notes must explain: (1) the 180° rotated top pane is intentional two-person UX —
include `docs/design/screenshots/layout.png`; (2) fully offline by design, hence no
server/login for the reviewer; (3) sample test phrases per language so a solo English-speaking
reviewer can validate; (4) binary is large because translation/STT models are bundled
on-device for privacy.
**Rejection playbook:** respond within 24 h; common risks pre-answered — "minimum
functionality" (cite offline AI), "4.2 design spam" (cite custom UX), metadata issues
(have alternates ready).

### 5.3 — Release · Owner D
Manual release on approval (not phased). Verify the store build on every team device,
in airplane mode.

### 5.4 — Presentation prep · Owner all
Demo script: airplane-mode toggle on stage → live two-language conversation → privacy story
(show the "Data Not Collected" label) → honest Tier 1/Tier 2 framing with the Sprint 0
bake-off comparison table vs Google Translate.

### 5.5 — Project retro + v2 grooming · Owner all
File v2 epics from the parking lot; archive learnings in `docs/specs/retro.md`.

## Exit criteria
- [ ] App live on the public App Store
- [ ] Presentation rehearsed with the store build, offline
