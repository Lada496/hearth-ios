# Hearth UI Specification

**Purpose:** define the canonical visual contract for the SwiftUI app. The values were extracted
from the original prototype once and are now frozen here; upstream prototype changes do not
change Hearth automatically. For approved August screens and task-specific flows, use the
repository-backed source of truth in [`august-ui/`](august-ui/).

The older full-prototype images in `screenshots/` are historical provenance. They include
features Hearth cut, including the Support tab, model-region picker, transcript persistence,
and harmful-language alert. Never implement those images beyond the scope explicitly retained
by this specification, the PRD, and the current sprint task.

**August 2026 scope note:** the final language list and permanent tier badges are deferred.
Where this historical visual spec says Tier 1/Tier 2, implement the equivalent runtime state:
speech available or text only. The manual language sheet in §4e is post-August work.

Implement all tokens in `Hearth/DesignSystem/` (e.g. `Color+Hearth.swift`,
`Font+Hearth.swift`). **Views must never hard-code these values.**

---

## 1. Color tokens

These values are canonical; change them only through an approved design-spec update.

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

**Grain texture:** the whole app has a fractal-noise overlay at 3.5% opacity. SwiftUI: a tiled noise image in an `.overlay` with
`.opacity(0.035)` and `.allowsHitTesting(false)` at the root. Low priority but it is part of
the warm paper-like feel.

## 2. Typography

| Role | Font | Size / weight |
|---|---|---|
| App body / UI | **Nunito** (Google Fonts, OFL — bundle the TTFs) | 13–15 pt, weights 400/600/700/800 |
| Landing title "Hearth" | **Playfair Display** 900 | 80 pt, letter-spacing −1, line-height 1 |
| Landing subtitle | Playfair Display 700 | 17 pt |
| CTA button | Nunito 800 | 17 pt |
| Conversation: latest translation | Nunito 700 | 24 pt, line-height 1.4, centered |
| Conversation: language badge | Nunito 700 | 22 pt, color `headingInk` |
| Bubble translation | Nunito 700 | 15 pt, line-height 1.35 |
| Bubble original (source text) | Nunito italic | 12 pt, line-height 1.4 |
| Tab labels | Nunito 700 | 13 pt |
| Text input | Nunito 400 | 13 pt |

Both fonts are SIL OFL — bundling in an iOS app is permitted; add them to the attribution
screen. Worker-side text must additionally support Dynamic Type scaling (PRD §6).

## 3. Screen: Landing

Approved image: [`august-ui/prototype-01-landing.png`](august-ui/prototype-01-landing.png).

- Full-screen `sideTop` background, vertically centered VStack, gap 20.
- "Hearth" Playfair 900 80 pt `headingInk` → subtitle "Real-time translation, face to face"
  Playfair 700 17 pt → CTA pill.
- CTA: warmth bg, `textOnWarmth` label, padding 16×48, **fully rounded** (radius 100),
  press scales to 0.98. Tap → 200 ms fade → conversation screen.

## 4. Screen: Conversation

Approved images: [`august-ui/prototype-02-conversation-empty.png`](august-ui/prototype-02-conversation-empty.png)
through [`august-ui/prototype-07-recoverable-error.png`](august-ui/prototype-07-recoverable-error.png),
plus [`august-ui/flow-02-conversation-turn.png`](august-ui/flow-02-conversation-turn.png).

The signature screen. Vertical layout, full height:

```
┌─────────────────────────────┐
│  TOP PANE  (rotated 180°)   │  bg sideTop #FDF0DC — resident faces the worker
│  ConversationView (top)     │  .rotationEffect(.degrees(180)) on the WHOLE pane
│  MicButton + TextInput      │
├─────────────────────────────┤
│  CENTER DIVIDER             │  glass bar: sand @55% + blur(12), 1px white@50% top/bottom
│  (language indicator)       │  borders, vertical padding 5  [v1: shows session language;
├─────────────────────────────┤   prototype had RegionPicker here — cut]
│  BOTTOM PANE (normal)       │  bg sideBottom #FCDFC2 — worker side
│  ConversationView (bottom)  │
│  MicButton + TextInput      │
└─────────────────────────────┘
```

- Shell: max-width 420 pt centered (matters on iPad), `cream` background, content clipped.
- Center-divider vertical padding is 5 pt in this build — thinned from the prototype's 6 pt
  (`translate-page.module.css`'s `.centerDivider`) per human review during issue #19; the
  language names are shown worker-language-first (e.g. "English ↔ Kiswahili") since the
  divider itself isn't rotated and is always read right-side-up from the worker's side.
- The two panes are **equal flex halves**. Each shows the conversation *from its viewer's
  perspective* (own messages right-aligned warmth bubbles, other's left-aligned).
- The *latest* message is shown large (24 pt centered) in each pane with a 22 pt language badge
  (flag + name) above. Follow the approved images.
- Error toast: floats top-center (top ≈ 80), `errorBg` bg, white 13 pt semibold, radius 12,
  max-width 300, slides down 8 pt + fades in over 0.3 s, tap to dismiss.
- Talk/Support tab pill (top-right in prototype): **cut for v1** (no Support tab). Keep the
  visual pattern in mind for v2.

### 4a. MicButton

- 60×60 circle, `warmth` bg, `textOnWarmth` mic glyph, shadow: warmth-tinted
  `rgba(240,168,130,0.35)` y=3 blur=14.
- **Hold-to-record** (press-and-hold, not toggle). While recording: bg → `recording`,
  scale 1.1, shadow `rgba(196,94,26,0.3)` y=4 blur=20, and **three pulse rings**: 2 px
  `recording` borders expanding scale 0.85→1.6 while fading 0.5→0 opacity, 1.6 s ease-out,
  staggered 0 / 0.5 / 1.0 s, repeating.
- Disabled (other side recording / processing): opacity 0.25, hit-testing off.
- Positioned bottom-center of its pane, slightly overlapping the thread above.

### 4b. Message bubbles

- Max-width 88% of pane, padding 10×14, radius 16 — except the corner nearest the sender is 4
  ("me": bottom-right 4; "other": bottom-left 4).
- "Me": `warmth` bg, right-aligned. "Other": `bubbleOtherBg`, left-aligned.
- Contents: language row (flag badge 14 pt bold, 70% opacity) → original text (12 pt italic)
  → translation (15 pt bold). Colors per token table §1.
- Play button: 28×28 circle inside the bubble's lower corner (left for "me", right for
  "other"), 10–12% black-tone bg, press scales 0.9. When runtime TTS support is unavailable,
  replace it with a small "text only" label.
- Entry animation: fade + 6 pt upward slide, 0.3 s ease.

### 4c. Processing indicator

Three 10 pt dots, `processing` color, scale 1→1.3→1 + opacity 0.3→1→0.3, 1 s loop,
staggered 0 / 0.15 / 0.3 s. Centered in the pane while transcribing/translating.

### 4d. TextInputBar

- Collapsed: a lone 48×48 pencil icon button, left-aligned (margin-left 24), muted `#8A827D`.
- Tap → card slides open ~0.45 s spring-ish ease (cubic-bezier(0.16,1,0.3,1)); icon shrinks
  to 25×25 warmth circle.
- Input card: horizontal margins 12, radius 14, **glass style**: `rgba(255,248,235,0.35)` +
  blur(10) (`.ultraThinMaterial` tinted), 1 px border `rgba(180,150,120,0.18)`, shadow
  `rgba(61,50,40,0.08)` y=2 blur=12.
- TextField 13 pt, placeholder `placeholder` color, grows 1→~5 lines (max-height 96).
- Send: 26×26 warmth circle, `textOnWarmth` arrow, disabled at 30% opacity.

### 4e. Language sheet (deferred until target languages are selected)

Do not implement this for the August build. After humans select target languages, write and
approve a dedicated spec for the sheet instead of inheriting the prototype's language catalog.
Until then, the divider may display detected session-language metadata but must not advertise a
supported-language list.

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
- Flag emoji render natively. Preview/test fixtures may use `Domain/TestFixtures.swift`, but
  production views must accept runtime language metadata rather than reading a fixed catalog.
- Radius-100 pills → `Capsule()`.
- Verify colors on-device: prototype colors are sRGB; use `Color(red:green:blue:)` from hex
  in sRGB space.

## 7. Acceptance: "did we replicate it?"

Side-by-side review against the task-mapped images in `docs/design/august-ui/` at each UI PR.
Pass = a teammate cannot tell the implementation from the approved retained screen at arm's
length. Historical full-prototype screenshots are not acceptance targets.
