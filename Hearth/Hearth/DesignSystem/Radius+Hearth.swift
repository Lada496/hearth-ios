import CoreGraphics

/// Corner-radius tokens from UI-SPEC.md. Views must reference these tokens and never
/// hard-code radius values.
enum RadiusHearth {
    /// Fully rounded pills (CTA button, capsules). Use `Capsule()` where the shape allows it.
    static let pill: CGFloat = 100

    /// Message bubble corners, except the corner nearest the sender.
    static let bubble: CGFloat = 16

    /// The single sharp corner nearest the sender on a message bubble.
    static let bubbleSenderCorner: CGFloat = 4

    /// Error toast.
    static let toast: CGFloat = 12

    /// Glass input card / center divider container.
    static let card: CGFloat = 14
}
