import XCTest

@MainActor
final class HearthUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchDisplaysLandingScreen() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Hearth"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Real-time translation, face to face"].exists)
        XCTAssertTrue(app.buttons["Start conversation"].exists)
    }

    func testTappingCTANavigatesToConversationPlaceholder() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Start conversation"].tap()

        XCTAssertTrue(app.staticTexts["Conversation"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Start conversation"].exists)
    }
}
