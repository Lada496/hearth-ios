import CoreGraphics

/// Semantic spacing tokens from UI-SPEC.md §§3-4. Views must reference these tokens
/// instead of repeating component-specific padding and margin values.
enum SpacingHearth {
    /// Gap between the title, subtitle, and CTA on the landing screen.
    static let landingContentGap: CGFloat = 20

    /// Landing CTA content padding.
    static let ctaVerticalPadding: CGFloat = 16
    static let ctaHorizontalPadding: CGFloat = 48

    /// Center-divider vertical content padding. Thinned from the prototype's 6 pt
    /// (`translate-page.module.css`'s `.centerDivider`) per human review during issue #19.
    static let dividerVerticalPadding: CGFloat = 5

    /// Message-bubble content padding.
    static let messageBubbleVerticalPadding: CGFloat = 10
    static let messageBubbleHorizontalPadding: CGFloat = 14

    /// Text-input placement within a conversation pane.
    static let inputHorizontalMargin: CGFloat = 12
    static let collapsedInputLeadingMargin: CGFloat = 24
}
