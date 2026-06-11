# Sprint 4 — Hardening + Beta (Aug 10–16, one week)

**Goal:** external TestFlight beta in real hands by **Aug 14**; the app is App-Store-grade.

## Tasks

### 4.1 — Onboarding · Owner B · agent-safe
≤3 icon-driven screens (hold-to-talk, pass the phone, "nothing leaves this device"),
shown once (UserDefaults flag). Minimal text — users may not read English.
**Acceptance:** a first-time user starts a conversation with no help.

### 4.2 — Accessibility pass · Owner B · agent-assisted + manual VoiceOver test
VoiceOver labels on every control (mind the rotated pane!), Dynamic Type on worker side,
contrast check (tokens are already AAA — verify nothing regressed), ≥44 pt targets.
**Acceptance:** full conversation completed with VoiceOver; checklist in PR.

### 4.3 — Edge-case sweep · Owner C · human-led
Phone call mid-recording; Bluetooth/wired route changes; Control-Center mic kill; backgrounding
mid-translation; rapid double-press; storage-full launch; locale set to RTL language.
**Acceptance:** each scenario handled or consciously documented; no crashes.

### 4.4 — App Store assets · Owner D · agent-safe drafts, human final
Icon (from `docs/design/screenshots/hearth-logo.png` mark), screenshots (6.7" + 6.1"),
description (states offline design + large download + device requirements), keywords,
privacy policy page (GitHub Pages), privacy nutrition label "Data Not Collected".
**Acceptance:** App Store Connect listing complete in draft.

### 4.5 — External TestFlight beta · Owner D · human-owned
Submit for Beta App Review; distribute to external testers — ideally a Bloom Group contact
+ friends with target-language skills.
**Acceptance:** beta live by Aug 14; feedback channel (GitHub issues template) ready.

### 4.6 — STRETCH (only if 4.1–4.5 done): SafetyFilter · agent-safe
Port `reference/backend/aggression.py` keyword list to a Swift regex check on the English
text. On hit: silently skip translation, show a neutral "couldn't translate" state.
**No alerts, no SMS, no blocking banner** (team decision 2026-06-10). Review the keyword
list first — remove entries likely to block disclosures (e.g. bare "die", "get out").

## Exit criteria
- [ ] External beta in non-team hands by Aug 14
- [ ] Zero known crashes; memory gate from 3.5 still passing
- [ ] Listing assets ready for submission
