import XCTest
@testable import Hearth

@MainActor
final class AppRouterTests: XCTestCase {
    func testInitialRouteIsLanding() {
        let router = AppRouter()
        XCTAssertEqual(router.route, .landing)
    }

    func testStartNavigatesToConversationPlaceholder() {
        let router = AppRouter()
        router.start()
        XCTAssertEqual(router.route, .conversationPlaceholder)
    }
}
