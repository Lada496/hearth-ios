# Supporting Screens and Error Copy Specification

Status: draft, pending human approval (see Acceptance).

Issue: https://github.com/Lada496/hearth-ios/issues/23

Sprint task: `docs/sprints/sprint-1.md` task 1.7

Depends on: `docs/PRD.md`, `docs/adr/ADRs.md`, and the August UI reference pack.
Blocks: [#24](https://github.com/Lada496/hearth-ios/issues/24),
[#28](https://github.com/Lada496/hearth-ios/issues/28),
[#29](https://github.com/Lada496/hearth-ios/issues/29), and
[#30](https://github.com/Lada496/hearth-ios/issues/30).

This is a spec-only document. It introduces no Swift files, assets, dependencies,
persistence, or model code.

## Visual authority and approved flow

`docs/design/august-ui/README.md` and the images it maps to issue #23 are the visual source
of truth. Copy, actions, hierarchy, and navigation below intentionally match those images.
An implementation must not silently substitute a different screen or omit an action. A
proposed divergence requires human approval and an updated reference image first.

The approved first-launch sequence from `flow-01-first-launch.png` is:

1. Launch and evaluate the device capability gate before model work.
2. Unsupported devices show the terminal unsupported-device path.
3. Supported first launches show onboarding, then landing.
4. Model preparation begins only after the worker taps **Start conversation** on landing.
5. Successful preparation enters the conversation screen.

Returning users skip onboarding but still reach landing before model preparation.

## Cross-cutting implementation rules

- **No supported-language claims.** Do not list, imply, or count supported languages, show
  tier badges, or claim translation quality (PRD §§3 and 5).
- **No accounts, networking, or downloads.** Do not add sign-in, connectivity indicators,
  remote-download progress, analytics, or external-service links.
- **No transcript history.** Conversation content remains in memory only (ADR-006).
- **Tokens only.** Colors, typography, spacing, radii, material, and shadows come from
  `Hearth/DesignSystem/`. Do not hard-code visual constants in feature views.
- **Dynamic Type gate.** Every worker-facing text role must use a `TypographyToken` whose
  underlying `Font.custom` includes `relativeTo:`. The current design system has scalable
  body roles but not every large title/CTA role shown in the gap images. The design-system
  owner must add or approve those scalable roles before implementation; do not fall back to
  fixed `FontHearth.languageBadge`, `ctaButton`, or `errorToast` values.
- **Localization-ready copy.** The August build uses the exact English literals below. Each
  complete string remains a single `LocalizedStringKey`-compatible literal; do not assemble
  sentences from fragments.
- **Reduced motion.** Replace fades, slides, pulses, and page transitions with immediate
  state changes when Reduce Motion is enabled. Preserve all information and controls.
- **Touch targets.** Every control is at least 44×44 pt.
- **Screen shell.** Worker-facing screens use `Color.Hearth.bodyBehindShell` behind a centered
  shell no wider than 420 pt. The shell uses `Color.Hearth.cream`; cards alternate existing
  `sandLight`/cream-family surfaces as shown in the reference images.

## 1. Unsupported-device screen

**Reference:** `gap-04-unsupported-device.png`, `flow-01-first-launch.png`.

### Entry, exit, and navigation

- Enter at launch when the ADR-005 memory check fails, before onboarding or model loading.
- The user cannot continue to landing or conversation.
- **About Hearth** opens the same About & attribution content specified in §4, then returns
  to this screen. Closing the app is the only session exit.

### Exact copy

- Navigation title: **"Unsupported device"**
- Title: **"This iPhone cannot run Hearth safely"**
- Body: **"Hearth needs at least 6 GB of memory to keep translation private and on this
  device."**
- Requirement card: **"Supported: iPhone 12 Pro and newer qualifying models."**
- Button: **"About Hearth"**

The memory and device wording is a product promise and requires explicit human approval before
issue #24 begins. It mirrors the approved image and ADR-005; implementation must derive the
gate from memory capability rather than parsing this display string or maintaining a view-level
device list.

### Layout and accessibility

- Center the device-with-x icon, title, body, requirement card, and secondary button in the
  order shown. The icon is decorative and hidden from VoiceOver.
- VoiceOver order: navigation title → title (`.isHeader`) → body → requirement → About Hearth.
- Allow the title, body, and card to grow vertically at accessibility text sizes without
  clipping or covering the button.

### Acceptance

- Screenshot: iPhone 16 portrait, 393×852 pt, compared with
  `gap-04-unsupported-device.png` using an injected unsupported capability.
- Human device check for #24: verify the supported path on a supported iPhone and the blocked
  path on an actual unsupported iPhone when one is available; otherwise record that the
  unsupported physical-device check remains outstanding.
- VoiceOver and largest accessibility Dynamic Type preview must preserve the reading order and
  all copy/actions.

## 2. Model preparation, retry, and unavailable states

**References:** `gap-05-model-preparing.png`, `gap-06-model-failure.png`,
`gap-07-model-unavailable.png`, `flow-01-first-launch.png`.

These states are entered only after **Start conversation**. Settings remains reachable during
preparation and failure. Returning to landing does not retain conversation content.

### 2a. Preparing private translation

**Entry/exit**

- Enter when model preparation starts after **Start conversation**.
- Success enters the empty conversation screen.
- **Settings** opens Settings while preparation remains the current app state; returning shows
  the latest preparation state.

**Exact copy**

- Eyebrow: **"Getting ready"**
- Title: **"Preparing private translation"**
- Body: **"Checking the speech and translation models bundled with Hearth."**
- Privacy note: **"Everything stays on this iPhone."**
- Button: **"Settings"**

**Layout and behavior**

- Show the three processing dots above the title. Hide their animation for Reduce Motion.
- Show determinate progress only when the preparation layer reports a real fraction. When it
  cannot, omit the filled progress fraction and keep the dots/labels indeterminate; never
  synthesize a percentage or ETA from elapsed time.
- VoiceOver announces **"Preparing private translation. Please wait."** once on entry. The
  progress control exposes its value only when real progress exists.

### 2b. Retryable translator failure

**Entry/exit**

- Enter when preparation fails with a condition that may succeed on retry.
- **Try again** returns to §2a. **Settings** opens model status. **Back** returns to landing.

**Exact copy**

- Navigation title: **"Translator"**
- Back label: **"Back"**
- Title: **"Hearth could not prepare the translator"**
- Body: **"Nothing left this phone. Try again, or open Settings to review the model status."**
- Primary button: **"Try again"**
- Secondary button: **"Settings"**

The failure icon is decorative. VoiceOver order is Back → navigation title → title (`.isHeader`)
→ body → Try again → Settings. Move VoiceOver focus to the title when the state appears.

### 2c. Translation unavailable

**Entry/exit**

- Enter when the bundled translation model cannot start and retry cannot safely recover.
- **Return to start** goes to landing. **About this build** opens About & attribution.
  **Back** also returns to landing. Conversation is not entered.

**Exact copy**

- Navigation title: **"Translator"**
- Back label: **"Back"**
- Title: **"Translation is unavailable"**
- Body: **"This build cannot start its bundled translation model on this iPhone.
  Conversation cannot continue safely."**
- Primary button: **"Return to start"**
- Secondary button: **"About this build"**

The device-with-x icon is decorative. VoiceOver order is Back → navigation title → title
(`.isHeader`) → body → Return to start → About this build.

### Model-state acceptance

| State | Preview size | Visual reference |
|---|---|---|
| Preparing | iPhone 16 portrait, 393×852 pt | `gap-05-model-preparing.png` |
| Retryable failure | iPhone 16 portrait, 393×852 pt | `gap-06-model-failure.png` |
| Unavailable | iPhone 16 portrait, 393×852 pt | `gap-07-model-unavailable.png` |

Each state must also pass VoiceOver order, largest accessibility Dynamic Type without clipped
actions, and Reduce Motion checks. A human verifies real model transitions on a supported iPhone
under issue #28; previews may inject each state without model files.

## 3. Onboarding

**References:** `gap-01-onboarding-hold.png`, `gap-02-onboarding-pass.png`,
`gap-03-onboarding-privacy.png`, `flow-01-first-launch.png`.

### Entry, exit, and replay

- On first supported launch, enter after the device gate and before landing. Do not prepare
  models during onboarding.
- Completing page 3 sets only the onboarding-seen flag and opens landing.
- Settings row **Show onboarding again** replays all three pages. Completing a replay returns
  to landing and leaves the already-set flag unchanged.

### Exact pages

| Page | Title | Body | Action |
|---|---|---|---|
| 1 | **"Hold to speak"** | **"Keep your finger on the microphone while you talk. Release when you are finished."** | **"Next"** |
| 2 | **"Pass the phone"** | **"The resident reads the top half. You read the bottom half. Each side has its own microphone."** | **"Next"** |
| 3 | **"Private by design"** | **"Hearth works offline. Conversations are never saved and are cleared when you end or leave a session."** | **"Continue to Hearth"** |

The privacy page deliberately says **never saved**, not **nothing is recorded**: hold-to-talk
temporarily captures audio for on-device speech recognition, while ADR-006 prohibits persistence.

### Layout and accessibility

- Match the icon-led hierarchy and bottom CTA in each reference image. Pages support both the
  CTA and horizontal swipe navigation.
- Show the three-dot position indicator. Expose it to VoiceOver as **"Page 1 of 3"**, etc.,
  rather than reading three punctuation marks.
- On each page, VoiceOver reads title (`.isHeader`) → body → page position → action. Decorative
  icons are hidden because the adjacent title supplies the same meaning.
- With Reduce Motion, page changes are immediate; focus moves to the next page title.

### Acceptance

- Capture all three pages at iPhone 16 portrait, 393×852 pt, and compare with their respective
  `gap-01`, `gap-02`, and `gap-03` images.
- At the largest accessibility Dynamic Type size, body copy may scroll but the CTA remains
  reachable and no copy is truncated.
- Verify first-launch completion, launch-after-completion, and Settings replay paths.

## 4. Settings, Privacy, About, and attribution

**References:** `gap-13-settings.png`, `gap-14-privacy.png`,
`gap-15-about-attribution.png`.

### Navigation

- Landing exposes the top-trailing Settings control shown in `prototype-01-landing.png`.
- Settings is a full-screen worker-facing navigation destination, not a language sheet.
- Back returns to the screen that opened Settings. Privacy and About & attribution are pushed
  from Settings and their Back controls return to Settings.
- Model preparation/failure may deep-link to Settings with the same Back behavior.

### Settings screen

Rows appear in this order:

1. **Model status** with a read-only runtime value: **Ready**, **Preparing**, **Needs attention**,
   or **Unavailable**. The view does not infer status from time or network state.
2. **Privacy** → Privacy screen.
3. **About & attribution** → About screen.
4. **Show onboarding again** → onboarding page 1.

Footer card copy:

- Title: **"Offline by default"**
- Body: **"No accounts · No analytics · No saved conversations"**

### Privacy screen exact copy

- Navigation title: **"Privacy"**
- Title: **"Privacy is the product"**
- Statements, in order:
  1. **"Works without a network connection"**
  2. **"Conversation text stays in memory only"**
  3. **"End Session clears everything immediately"**
  4. **"Background sessions clear after five minutes"**
  5. **"Hearth does not collect data"**

The lock and row icons are decorative. VoiceOver reads the navigation title, title as a header,
then each complete statement from top to bottom.

### About & attribution screen exact copy

- Navigation title: **"About"**
- App title: **"Hearth"**
- Description: **"Private, on-device translation for face-to-face conversations."**
- Attribution cards:
  - **"Tiny-Aya Earth"** — **"Provisional local translation · CC BY-NC 4.0"**
  - **"WhisperKit"** — **"On-device speech recognition · MIT"**
  - **"llama.cpp Swift bindings"** — **"Local translation runtime · MIT"**
  - **"Nunito & Playfair Display"** — **"Interface fonts · SIL Open Font License"**
- Model-use note: **"Tiny-Aya Earth use is also subject to the Cohere Labs Acceptable Use
  Policy."**
- Quality note: **"Translation quality is not yet approved for any launch language."**

The llama.cpp card and clarified Tiny-Aya license note extend `gap-15-about-attribution.png` to
satisfy Sprint 5 task 5.2's complete attribution requirement. A human must re-check every
displayed license, acceptable-use term, and dependency notice against the exact bundled revisions
before release.

Below the attribution cards, include a **Device information** section in the same card style:

- **"App version"** — `CFBundleShortVersionString` plus build number.
- **"iOS version"** — current local system version.
- **"Device"** — local device model identifier.
- **"Memory tier"** — locally computed capability tier, such as **"6 GB or more"**.

These values are displayed locally and are never transmitted. VoiceOver reads each as a single
label/value pair. Do not expose a hardware serial number or other unique identifier.

### Deliberately absent

- No supported-language list, language tiers, or quality claim.
- No account, analytics, connectivity, download, or external-service controls.
- No transcript/history, export, or persisted-conversation clearing controls.
- No full license text is invented in the view; bundled license obligations remain a human
  release check.

### Settings acceptance

| Screen | Preview size | Visual reference |
|---|---|---|
| Settings | iPhone 16 portrait, 393×852 pt | `gap-13-settings.png` |
| Privacy | iPhone 16 portrait, 393×852 pt | `gap-14-privacy.png` |
| About, top | iPhone 16 portrait, 393×852 pt | `gap-15-about-attribution.png` |
| About, device information | iPhone 16 portrait, 393×852 pt, scrolled | same visual language |

All screens must pass largest accessibility Dynamic Type with vertical scrolling, VoiceOver
order/labels, Reduce Motion, and 44 pt target checks.

## 5. Shared recoverable conversation errors

**References:** `prototype-07-recoverable-error.png`, `flow-03-recovery-privacy.png`, and the
ConversationViewModel from issue #9.

### Copy contract

| Source | User-facing copy |
|---|---|
| `SpeechToTextError.notPrepared` | **"Still getting ready. Please wait a moment and try again."** |
| `SpeechToTextError.audioTooShort` | **"That was too short to hear. Hold the button and speak."** |
| `SpeechToTextError.transcriptionFailed` | **"Couldn't understand that. Please try again."** |
| `TranslationError.notPrepared` | **"Still getting ready. Please wait a moment and try again."** |
| `TranslationError.emptyInput` | **"Nothing to translate."** |
| `TranslationError.translationFailed` | **"Couldn't translate that. Please try again."** |
| Resident language unknown | **"We don't know the resident's language yet. Have them speak first."** |
| Unclassified turn failure | **"Translation paused. Please try that turn again."** |

New recoverable errors use plain language, state the next action, avoid blame/jargon, and stay
within two sentences. Engine names and error types never appear in conversation copy.

### Presentation and behavior

- Present the error as the retained toast in `prototype-07-recoverable-error.png`: top-center
  within the worker pane, `Color.Hearth.errorBg`, white scalable error typography,
  `RadiusHearth.toast`, maximum width 300 pt.
- Tapping the toast calls `dismissError()`. A successful retry or new turn also clears stale
  error copy. No automatic dismissal timer is defined.
- With motion enabled, use the UI-SPEC 0.3 s fade and 8 pt downward entry. With Reduce Motion,
  show it immediately.
- Post a VoiceOver announcement when `error` changes from `nil` to a value, then keep normal
  focus on the current conversation control. Do not rely on `.updatesFrequently` to announce
  an off-focus toast.

### Acceptance

- Screenshot: iPhone 16 portrait, 393×852 pt, compared with
  `prototype-07-recoverable-error.png` using the generic unclassified copy.
- Preview every table row at standard and largest accessibility Dynamic Type; the toast may
  grow vertically but must not obscure the microphone or text-input controls.
- Verify tap-to-dismiss, retry clearing, VoiceOver announcement, and Reduce Motion behavior.

## Acceptance

- [ ] All five areas have unambiguous entry/exit, copy, visual hierarchy, navigation,
      accessibility behavior, and preview acceptance.
- [ ] Copy and actions match the mapped August reference images, except the explicitly noted
      attribution and license clarifications.
- [ ] Copy makes no supported-language or translation-accuracy claim.
- [ ] A human approves the device, privacy, and quality wording.
- [ ] A human verifies displayed dependency/model/font licenses against bundled revisions.
- [ ] Scalable supporting-screen typography roles are approved in the design system before
      implementation tickets begin.
- [ ] Human approval is recorded before #24, #28, #29, or #30 begins.
