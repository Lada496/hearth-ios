import XCTest
@testable import Hearth

final class EngineProtocolTests: XCTestCase {
    // MARK: - SpeechToText

    func testMockSTTSuccessPath() async throws {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili,
            confidence: 0.92
        )

        try await stt.prepare()
        let result = try await stt.transcribe(AudioBuffer(pcmData: Data([0x01, 0x02])))

        XCTAssertEqual(result.text, "Ninahitaji msaada.")
        XCTAssertEqual(result.detectedLanguage, TestFixtures.FixtureLanguage.swahili)
        XCTAssertEqual(result.confidence, 0.92)
        XCTAssertEqual(stt.prepareCallCount, 1)
        XCTAssertEqual(stt.transcribeCallCount, 1)
    }

    func testMockSTTHonorsConfiguredDelay() async throws {
        let stt = MockSTT()
        stt.transcribeDelaySeconds = 0.05

        let start = Date()
        _ = try await stt.transcribe(AudioBuffer(pcmData: Data()))
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(start), 0.05)
    }

    func testMockSTTInjectedFailure() async {
        let stt = MockSTT()
        stt.errorToThrow = .audioTooShort

        do {
            _ = try await stt.transcribe(AudioBuffer(pcmData: Data()))
            XCTFail("expected audioTooShort to be thrown")
        } catch SpeechToTextError.audioTooShort {
            // expected
        } catch {
            XCTFail("expected SpeechToTextError.audioTooShort, got \(error)")
        }
    }

    // MARK: - TranslationEngine

    func testMockTranslatorSuccessPath() async throws {
        let translator = MockTranslator()
        translator.resultToReturn = "I need help."

        try await translator.prepare()
        let result = try await translator.translate(
            "Ninahitaji msaada.",
            from: TestFixtures.FixtureLanguage.swahili,
            to: TestFixtures.FixtureLanguage.english
        )

        XCTAssertEqual(result, "I need help.")
        XCTAssertEqual(translator.prepareCallCount, 1)
        XCTAssertEqual(translator.translateCallCount, 1)
    }

    func testMockTranslatorRejectsEmptyInput() async {
        let translator = MockTranslator()

        do {
            _ = try await translator.translate(
                "",
                from: TestFixtures.FixtureLanguage.english,
                to: TestFixtures.FixtureLanguage.swahili
            )
            XCTFail("expected emptyInput to be thrown")
        } catch TranslationError.emptyInput {
            // expected
        } catch {
            XCTFail("expected TranslationError.emptyInput, got \(error)")
        }
    }

    func testMockTranslatorInjectedFailure() async {
        let translator = MockTranslator()
        translator.errorToThrow = .translationFailed(reason: "model unavailable")

        do {
            _ = try await translator.translate(
                "hello",
                from: TestFixtures.FixtureLanguage.english,
                to: TestFixtures.FixtureLanguage.swahili
            )
            XCTFail("expected translationFailed to be thrown")
        } catch TranslationError.translationFailed(let reason) {
            XCTAssertEqual(reason, "model unavailable")
        } catch {
            XCTFail("expected TranslationError.translationFailed, got \(error)")
        }
    }

    // MARK: - TextToSpeech

    func testMockTTSSupportsConfiguredLanguagesOnly() {
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]

        XCTAssertTrue(tts.supports(TestFixtures.FixtureLanguage.english))
        XCTAssertFalse(tts.supports(TestFixtures.FixtureLanguage.swahili))
    }

    func testMockTTSSpeaksSupportedLanguage() async throws {
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]

        try await tts.prepare()
        try await tts.speak("Hello", language: TestFixtures.FixtureLanguage.english)

        XCTAssertEqual(tts.speakCallCount, 1)
    }

    func testMockTTSThrowsForUnsupportedLanguage() async {
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]

        do {
            try await tts.speak("Jambo", language: TestFixtures.FixtureLanguage.swahili)
            XCTFail("expected unsupportedLanguage to be thrown")
        } catch TextToSpeechError.unsupportedLanguage {
            // expected
        } catch {
            XCTFail("expected TextToSpeechError.unsupportedLanguage, got \(error)")
        }
    }

    func testMockTTSInjectedFailure() async {
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]
        tts.errorToThrow = .synthesisFailed(reason: "voice unavailable")

        do {
            try await tts.speak("Hello", language: TestFixtures.FixtureLanguage.english)
            XCTFail("expected synthesisFailed to be thrown")
        } catch TextToSpeechError.synthesisFailed(let reason) {
            XCTAssertEqual(reason, "voice unavailable")
        } catch {
            XCTFail("expected TextToSpeechError.synthesisFailed, got \(error)")
        }
    }

    func testMockTTSStopIsSafeToCallAnytime() {
        let tts = MockTTS()
        tts.stop()
        XCTAssertEqual(tts.stopCallCount, 1)
    }

    // MARK: - Full mock pipeline (acceptance criterion: runs without model assets)

    func testFullMockPipelineRunsWithoutModelAssets() async throws {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada kupata makazi.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )

        let translator = MockTranslator()
        translator.resultToReturn = "I need help finding shelter."

        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]

        try await stt.prepare()
        try await translator.prepare()
        try await tts.prepare()

        let transcription = try await stt.transcribe(AudioBuffer(pcmData: Data([0x00])))
        let translated = try await translator.translate(
            transcription.text,
            from: transcription.detectedLanguage ?? TestFixtures.FixtureLanguage.swahili,
            to: TestFixtures.FixtureLanguage.english
        )
        try await tts.speak(translated, language: TestFixtures.FixtureLanguage.english)

        XCTAssertEqual(translated, "I need help finding shelter.")
        XCTAssertEqual(stt.transcribeCallCount, 1)
        XCTAssertEqual(translator.translateCallCount, 1)
        XCTAssertEqual(tts.speakCallCount, 1)
    }
}
