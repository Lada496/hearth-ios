import XCTest

@MainActor
final class HearthUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchesNeutralAppShell() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Hearth"].waitForExistence(timeout: 5))
    }
}
