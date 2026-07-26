# Design system debug preview screenshots

Screenshot evidence for issue #10 (design-system tokens and fonts), captured by temporarily
running `DesignSystemPreview` (`Hearth/Hearth/DesignSystem/DesignSystemPreview.swift`) as the
app's root view on iPhone 17 Pro Simulator, iOS 26.5.

- `colors.png` — all 19 color tokens from UI-SPEC.md §1.
- `typography-radius-shadow.png` — all typography roles (real bundled Nunito and Playfair
  Display rendering, not system-font fallback), radius tokens, and shadow tokens.

`DesignSystemPreview` is `#if DEBUG`-only and is never the app's real root view; the swap used
to capture these was reverted immediately after.
