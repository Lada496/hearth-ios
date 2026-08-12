import Observation

/// Owns the app's top-level route so navigation logic is testable independent of any SwiftUI
/// view (`AppRootView` just renders whatever `route` currently is). This is the
/// dependency-injection seam issue #18 asks for: a future ticket can construct `AppRootView`
/// with a differently-configured router (or replace `start()`'s behavior) without touching
/// this file's callers.
@MainActor
@Observable
final class AppRouter {
    private(set) var route: AppRoute = .landing

    /// Landing's CTA action. Placeholder destination only — real conversation composition
    /// (engine construction, etc.) is out of scope for #18.
    func start() {
        route = .conversationPlaceholder
    }
}
