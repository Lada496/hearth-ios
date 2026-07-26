import SwiftUI

/// Shadow tokens from UI-SPEC.md. Views must reference these tokens and never hard-code
/// shadow values.
struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum ShadowHearth {
    /// MicButton at rest: warmth-tinted glow.
    static let micButtonIdle = ShadowToken(
        color: Color(red: 240 / 255, green: 168 / 255, blue: 130 / 255, opacity: 0.35),
        radius: 14,
        x: 0,
        y: 3
    )

    /// MicButton while recording: deeper, recording-tinted glow.
    static let micButtonRecording = ShadowToken(
        color: Color(red: 196 / 255, green: 94 / 255, blue: 26 / 255, opacity: 0.3),
        radius: 20,
        x: 0,
        y: 4
    )

    /// Glass input card / bottom bar.
    static let glassCard = ShadowToken(
        color: Color(red: 61 / 255, green: 50 / 255, blue: 40 / 255, opacity: 0.08),
        radius: 12,
        x: 0,
        y: 2
    )
}

extension View {
    func hearthShadow(_ token: ShadowToken) -> some View {
        shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
}
