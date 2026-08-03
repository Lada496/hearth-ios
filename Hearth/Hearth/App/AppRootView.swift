import SwiftUI

/// The app shell: renders whatever `AppRouter.route` currently is, behind the app-wide
/// paper-grain overlay (UI-SPEC.md §1, applied once here "at the root" per spec, not
/// per-screen). Route switches fade over 200 ms, matching the reference's `page.tsx`
/// `fadeOut` transition timing.
struct AppRootView: View {
    @State private var router = AppRouter()

    var body: some View {
        Group {
            switch router.route {
            case .landing:
                LandingView(onStart: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        router.start()
                    }
                })
            case .conversationPlaceholder:
                ConversationPlaceholderView()
            }
        }
        .transition(.opacity)
        .hearthGrainOverlay()
    }
}

/// Stands in for the real conversation screen until #19/#31 land. Intentionally minimal —
/// building conversation UI or engine composition is explicitly out of scope for #18.
private struct ConversationPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.Hearth.sideBottom.ignoresSafeArea()
            Text("Conversation")
                .hearthTypography(TypographyHearth.appBodyBold)
                .foregroundStyle(Color.Hearth.headingInk)
        }
    }
}

#Preview {
    AppRootView()
}
