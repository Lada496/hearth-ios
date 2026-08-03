# Hearth UI Specification

**Purpose:** make the SwiftUI app visually indistinguishable from the prototype. Every value
below was extracted from the prototype's actual CSS (paths given), not approximated. When in
doubt, the screenshots in `screenshots/` are the final arbiter — especially `translation.png`
(conversation screen) and `landing.png`.

**August 2026 scope note:** the final language list and permanent tier badges are deferred.
Where this historical visual spec says Tier 1/Tier 2, implement the equivalent runtime state:
speech available or text only. The manual language sheet in §4e is post-August work.

**Reference screenshots show more than Hearth iOS builds.** The prototype screenshots
(`translation.png`, `harmful-language-detection.png`, `layout.png`, `prompt.png`,
`support.png`, `transcript.png`) capture the *whole* web prototype, including features this
repo has explicitly decided not to port. Only build what's documented in §§3-4 below —
specifically, the following visible elements are **not in scope**, regardless of how
prominently they appear in a screenshot:
- The "Auto / Earth / Fire / Water" region-model picker bar (ADR-003: "Drop the earth/fire/
  water/global picker")
- The "Support" tab and its prompt library (PRD: "support prompts... cut")
- The bottom-right save/transcript icons and transcript viewer overlay (ADR-006: "no
  persistence of conversation content")
- **`harmful-language-detection.png`'s blocking red alert is actively wrong to copy** —
  PRD explicitly requires this feature, if ever built, to "silently skip translation... no
  alert, no SMS, no blocking message." The screenshot's UI contradicts that decision; do not
  treat it as the target design if this feature is ever picked up.

Implement all tokens in `Hearth/DesignSystem/` (e.g. `Color+Hearth.swift`,
`Font+Hearth.swift`). **Views must never hard-code these values.**

---

## 1. Color tokens

Source: `reference/frontend/app/globals.css`

| Token | Hex | Usage |
|---|---|---|
| `cream` | `#FFFDF8` | app shell background |
| `sand` | `#EDE0CC` | divider/tab-bar tint (used at 35–55% opacity over blur) |
| `sandLight` | `#F5EDE3` | secondary surfaces |
| `warmth` | `#E6A886` | PRIMARY accent: mic button, CTA, send button, "me" bubbles, tab slider |
| `text` | `#635B56` | default body text |
| `divider` | `#E8E0D6` | hairlines |
| `sideTop` | `#FDF0DC` | resident (top) pane background + landing page background |
| `sideBottom` | `#FCDFC2` | worker (bottom) pane background |
| `recording` | `#C45E1A` | active recording state (mic button + pulse rings) |
| `processing` | `#7D6B58` | processing-dots indicator |
| `textOnWarmth` | `#3D2218` | text/icons on warmth surfaces (7.17:1 — AAA) |
| `bubbleOtherBg` | `#FEF5EC` | "other person" bubble background |
| `bubbleMeOriginal` | `#421E0A` | original-text color in "me" bubbles (AAA) |
| `bubbleOtherOriginal` | `#4A3F35` | original-text color in "other" bubbles (AAA) |
| `bubbleMeTranslation` | `#3D2218` | translation text in "me" bubbles (AAA) |
| `bubbleOtherTranslation` | `#3D3228` | translation text in "other" bubbles (AAA) |
| `headingInk` | `#5E5650` | landing title/subtitle, conversation language badge |
| `errorBg` | `#5C2020` | error toast background (white text) |
| `placeholder` | `#968474` | text-field placeholder |
| `bodyBehindShell` | `#E8D9C4` | page background behind the 420 pt shell (iPad/large screens) |

The prototype's contrast pairs are **WCAG AAA** — preserve them exactly.

**Grain texture:** the whole app has a fractal-noise overlay at 3.5% opacity
(`globals.css` body::after). SwiftUI: a tiled noise image in an `.overlay` with
`.opacity(0.035)` and `.allowsHitTesting(false)` at the root. Low priority but it is part of
the warm paper-like feel.

## 2. Typography

| Role | Font | Size / weight | Source |
|---|---|---|---|
| App body / UI | **Nunito** (Google Fonts, OFL — bundle the TTFs) | 13–15 pt, weights 400/600/700/800 | `globals.css` |
| Landing title "Hearth" | **Playfair Display** 900 | 80 pt, letter-spacing −1, line-height 1 | `app/page.module.css` |
| Landing subtitle | Playfair Display 700 | 17 pt | same |
| CTA button | Nunito 800 | 17 pt | same |
| Conversation: latest translation | Nunito 700 | 24 pt, line-height 1.4, centered | `ConversationThread.module.css` |
| Conversation: language badge | Nunito 700 | 22 pt, color `headingInk` | same |
| Bubble translation | Nunito 700 | 15 pt, line-height 1.35 | `ConversationThread.module.css` |
| Bubble original (source text) | Nunito italic | 12 pt, line-height 1.4 | same |
| Tab labels | Nunito 700 | 13 pt | `app/translate/page.module.css` |
| Text input | Nunito 400 | 13 pt | `TextInputBar.module.css` |

Both fonts are SIL OFL — bundling in an iOS app is permitted; add them to the attribution
screen. Worker-side text must additionally support Dynamic Type scaling (PRD §6).

**Non-Latin script fallback.** The reference prototype's `globals.css` declares a real
fallback stack for text Nunito can't render: `Nunito → Noto Sans + per-script variants
(Arabic, Hebrew, Devanagari, Bengali, Gujarati, Gurmukhi, Tamil, Telugu, Khmer, Lao, Thai,
Myanmar, Chinese/Japanese/Korean, Ethiopic) → sans-serif`. This matters for Hearth
specifically because the low-resource languages under consideration (e.g. Amharic uses
Ethiopic script) won't render in Nunito at all. iOS/CoreText automatically substitutes a
system font per-glyph when the active font (including a bundled custom font like Nunito)
lacks a character — this should work without extra code, but **must be verified visually
on-device** once real multilingual text renders (#19/#25), since we're relying on OS
cascade behavior rather than an explicit fallback list like CSS requires.

## 3. Screen: Landing  (`screenshots/landing.png`, `reference/frontend/app/page.tsx`)

- Full-screen `sideTop` background, vertically centered VStack, gap 20.
- "Hearth" Playfair 900 80 pt `headingInk` → subtitle "Real-time translation, face to face"
  Playfair 700 17 pt → CTA pill.
- CTA: warmth bg, `textOnWarmth` label, padding 16×48, **fully rounded** (radius 100),
  press scales to 0.98. Tap → 200 ms fade → conversation screen.

## 4. Screen: Conversation  (`screenshots/translation.png`, `reference/frontend/app/translate/page.tsx`)

The signature screen. Vertical layout, full height:

```
┌─────────────────────────────┐
│  TOP PANE  (rotated 180°)   │  bg sideTop #FDF0DC — resident faces the worker
│  ConversationView (top)     │  .rotationEffect(.degrees(180)) on the WHOLE pane
│  MicButton + TextInput      │
├─────────────────────────────┤
│  CENTER DIVIDER             │  glass bar: sand @55% + blur(12), 1px white@50% top/bottom
│  (language indicator)       │  borders, vertical padding 6  [v1: shows session language;
├─────────────────────────────┤   prototype had RegionPicker here — cut]
│  BOTTOM PANE (normal)       │  bg sideBottom #FCDFC2 — worker side
│  ConversationView (bottom)  │
│  MicButton + TextInput      │
└─────────────────────────────┘
```

- Shell: max-width 420 pt centered (matters on iPad), `cream` background, content clipped.
- The two panes are **equal flex halves**. Each shows the conversation *from its viewer's
  perspective* (own messages right-aligned warmth bubbles, other's left-aligned).
- Prototype center-stage display: the *latest* message is shown large (24 pt centered) in
  each pane with a 22 pt language badge (flag + name) above — see `ConversationThread.tsx`.
  Follow the screenshot.
- Error toast: floats top-center (top ≈ 80), `errorBg` bg, white 13 pt semibold, radius 12,
  max-width 300, slides down 8 pt + fades in over 0.3 s, tap to dismiss.
- Talk/Support tab pill (top-right in prototype): **cut for v1** (no Support tab). Keep the
  visual pattern in mind for v2.

### 4a. MicButton  (`reference/frontend/components/MicButton.module.css`)

- 60×60 circle, `warmth` bg, `textOnWarmth` mic glyph, shadow: warmth-tinted
  `rgba(240,168,130,0.35)` y=3 blur=14.
- **Hold-to-record** (press-and-hold, not toggle). While recording: bg → `recording`,
  scale 1.1, shadow `rgba(196,94,26,0.3)` y=4 blur=20, and **three pulse rings**: 2 px
  `recording` borders expanding scale 0.85→1.6 while fading 0.5→0 opacity, 1.6 s ease-out,
  staggered 0 / 0.5 / 1.0 s, repeating.
- Disabled (other side recording / processing): opacity 0.25, hit-testing off.
- Positioned bottom-center of its pane, slightly overlapping the thread above.

### 4b. Message bubbles  (`reference/frontend/components/ConversationThread.module.css` —
merged upstream from a formerly-separate `MessageBubble.module.css`)

- Max-width 88% of pane, padding 10×14, radius 16 — except the corner nearest the sender is 4
  ("me": bottom-right 4; "other": bottom-left 4).
- "Me": `warmth` bg, right-aligned. "Other": `bubbleOtherBg`, left-aligned.
- Contents: language row (flag badge 14 pt bold, 70% opacity) → original text (12 pt italic)
  → translation (15 pt bold). Colors per token table §1.
- Play button: 28×28 circle inside the bubble's lower corner (left for "me", right for
  "other"), 10–12% black-tone bg, press scales 0.9. When runtime TTS support is unavailable,
  replace it with a small "text only" label.
- Entry animation: fade + 6 pt upward slide, 0.3 s ease.

### 4c. Processing indicator  (`ConversationThread.module.css`)

Three 10 pt dots, `processing` color, scale 1→1.3→1 + opacity 0.3→1→0.3, 1 s loop,
staggered 0 / 0.15 / 0.3 s. Centered in the pane while transcribing/translating.

### 4d. TextInputBar  (`reference/frontend/components/TextInputBar.module.css`)

- Collapsed: a lone 48×48 **keyboard icon** button (updated from an earlier pencil icon —
  same 48×48 hit target, just a different glyph), left-aligned (margin-left 24), muted
  `#8A827D`.
- Tap → card slides open ~0.45 s spring-ish ease (cubic-bezier(0.16,1,0.3,1)); icon shrinks
  to 25×25 warmth circle.
- Input card: horizontal margins 12, radius 14, **glass style**: `rgba(255,248,235,0.35)` +
  blur(10) (`.ultraThinMaterial` tinted), 1 px border `rgba(180,150,120,0.18)`, shadow
  `rgba(61,50,40,0.08)` y=2 blur=12.
- TextField 13 pt, placeholder `placeholder` color, grows 1→~5 lines (max-height 96).
  Placeholder copy: **"Type in any language…"** for the resident (top) side, **"Type in
  English…"** for the worker (bottom) side.
- Send: 26×26 warmth circle, `textOnWarmth` arrow, disabled at 30% opacity.

### 4e. Language sheet (deferred until target languages are selected)

After the target-language decision, use `reference/frontend/components/SupportPanel.tsx`'s
language dropdown as a visual/data reference, filter it to the approved catalog, and add the
approved capability labels. As of the latest reference sync: rows are **name only, no flag
emoji** (an earlier flag-emoji treatment was removed upstream), Nunito 600, cream surface,
warmth highlight on selection; the full reference dropdown now covers 72 languages with ARIA
`listbox` semantics and closes on outside click. Present as a standard `.sheet` from the
center divider.

The reference language state is session-scoped: it persists across the conversation (and,
upstream, across its Support tab) for the duration of a session, and only resets on returning
to the landing screen or an explicit language reset — never silently mid-session. This
already matches how `ConversationViewModel` (#9) holds `residentLanguage` for the whole
session and clears it only in `endSession()`.

Do not implement this for the August build. Until the final catalog exists, the divider may
display detected session-language metadata but must not advertise a supported-language list.

## 5. Motion summary

| Element | Animation |
|---|---|
| Screen transitions | 0.2 s fade in; landing exit 0.45 s fade out |
| Message arrival | 0.3 s fade + 6 pt rise |
| Mic recording | pulse rings 1.6 s ease-out ×3 staggered; button scale 0.2 s |
| Processing dots | 1 s loop, 0.15 s stagger |
| Input bar expand | 0.45 s cubic-bezier(0.16,1,0.3,1) |
| Buttons | hover/press scale 1.06 / 0.95-ish, 0.15-0.2 s |

## 6. SwiftUI mapping notes

- Top pane rotation: `.rotationEffect(.degrees(180))` on the pane container. **Gotcha:**
  apply to the entire pane including its mic/input so touch targets rotate with it; test
  scroll direction feels natural to the resident.
- CSS `backdrop-filter: blur` glass → `.background(.ultraThinMaterial)` tinted with
  `sand.opacity(...)`; match against screenshots, not exact CSS alpha.
- `100dvh` → SwiftUI handles this natively; respect safe areas; keyboard avoidance only on
  the bottom (worker) input — the top input needs custom handling since it's rotated.
- Flag emoji render natively. Preview/test fixtures may borrow the prototype's
  `LANGUAGE_FLAGS` map, but production views must accept runtime language metadata rather than
  reading a fixed catalog.
- Radius-100 pills → `Capsule()`.
- Verify colors on-device: prototype colors are sRGB; use `Color(red:green:blue:)` from hex
  in sRGB space.

## 7. Acceptance: "did we replicate it?"

Side-by-side review (simulator screenshot vs `screenshots/translation.png` and
`landing.png`) at each UI PR. Pass = a teammate cannot tell which is which at arm's length,
minus cut features (tab pill, region picker, transcript buttons).
