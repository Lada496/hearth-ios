/// The app's top-level navigation state, owned by the app shell (`AppRootView`). Deliberately
/// a plain enum, not a `NavigationStack` path — there is no back-navigation between these two
/// screens; the router just switches which one is shown, per issue #18.
enum AppRoute: Equatable {
    case landing

    /// Placeholder destination after the landing CTA. Real conversation UI/composition lands
    /// in #19 and #31 — out of scope here.
    case conversationPlaceholder
}
