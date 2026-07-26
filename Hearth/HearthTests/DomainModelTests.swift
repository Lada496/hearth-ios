import XCTest
@testable import Hearth

final class DomainModelTests: XCTestCase {
    // MARK: - Language normalization

    func testLanguageCodeIsLowercased() {
        let language = Language(code: "EN", displayName: "English")
        XCTAssertEqual(language.code, "en")
    }

    func testLanguageCodeIsTrimmed() {
        let language = Language(code: "  sw \n", displayName: "Kiswahili")
        XCTAssertEqual(language.code, "sw")
    }

    // MARK: - Language equality

    func testLanguagesWithSameFieldsAreEqual() {
        let lowercase = Language(code: "en", displayName: "English", flag: "🇬🇧")
        let uppercase = Language(code: "EN", displayName: "English", flag: "🇬🇧")
        XCTAssertEqual(
            lowercase,
            uppercase,
            "normalization should make differently-cased codes compare equal"
        )
    }

    func testLanguagesWithDifferentCodesAreNotEqual() {
        let english = Language(code: "en", displayName: "English")
        let swahili = Language(code: "sw", displayName: "Kiswahili")
        XCTAssertNotEqual(english, swahili)
    }

    // MARK: - Fixture integrity (#if DEBUG only, matches production exclusion of TestFixtures)

    func testFixtureLanguageCodesAreNormalized() {
        XCTAssertEqual(TestFixtures.FixtureLanguage.english.code, "en")
        XCTAssertEqual(TestFixtures.FixtureLanguage.swahili.code, "sw")
        XCTAssertEqual(TestFixtures.FixtureLanguage.arabic.code, "ar")
    }

    func testFixtureMessagesConstructWithExpectedLanguagePair() {
        let residentTurn = TestFixtures.FixtureMessage.residentTurn
        XCTAssertEqual(residentTurn.speaker, .resident)
        XCTAssertEqual(residentTurn.sourceLanguage, TestFixtures.FixtureLanguage.swahili)
        XCTAssertEqual(residentTurn.targetLanguage, TestFixtures.FixtureLanguage.english)
        XCTAssertFalse(residentTurn.hasPlayableAudio)

        let workerTurn = TestFixtures.FixtureMessage.workerTurn
        XCTAssertEqual(workerTurn.speaker, .worker)
        XCTAssertTrue(workerTurn.hasPlayableAudio)
    }

    // MARK: - Message construction

    func testMessageDefaultsGenerateUniqueIDs() {
        let first = Message(
            speaker: .resident,
            originalText: "a",
            translatedText: "b",
            sourceLanguage: TestFixtures.FixtureLanguage.swahili,
            targetLanguage: TestFixtures.FixtureLanguage.english
        )
        let second = Message(
            speaker: .resident,
            originalText: "a",
            translatedText: "b",
            sourceLanguage: TestFixtures.FixtureLanguage.swahili,
            targetLanguage: TestFixtures.FixtureLanguage.english
        )
        XCTAssertNotEqual(first.id, second.id)
    }

    func testMessageEqualityIsFieldwise() {
        let sharedID = UUID()
        let timestamp = Date()

        let first = Message(
            id: sharedID,
            speaker: .worker,
            originalText: "Hello",
            translatedText: "Jambo",
            sourceLanguage: TestFixtures.FixtureLanguage.english,
            targetLanguage: TestFixtures.FixtureLanguage.swahili,
            timestamp: timestamp
        )
        let second = Message(
            id: sharedID,
            speaker: .worker,
            originalText: "Hello",
            translatedText: "Jambo",
            sourceLanguage: TestFixtures.FixtureLanguage.english,
            targetLanguage: TestFixtures.FixtureLanguage.swahili,
            timestamp: timestamp
        )
        XCTAssertEqual(first, second)
    }

    // MARK: - SessionPhase equality

    func testSessionPhaseEqualityIncludesAssociatedSpeaker() {
        XCTAssertEqual(SessionPhase.idle, SessionPhase.idle)
        XCTAssertEqual(SessionPhase.recording(.resident), SessionPhase.recording(.resident))
        XCTAssertNotEqual(SessionPhase.recording(.resident), SessionPhase.recording(.worker))
        XCTAssertNotEqual(SessionPhase.recording(.resident), SessionPhase.transcribing(.resident))
    }
}
