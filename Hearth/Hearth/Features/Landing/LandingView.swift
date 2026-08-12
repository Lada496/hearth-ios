import SwiftUI

/// The landing screen (UI-SPEC.md §3, `screenshots/landing.png`). Pure presentation — the
/// CTA action is injected by the caller (`AppRootView`) rather than this view owning
/// navigation, so a future composition root can swap in real conversation setup (engine
/// preparation, etc.) without changing this file.
struct LandingView: View {
    let onStart: () -> Void

    @State private var isPressed = false

    var body: some View {
        ZStack {
            Color.Hearth.sideTop
                .ignoresSafeArea()

            VStack(spacing: SpacingHearth.landingContentGap) {
                Text("Hearth")
                    .hearthTypography(TypographyHearth.landingTitle)
                    .foregroundStyle(Color.Hearth.headingInk)

                Text("Real-time translation, face to face")
                    .hearthTypography(TypographyHearth.landingSubtitle)
                    .foregroundStyle(Color.Hearth.headingInk)

                Button(action: onStart) {
                    Text("Start conversation")
                        .hearthTypography(TypographyHearth.ctaButton)
                        .foregroundStyle(Color.Hearth.textOnWarmth)
                        .padding(.vertical, SpacingHearth.ctaVerticalPadding)
                        .padding(.horizontal, SpacingHearth.ctaHorizontalPadding)
                        .frame(minHeight: 44)
                        .background(Color.Hearth.warmth, in: Capsule())
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.98 : 1)
                .animation(.easeOut(duration: 0.1), value: isPressed)
                .accessibilityLabel("Start conversation")
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
            }
        }
    }
}

#Preview {
    LandingView(onStart: {})
}
