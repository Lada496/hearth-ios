import XCTest
@testable import Hearth

@MainActor
final class HearthTests: XCTestCase {
    func testAppRootViewCanBeConstructedWithoutModelResources() {
        _ = AppRootView()
    }
}
