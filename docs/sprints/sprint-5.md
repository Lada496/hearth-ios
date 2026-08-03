# Sprint 5 — Polish and August Build (Aug 24–31)

**Goal:** produce a stable, private, internally installable build. App Store submission and
external beta are not in this sprint.

## Tasks

### 5.1 — Onboarding · Owner B · agent-safe · [#29](https://github.com/Lada496/hearth-ios/issues/29)
Add at most three icon-led pages for hold-to-talk, pass-the-phone, and offline privacy. Store only
the onboarding-seen flag.

### 5.2 — Settings and attribution · Owner B/D · agent-safe · [#30](https://github.com/Lada496/hearth-ios/issues/30)
Add privacy, model/library/font attributions, and device information. Do not show a supported language list or tier badges before the language decision.

### 5.3 — Accessibility and visual regression · Owner B · agent-assisted · [#35](https://github.com/Lada496/hearth-ios/issues/35)
Audit VoiceOver on both orientations, worker-side Dynamic Type, contrast, touch targets, reduced
motion, and screenshots. Include a final non-Latin script pass (Arabic, Ethiopic, CJK,
Devanagari, etc.) confirming font fallback actually renders correctly on-device, not just in
simulator fixtures. A human completes the device/VoiceOver pass.

### 5.4 — Offline device verification and August build · Owner C/D · human-owned · [#36](https://github.com/Lada496/hearth-ios/issues/36)
Run build/tests, networking scan, airplane-mode typed/voice smoke test, interruption test, and a
ten-minute memory run on a supported iPhone. Record translation outputs without scoring accuracy.

### 5.5 — Model-enrichment backlog handoff · Owner all · human-only · [#37](https://github.com/Lada496/hearth-ios/issues/37)
Confirm the entry evidence for [`../backlog/model-enrichment.md`](../backlog/model-enrichment.md):
target-language decision inputs, evaluator access, data/license ownership, named test devices,
and release ownership. Do not select languages or begin enrichment work in this sprint.

## Exit criteria

- Internal August build installs and runs offline on a supported iPhone.
- Core typed/voice flows and privacy wipes pass.
- Deferred language, enrichment, and release work has a gated owner and dependency order and
  cannot be mistaken for completed work.
