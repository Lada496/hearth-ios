import XCTest
@testable import Hearth

@MainActor
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
        let result = try await stt.transcribe(AudioBuffer(samples: [0.1, -0.1]))

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
        _ = try await stt.transcribe(AudioBuffer(samples: []))
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(start), 0.05)
    }

    func testMockSTTPropagatesCancellation() async {
        let stt = MockSTT()
        stt.transcribeDelaySeconds = 1

        let task = Task {
            try await stt.transcribe(AudioBuffer(samples: []))
        }
        await Task.yield()
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("expected cancellation to be thrown")
        } catch is CancellationError {
            // expected
        } catch {
            XCTFail("expected CancellationError, got \(error)")
        }
    }

    func testMockSTTInjectedFailure() async {
        let stt = MockSTT()
        stt.errorToThrow = .audioTooShort

        do {
            _ = try await stt.transcribe(AudioBuffer(samples: []))
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

    // MARK: - ViewModel pipeline (acceptance criterion: runs without model assets)

    func testInjectedViewModelRunsFullMockPipelineWithoutModelAssets() async throws {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada kupata makazi.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )

        let translator = MockTranslator()
        translator.resultToReturn = "I need help finding shelter."

        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]

        let viewModel = TestPipelineViewModel(
            speechToText: stt,
            translationEngine: translator,
            textToSpeech: tts
        )
        let translated = try await viewModel.run(
            AudioBuffer(samples: [0]),
            fallbackSource: TestFixtures.FixtureLanguage.swahili,
            target: TestFixtures.FixtureLanguage.english
        )

        XCTAssertEqual(translated, "I need help finding shelter.")
        XCTAssertEqual(stt.transcribeCallCount, 1)
        XCTAssertEqual(translator.translateCallCount, 1)
        XCTAssertEqual(tts.speakCallCount, 1)
    }
}

@MainActor
private final class TestPipelineViewModel {
    private let speechToText: SpeechToText
    private let translationEngine: TranslationEngine
    private let textToSpeech: TextToSpeech

    init(
        speechToText: SpeechToText,
        translationEngine: TranslationEngine,
        textToSpeech: TextToSpeech
    ) {
        self.speechToText = speechToText
        self.translationEngine = translationEngine
        self.textToSpeech = textToSpeech
    }

    func run(
        _ audio: AudioBuffer,
        fallbackSource: Language,
        target: Language
    ) async throws -> String {
        try await speechToText.prepare()
        try await translationEngine.prepare()

        let transcription = try await speechToText.transcribe(audio)
        let translated = try await translationEngine.translate(
            transcription.text,
            from: transcription.detectedLanguage ?? fallbackSource,
            to: target
        )

        if textToSpeech.supports(target) {
            try await textToSpeech.speak(translated, language: target)
        }
        return translated
    }
}
