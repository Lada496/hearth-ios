import XCTest
@testable import Hearth

final class MessagePresentationTests: XCTestCase {
    func testPerspectiveUsesViewerSpecificTextAndLanguage() {
        let message = TestFixtures.FixtureMessage.workerTurn

        XCTAssertTrue(MessagePresentationPerspective.isOwnMessage(message, for: .worker))
        XCTAssertEqual(MessagePresentationPerspective.text(for: message, viewer: .worker), message.originalText)
        XCTAssertEqual(MessagePresentationPerspective.language(for: message, viewer: .worker), message.sourceLanguage)

        XCTAssertFalse(MessagePresentationPerspective.isOwnMessage(message, for: .resident))
        XCTAssertEqual(MessagePresentationPerspective.text(for: message, viewer: .resident), message.translatedText)
        XCTAssertEqual(MessagePresentationPerspective.language(for: message, viewer: .resident), message.targetLanguage)
    }

    func testLanguageLabelUsesRuntimeFlagWhenPresent() {
        XCTAssertEqual(
            MessagePresentationPerspective.languageLabel(for: TestFixtures.FixtureLanguage.english),
            "🇬🇧 English"
        )
        let language = Language(code: "xx", displayName: "Example")
        XCTAssertEqual(MessagePresentationPerspective.languageLabel(for: language), "Example")
    }
}
