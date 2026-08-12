import SwiftUI

/// Canonical color tokens from `docs/design/UI-SPEC.md` §1.
/// Views must reference these tokens and never hard-code hex values.
extension Color {
    enum Hearth {
        /// App shell background.
        static let cream = Color(red: 0xFF / 255, green: 0xFD / 255, blue: 0xF8 / 255)

        /// Divider / tab-bar tint (used at 35-55% opacity over blur).
        static let sand = Color(red: 0xED / 255, green: 0xE0 / 255, blue: 0xCC / 255)

        /// Secondary surfaces.
        static let sandLight = Color(red: 0xF5 / 255, green: 0xED / 255, blue: 0xE3 / 255)

        /// Primary accent: mic button, CTA, send button, "me" bubbles, tab slider.
        static let warmth = Color(red: 0xE6 / 255, green: 0xA8 / 255, blue: 0x86 / 255)

        /// Default body text.
        static let text = Color(red: 0x63 / 255, green: 0x5B / 255, blue: 0x56 / 255)

        /// Hairlines.
        static let divider = Color(red: 0xE8 / 255, green: 0xE0 / 255, blue: 0xD6 / 255)

        /// Resident (top) pane background + landing page background.
        static let sideTop = Color(red: 0xFD / 255, green: 0xF0 / 255, blue: 0xDC / 255)

        /// Worker (bottom) pane background.
        static let sideBottom = Color(red: 0xFC / 255, green: 0xDF / 255, blue: 0xC2 / 255)

        /// Active recording state (mic button + pulse rings).
        static let recording = Color(red: 0xC4 / 255, green: 0x5E / 255, blue: 0x1A / 255)

        /// Processing-dots indicator.
        static let processing = Color(red: 0x7D / 255, green: 0x6B / 255, blue: 0x58 / 255)

        /// Text/icons on warmth surfaces (7.17:1 - AAA).
        static let textOnWarmth = Color(red: 0x3D / 255, green: 0x22 / 255, blue: 0x18 / 255)

        /// "Other person" bubble background.
        static let bubbleOtherBg = Color(red: 0xFE / 255, green: 0xF5 / 255, blue: 0xEC / 255)

        /// Original-text color in "me" bubbles (AAA).
        static let bubbleMeOriginal = Color(red: 0x42 / 255, green: 0x1E / 255, blue: 0x0A / 255)

        /// Original-text color in "other" bubbles (AAA).
        static let bubbleOtherOriginal = Color(red: 0x4A / 255, green: 0x3F / 255, blue: 0x35 / 255)

        /// Translation text in "me" bubbles (AAA).
        static let bubbleMeTranslation = Color(red: 0x3D / 255, green: 0x22 / 255, blue: 0x18 / 255)

        /// Translation text in "other" bubbles (AAA).
        static let bubbleOtherTranslation = Color(red: 0x3D / 255, green: 0x32 / 255, blue: 0x28 / 255)

        /// Landing title/subtitle, conversation language badge.
        static let headingInk = Color(red: 0x5E / 255, green: 0x56 / 255, blue: 0x50 / 255)

        /// Error toast background (white text).
        static let errorBg = Color(red: 0x5C / 255, green: 0x20 / 255, blue: 0x20 / 255)

        /// Text-field placeholder.
        static let placeholder = Color(red: 0x96 / 255, green: 0x84 / 255, blue: 0x74 / 255)

        /// Collapsed text-input pencil icon.
        static let inputIconMuted = Color(red: 0x8A / 255, green: 0x82 / 255, blue: 0x7D / 255)

        /// Page background behind the 420 pt shell (iPad/large screens).
        static let bodyBehindShell = Color(red: 0xE8 / 255, green: 0xD9 / 255, blue: 0xC4 / 255)
    }
}
