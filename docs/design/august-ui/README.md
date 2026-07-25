# August UI reference pack

This directory is the repository-backed visual source of truth for the August internal build.
It lets contributors review and implement the planned UI without requiring access to the Figma
draft.

Every screen is labelled with its provenance:

- **PROTOTYPE / RETAINED** — present in the original frontend prototype and retained for August.
- **NEW GAP / AUGUST** — added to complete an August requirement or recovery path missing from
  the prototype.
- **DEFERRED / NOT AUGUST** — a prototype concept that must not be treated as an August
  implementation requirement.

The Spanish and English text in conversation screens is fixture content only. It is not a
supported-language promise or a launch-language decision.

## Complete views

- [`catalog-all-ui.png`](catalog-all-ui.png) — all retained and new August screens in one board.
- [`flow-01-first-launch.png`](flow-01-first-launch.png) — first launch, capability gate, model
  preparation, onboarding, and entry.
- [`flow-02-conversation-turn.png`](flow-02-conversation-turn.png) — typed and voice turn states.
- [`flow-03-recovery-privacy.png`](flow-03-recovery-privacy.png) — recoverable failures, explicit
  end-session, and background privacy clearing.
- [`deferred-prototype-reference.png`](deferred-prototype-reference.png) — prototype concepts that
  remain outside the August build.

## Ticket map

| Issue | Use these files |
| --- | --- |
| [#9 Conversation ViewModel](https://github.com/Lada496/hearth-ios/issues/9) | `flow-02-conversation-turn.png`, `flow-03-recovery-privacy.png` |
| [#10 Design system](https://github.com/Lada496/hearth-ios/issues/10) | `catalog-all-ui.png` |
| [#13 Audio session](https://github.com/Lada496/hearth-ios/issues/13) | `prototype-03-recording.png`, `gap-08-microphone-permission.png` |
| [#18 App shell and landing](https://github.com/Lada496/hearth-ios/issues/18) | `prototype-01-landing.png`, `flow-01-first-launch.png` |
| [#19 Conversation shell](https://github.com/Lada496/hearth-ios/issues/19) | `prototype-02-conversation-empty.png`, `prototype-05-latest-message.png` |
| [#21 Session privacy lifecycle](https://github.com/Lada496/hearth-ios/issues/21) | `gap-11-end-session.png`, `gap-12-session-expired.png`, `flow-03-recovery-privacy.png` |
| [#22 WhisperKit adapter](https://github.com/Lada496/hearth-ios/issues/22) | `prototype-03-recording.png`, `prototype-04-processing.png`, `gap-09-language-not-detected.png` |
| [#23 Supporting-screen spec](https://github.com/Lada496/hearth-ios/issues/23) | `catalog-all-ui.png`, all `gap-*.png`, all `flow-*.png` |
| [#24 Device capability gate](https://github.com/Lada496/hearth-ios/issues/24) | `gap-04-unsupported-device.png`, `flow-01-first-launch.png` |
| [#25 Message presentation](https://github.com/Lada496/hearth-ios/issues/25) | `prototype-05-latest-message.png`, `gap-10-text-only.png` |
| [#26 Conversation controls](https://github.com/Lada496/hearth-ios/issues/26) | `prototype-03-recording.png`, `prototype-04-processing.png` |
| [#27 Text input bar](https://github.com/Lada496/hearth-ios/issues/27) | `prototype-06-text-input.png` |
| [#28 Model loading and failure UX](https://github.com/Lada496/hearth-ios/issues/28) | `gap-05-model-preparing.png`, `gap-06-model-failure.png`, `gap-07-model-unavailable.png` |
| [#29 Onboarding](https://github.com/Lada496/hearth-ios/issues/29) | `gap-01-onboarding-hold.png`, `gap-02-onboarding-pass.png`, `gap-03-onboarding-privacy.png`, `flow-01-first-launch.png` |
| [#30 Settings and attribution](https://github.com/Lada496/hearth-ios/issues/30) | `gap-13-settings.png`, `gap-14-privacy.png`, `gap-15-about-attribution.png` |
| [#31 Bind conversation UI](https://github.com/Lada496/hearth-ios/issues/31) | retained `prototype-02` through `prototype-07`, `flow-02-conversation-turn.png` |
| [#32 TTS and text fallback](https://github.com/Lada496/hearth-ios/issues/32) | `prototype-05-latest-message.png`, `gap-10-text-only.png` |
| [#33 Wire typed turns](https://github.com/Lada496/hearth-ios/issues/33) | `prototype-06-text-input.png`, `prototype-04-processing.png`, `prototype-05-latest-message.png`, `flow-02-conversation-turn.png` |
| [#34 Wire the voice loop](https://github.com/Lada496/hearth-ios/issues/34) | `prototype-03-recording.png`, `prototype-04-processing.png`, `prototype-05-latest-message.png`, `flow-02-conversation-turn.png` |
| [#35 Accessibility](https://github.com/Lada496/hearth-ios/issues/35) | `gap-16-accessibility.png`, `catalog-all-ui.png` |
| [#36 August build verification](https://github.com/Lada496/hearth-ios/issues/36) | `catalog-all-ui.png`, all `flow-*.png` |
| [#37 Model-enrichment handoff](https://github.com/Lada496/hearth-ios/issues/37) | `deferred-prototype-reference.png` |

## Screen files

Retained prototype screens are numbered `prototype-01` through `prototype-07`. New screens are
numbered `gap-01` through `gap-16`. Keep those stable names when replacing a mockup with a newer
approved revision so ticket links remain valid.
