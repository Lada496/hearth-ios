# Supporting Screens and Error Copy Specification

Status: draft, pending human approval (see Acceptance below).

Issue: https://github.com/Lada496/hearth-ios/issues/23

Sprint task: `docs/sprints/sprint-1.md` task 1.7

Depends on: the rebaselined `docs/PRD.md` and `docs/adr/ADRs.md`.
Blocks: [#24](https://github.com/Lada496/hearth-ios/issues/24) (device gate),
[#28](https://github.com/Lada496/hearth-ios/issues/28) (model preparation/retry UX),
[#29](https://github.com/Lada496/hearth-ios/issues/29) (onboarding),
[#30](https://github.com/Lada496/hearth-ios/issues/30) (Settings/About/Privacy/Attribution).

This is a spec-only document. It defines copy, layout, navigation, and accessibility contracts
for screens/states not yet covered by `docs/design/UI-SPEC.md`. **No Swift files, assets,
dependencies, persistence, or model code are introduced here.**

## Cross-cutting rules

These apply to every state below:

- **No supported-language claims.** No screen may list, imply, or count supported/launch
  languages, show tier badges, or suggest translation-quality guarantees (PRD §3, §5).
- **No accounts, network, or download UI.** No sign-in, network-status indicators, download
  progress for remote content, or links to external services (AGENTS.md rule 1; PRD §6).
- **No transcript history.** No screen may reference saving, viewing, or exporting past
  conversation content (ADR-006).
- **Tokens only.** All colors/fonts/radii/shadows come from `Hearth/DesignSystem/` token
  files (`Color+Hearth`, `FontHearth`/`TypographyHearth`, `RadiusHearth`, `ShadowHearth`).
  No screen in this spec introduces a new token; if a needed value doesn't exist yet, flag it
  for human review rather than hard-coding it.
- **Localization placeholder policy.** All user-facing strings are plain English `String`
  literals for the August build (no `.strings`/`String Catalog` infrastructure exists yet).
  Every literal must be a single `Text("...")` call or a `LocalizedStringKey`-compatible
  literal so a future localization pass is a mechanical string-catalog migration, not a
  rewrite. No string concatenation of copy fragments.
- **Reduced motion.** Wherever this spec calls for a fade/scale/pulse animation, that
  animation must be skipped (state should appear instantly) when
  `UIAccessibility.isReduceMotionEnabled` is true.
- **Touch targets.** Every tappable control is at least 44×44 pt, per PRD §6.
- **Dynamic Type.** Worker-facing text (all screens in this spec are worker-facing, not
  rotated) scales with the system content size category; use `Font.custom(_:size:relativeTo:)`
  or `TypographyToken`-based `.hearthTypography(_:)`, never a fixed unscaled size.

---

## 1. Unsupported-device screen

**Source:** ADR-005 (6 GB RAM / iOS 17.0+ floor).

### Entry/exit

- Entry: app launch, before any model preparation begins, when the device fails the ADR-005
  RAM check. This is the *only* entry point — the screen is never reachable via in-app
  navigation.
- Exit: none. This is a terminal screen for the session; the only affordance is to close the
  app. There is no "continue anyway" or "try again" — the device genuinely cannot run the
  model (ADR-005: "app memory ceiling ~2 GB cannot hold Whisper + LLM").

### Copy

- Title: **"This device isn't supported yet"**
- Body: **"Hearth needs more memory than this iPhone has to run its translation model
  fully offline. Nothing was downloaded or changed on your device."**
- No specific RAM number, model name, or device-model list is shown to the user (avoids
  a stale hard-coded device list going out of date; App Store listing carries the
  authoritative requirement per ADR-005).

### Layout

- Full-screen, `Color.Hearth.cream` background, centered content, matches the landing
  screen's shell chrome (no tab bar, no back button).
- A single centered icon (SF Symbol, e.g. `exclamationmark.triangle`, tinted
  `Color.Hearth.text`) above the title.
- Title: reuse `FontHearth.languageBadge` (Nunito 700, 22 pt) — no new token needed, this is
  the closest existing "short, centered, bold statement" role. Body: `TypographyHearth.appBodyRegular`.
- No buttons. No CTA. This is intentionally a dead-end screen.

### Accessibility

- VoiceOver reads the icon as decorative (`.accessibilityHidden(true)`), then title, then
  body, as one combined accessibility element in `.staticText`/`.header` traits order:
  title first (`.isHeader`), then body.
- Dynamic Type applies to both title and body.
- No reduced-motion concern (static screen, no entry animation beyond the standard 0.2s
  screen-transition fade already defined in UI-SPEC §5).

### Screenshot acceptance size

- iPhone 16 (393×852 pt) simulator preview only. No physical-device verification is possible
  for this specific screen: it only renders on devices ADR-005 excludes from the supported
  list, so there is no supported device to test it on. Simulator preview is the acceptance
  bar here, as an exception to the usual physical-device requirement.

---

## 2. Model preparation / retryable load failure / unavailable-model states

**Source:** PRD §4 item 6 ("Loading, processing, empty-input, permission, and recoverable-
error states"), Sprint 3 task 3.4, Sprint 5 task 5.1's onboarding boundary.

Three distinct states, all reachable only between the supported-device check succeeding and
the conversation screen becoming interactive:

### 2a. Preparing (loading)

- Entry: app has passed the device gate and is loading WhisperKit + Tiny-Aya model
  resources into memory.
- Exit: automatic, to the conversation/landing flow, once both engines report ready.
- Copy: **"Getting ready…"** — no percentage, no ETA, no model name. Avoids a promise the
  loading step can't keep (model prep time is device-dependent, PRD §6 performance note is
  about the conversation loop, not first load).
- Layout: centered `ProgressView()` (indeterminate spinner, tinted `Color.Hearth.warmth`)
  above the copy, `Color.Hearth.cream` background.
- Motion: spinner is the standard system indeterminate spin; respects
  `isReduceMotionEnabled` by falling back to a static "Getting ready…" with no spinner
  animation (a plain non-animating glyph) when reduced motion is on — SwiftUI's
  `ProgressView` does not fully honor reduce-motion on its own, so this must be an explicit
  check in the implementing view.
- VoiceOver: announces **"Getting ready, please wait"** once via
  `.accessibilityAddTraits(.updatesFrequently)` so it isn't re-announced on every frame.

### 2b. Retryable load failure

- Entry: model loading throws (e.g. corrupted bundled resource, out-of-memory during load).
- Exit: user taps **Retry**, returning to 2a; or the user backgrounds/force-quits the app
  (no other exit — there is no "continue without models" path since the app has no
  functionality without them).
- Copy:
  - Title: **"Couldn't get ready"**
  - Body: **"Something went wrong preparing Hearth. Try again, or restart the app if this
    keeps happening."**
  - Button: **"Retry"**
- Layout: same shell as 2a, icon (`exclamationmark.triangle`, `Color.Hearth.text`) replaces
  the spinner, `Retry` is a pill button using the existing CTA style
  (`RadiusHearth.pill`, `FontHearth.ctaButton`, `Color.Hearth.warmth` fill,
  `Color.Hearth.textOnWarmth` label) at minimum 44×44 pt.
- VoiceOver: title (`.isHeader`) → body → Retry button, standard focus order top-to-bottom.
- This state does not name which engine failed (WhisperKit vs. Tiny-Aya) — that distinction
  is diagnostic detail, not something the user needs to act on differently.

### 2c. Unavailable model (non-retryable)

- Entry: reserved for a case where retry cannot possibly help (e.g. the app bundle itself is
  missing a required resource — a build/packaging defect, not a transient failure). This is
  expected to be rare/never hit in the August build since models are bundled at build time,
  but the state is specified so the ViewModel layer has a defined terminal error rather than
  an infinite retry loop.
- Copy:
  - Title: **"Hearth can't start"**
  - Body: **"A required file is missing from this install. Reinstalling the app may fix
    this."**
  - No Retry button (retrying a missing bundled resource cannot succeed).
- Layout: same shell as 2b, minus the Retry button.
- VoiceOver: title → body, same pattern as 2b.

---

## 3. Onboarding (three pages or fewer)

**Source:** Sprint 5 task 5.1 ("Add at most three icon-led pages for hold-to-talk,
pass-the-phone, and offline privacy. Store only the onboarding-seen flag.")

### Entry/exit

- Entry: first launch only (no onboarding-seen flag in `UserDefaults`), after the device
  gate and model-preparation succeed, before the landing screen.
- Exit: tapping "Get started" on the final page sets the onboarding-seen flag
  (`UserDefaults`, per ADR-006's explicit allow-list) and navigates to the landing screen.
  Onboarding never reappears after that, with no in-app way to replay it in the August build
  (Settings does not get a "replay onboarding" affordance — out of scope per Sprint 5 task
  5.2's minimal Settings scope).

### Pages (exactly three, one concept each)

1. **Hold-to-talk** — icon: mic glyph (reuse conversation screen's mic iconography style).
   Copy: **"Hold the mic button and speak. Let go when you're done."**
2. **Pass-the-phone** — icon: phone-rotate glyph. Copy: **"Hand the phone across. The other
   person's side is upside-down on purpose — it faces them correctly."**
3. **Offline privacy** — icon: lock/wifi-slash glyph. Copy: **"Everything happens on this
   phone. Nothing is recorded, saved, or sent anywhere."**

Each page is a full-screen `Color.Hearth.cream` view: icon, then title-less body copy in
`TypographyHearth.appBodyRegular`, paged via a `TabView(.page)` style, no page indicator
text (dots use standard SwiftUI page control, tinted `Color.Hearth.warmth` for the active
dot). Final page adds a **"Get started"** pill CTA button (same CTA styling as §2b's Retry).
Pages 1-2 have no button — swipe or the standard page-dot navigation advances.

### Accessibility

- Each page is a single VoiceOver "page" — swipe-right/left (or the standard
  `TabView(.page)` accessibility rotor) moves between pages; icon is decorative
  (`.accessibilityHidden(true)`).
- "Get started" is only focusable on page 3, 44×44 pt minimum.
- Reduced motion: page transitions use `.animation(nil)` fallback (no slide animation) —
  content still changes, just without the animated transition.

### Screenshot acceptance size

- iPhone 16 (393×852 pt), portrait only (onboarding is worker-facing setup, not the rotated
  resident pane, so no landscape/rotated variant is needed).

---

## 4. Settings / About / Privacy / Attribution

**Source:** Sprint 5 task 5.2 ("Add privacy, model/library/font attributions, and device
information. Do not show a supported language list or tier badges before the language
decision.")

### Entry/exit

- Entry: a Settings entry point from the landing screen (icon button, top corner — exact
  placement matches `docs/design/screenshots/landing.png` chrome where present, otherwise a
  single top-trailing gear icon at 44×44 pt tap target).
- Exit: a close/back control (top-leading, standard `chevron.left` or `xmark`, 44×44 pt)
  returns to landing. This is a `.sheet` presentation, consistent with §4e's Language sheet
  pattern in `UI-SPEC.md`.

### Sections and copy

1. **Privacy** — static text, no toggles (there is nothing to opt in/out of since there's no
   networking to begin with): **"Hearth doesn't collect, store, or send any conversation
   content. Everything runs on this device. Ending a session — or leaving the app in the
   background for more than five minutes — clears the conversation."**
2. **About** — app name, version/build number (from `Bundle.main`, read at render time —
   not hard-coded), one-line description: **"Hearth helps a shelter worker and a resident
   communicate, powered by on-device translation."**
3. **Attributions** — a plain list, no links out: model name(s) (Tiny-Aya Earth, WhisperKit)
   with their license names only (no full license text inline; if a human wants full license
   text shown, that's a separate follow-up, not this spec), plus Nunito and Playfair Display
   font attributions (both are open-license Google Fonts — name + license name only, e.g.
   "Nunito — SIL Open Font License 1.1").
4. **Device information** — read-only, diagnostic only: iOS version, device model identifier,
   available RAM tier (e.g. "6 GB+") — no networking, no telemetry sent anywhere; this is
   displayed locally for the user/support-desk's own troubleshooting reference only.

### What is deliberately absent

- No supported-language list or tier badges (explicit PRD §5/§3 deferral).
- No "manage account" / sign-in — there are no accounts.
- No network/connectivity status row (app has no network code to report on).
- No transcript/history section or "clear data now" button — there is nothing persisted to
  clear (ADR-006); the only content-bearing state is the live conversation, which Settings
  does not touch.

### Layout

- Grouped-list style (`List` with `.insetGrouped` or a custom card list matching
  `RadiusHearth.card` on each section container), `Color.Hearth.cream` background,
  `Color.Hearth.text` body text via `TypographyHearth.appBodyRegular`, section headers via
  `TypographyHearth.appBodySemibold`.

### Accessibility

- Each section header uses `.isHeader` trait.
- Close button has an explicit `.accessibilityLabel("Close settings")` (an icon-only button
  otherwise reads as an unlabeled glyph).
- Device-information values are read as `"iOS version, 26.5"` style label+value pairs, not
  bare numbers.

### Screenshot acceptance size

- iPhone 16 (393×852 pt) portrait, sheet presentation at full height.

---

## 5. Shared recoverable-error wording (ConversationViewModel)

**Source:** `Hearth/Features/Conversation/ConversationViewModel.swift` (issue #9,
`feat/conversation-viewmodel`), PRD §4 item 6.

This section documents the copy contract the ViewModel already implements, so future engine
work maps new failure cases onto the same tone/format rather than inventing new patterns.

### Existing strings (frozen contract — reuse this phrasing family for new cases)

| Source error | User-facing copy |
|---|---|
| `SpeechToTextError.notPrepared` | "Still getting ready. Please wait a moment and try again." |
| `SpeechToTextError.audioTooShort` | "That was too short to hear. Hold the button and speak." |
| `SpeechToTextError.transcriptionFailed` | "Couldn't understand that. Please try again." |
| `TranslationError.notPrepared` | "Still getting ready. Please wait a moment and try again." |
| `TranslationError.emptyInput` | "Nothing to translate." |
| `TranslationError.translationFailed` | "Couldn't translate that. Please try again." |
| Unresolved resident language (typed worker reply before any resident speech) | "We don't know the resident's language yet. Have them speak first." |
| Unclassified/unexpected error | "Something went wrong understanding that. Please try again." / "Something went wrong sending that. Please try again." |

### Copy conventions to preserve for any new error case

1. **Plain sentence, no jargon.** Never surface an engine/type name (`SpeechToTextError`,
   `TranslationError`, `WhisperKit`, `Tiny-Aya`) to the user.
2. **State what to do next**, not just what went wrong, whenever an action exists ("Please
   try again", "Have them speak first", "Hold the button and speak").
3. **No blame, no alarm.** No exclamation points, no "Error:" prefix, no red-alert framing —
   matches the PRD's broader stance (see the harmful-language-detection exclusion in
   UI-SPEC.md: "no alert, no SMS, no blocking message") that Hearth avoids scary/blocking UI
   even for recoverable failures.
4. **Two sentences max.** Keeps the toast readable at the existing `errorToast` type size
   (13pt) within the toast's layout.

### Presentation (already defined in UI-SPEC.md, referenced here for completeness)

- Rendered as a toast per UI-SPEC.md §4: floats top-center (top ≈ 80pt), `Color.Hearth.errorBg`
  background, white `FontHearth.errorToast` text, `RadiusHearth.toast` corners, max-width
  300pt, slides down 8pt + fades in over 0.3s, tap anywhere on the toast to dismiss.
- Dismissal: tapping the toast calls the `dismissError()` intent, clearing `error`. No
  auto-dismiss timer is specified here (if product wants one, that's a follow-up decision,
  not assumed by this spec).
- VoiceOver: the toast must be announced via
  `UIAccessibility.post(notification: .announcement, argument:)` or an
  `.accessibilityAddTraits(.updatesFrequently)` live region when `error` transitions from
  `nil` to non-`nil`, since it's not the currently-focused element when it appears.

---

## Acceptance

- [ ] All five sections above have unambiguous state, copy, layout, and accessibility
      requirements (this document).
- [ ] Copy makes no supported-language, device-list, or accuracy claim (see per-section
      notes above).
- [ ] A human approves this spec before implementation tickets (#24, #28, #29, #30) begin.
