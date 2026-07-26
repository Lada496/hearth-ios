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

    /// Tab labels: Nunito 700, 13 pt.
    static let tabLabel = Font.custom(nunito, size: 13).weight(.bold)

    /// Text input: Nunito 400, 13 pt.
    static let textInput = Font.custom(nunito, size: 13).weight(.regular)

    /// Generic app body / UI text: Nunito 400, 14 pt. Scales with Dynamic Type for the
    /// worker-facing side (PRD §6).
    static let bodyDynamic = Font.custom(nunito, size: 14, relativeTo: .body)
}
