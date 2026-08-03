import SwiftUI

/// Typography tokens from UI-SPEC.md §2. Views must reference these tokens and never
/// hard-code font names/sizes.
///
/// Nunito and Playfair Display are bundled as variable fonts (single file spans the full
/// weight range) in `DesignSystem/Fonts/` and registered in Info.plist under
/// `UIAppFonts`. Weight is selected via `.weight(_:)` on the variable font's `wght` axis,
/// which SwiftUI/CoreText maps automatically — no separate static-weight files needed.
enum FontHearth {
    private static let nunito = "Nunito"
    private static let playfairDisplay = "Playfair Display"

    /// Generic app body / UI text weights at the middle of the documented 13-15 pt range.
    static let bodyRegular = Font.custom(nunito, size: 14, relativeTo: .body).weight(.regular)
    static let bodySemibold = Font.custom(nunito, size: 14, relativeTo: .body).weight(.semibold)
    static let bodyBold = Font.custom(nunito, size: 14, relativeTo: .body).weight(.bold)
    static let bodyHeavy = Font.custom(nunito, size: 14, relativeTo: .body).weight(.heavy)

    /// Landing title "Hearth": Playfair Display 900, 80 pt.
    static let landingTitle = Font.custom(playfairDisplay, size: 80).weight(.black)

    /// Landing subtitle: Playfair Display 700, 17 pt.
    static let landingSubtitle = Font.custom(playfairDisplay, size: 17).weight(.bold)

    /// CTA button label: Nunito 800, 17 pt.
    static let ctaButton = Font.custom(nunito, size: 17).weight(.heavy)

    /// Conversation: latest translation, Nunito 700, 24 pt.
    static let latestTranslation = Font.custom(nunito, size: 24).weight(.bold)

    /// Conversation: language badge, Nunito 700, 22 pt.
    static let languageBadge = Font.custom(nunito, size: 22).weight(.bold)

    /// Message bubble translation text: Nunito 700, 15 pt.
    static let bubbleTranslation = Font.custom(nunito, size: 15).weight(.bold)

    /// Message bubble original (source) text: Nunito italic, 12 pt.
    static let bubbleOriginal = Font.custom(nunito, size: 12).italic()

    /// Message bubble language row: Nunito 700, 14 pt.
    static let bubbleLanguageRow = Font.custom(nunito, size: 14).weight(.bold)

    /// Tab labels: Nunito 700, 13 pt.
    static let tabLabel = Font.custom(nunito, size: 13).weight(.bold)

    /// Text input: Nunito 400, 13 pt.
    static let textInput = Font.custom(nunito, size: 13).weight(.regular)

    /// Error toast: Nunito 600, 13 pt.
    static let errorToast = Font.custom(nunito, size: 13).weight(.semibold)

    /// Backwards-compatible name for generic Dynamic Type body text.
    static let bodyDynamic = bodyRegular
}

/// A complete typography role, including metrics that `Font` alone cannot carry.
struct TypographyToken {
    let font: Font
    let tracking: CGFloat
    let lineHeightMultiplier: CGFloat
    let lineSpacing: CGFloat
    let alignment: TextAlignment

    fileprivate init(
        font: Font,
        size: CGFloat,
        tracking: CGFloat = 0,
        lineHeightMultiplier: CGFloat = 1,
        alignment: TextAlignment = .leading
    ) {
        self.font = font
        self.tracking = tracking
        self.lineHeightMultiplier = lineHeightMultiplier
        lineSpacing = size * (lineHeightMultiplier - 1)
        self.alignment = alignment
    }
}

/// Typography roles from UI-SPEC.md §§2-4. Using these tokens keeps tracking and line-height
/// values out of feature views while preserving Dynamic Type through `Font.custom`.
enum TypographyHearth {
    static let appBodyRegular = TypographyToken(font: FontHearth.bodyRegular, size: 14)
    static let appBodySemibold = TypographyToken(font: FontHearth.bodySemibold, size: 14)
    static let appBodyBold = TypographyToken(font: FontHearth.bodyBold, size: 14)
    static let appBodyHeavy = TypographyToken(font: FontHearth.bodyHeavy, size: 14)

    static let landingTitle = TypographyToken(
        font: FontHearth.landingTitle,
        size: 80,
        tracking: -1
    )
    static let landingSubtitle = TypographyToken(font: FontHearth.landingSubtitle, size: 17)
    static let ctaButton = TypographyToken(font: FontHearth.ctaButton, size: 17)
    static let latestTranslation = TypographyToken(
        font: FontHearth.latestTranslation,
        size: 24,
        lineHeightMultiplier: 1.4,
        alignment: .center
    )
    static let languageBadge = TypographyToken(
        font: FontHearth.languageBadge,
        size: 22,
        alignment: .center
    )
    static let bubbleLanguageRow = TypographyToken(font: FontHearth.bubbleLanguageRow, size: 14)
    static let bubbleTranslation = TypographyToken(
        font: FontHearth.bubbleTranslation,
        size: 15,
        lineHeightMultiplier: 1.35
    )
    static let bubbleOriginal = TypographyToken(
        font: FontHearth.bubbleOriginal,
        size: 12,
        lineHeightMultiplier: 1.4
    )
    static let tabLabel = TypographyToken(font: FontHearth.tabLabel, size: 13)
    static let textInput = TypographyToken(font: FontHearth.textInput, size: 13)
    static let errorToast = TypographyToken(font: FontHearth.errorToast, size: 13)
}

extension Text {
    func hearthTypography(_ token: TypographyToken) -> some View {
        font(token.font)
            .tracking(token.tracking)
            .lineSpacing(token.lineSpacing)
            .multilineTextAlignment(token.alignment)
    }
}
