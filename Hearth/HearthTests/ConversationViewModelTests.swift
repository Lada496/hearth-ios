import XCTest
@testable import Hearth

@MainActor
final class ConversationViewModelTests: XCTestCase {
    private let someAudio = AudioBuffer(samples: [0, 0.1])

    private func makeViewModel(
        stt: MockSTT? = nil,
        translator: MockTranslator? = nil,
        tts: MockTTS? = nil,
        residentLanguage: Language? = nil
    ) -> ConversationViewModel {
        ConversationViewModel(
            speechToText: stt ?? MockSTT(),
            translationEngine: translator ?? MockTranslator(),
            textToSpeech: tts ?? MockTTS(),
            residentLanguage: residentLanguage
        )
    }

    private func makeWorkerMessage(tts: MockTTS) async -> ConversationViewModel {
        let translator = MockTranslator()
        translator.resultToReturn = "Tuna kitanda kinachopatikana."
        let viewModel = makeViewModel(
            translator: translator,
            tts: tts,
            residentLanguage: TestFixtures.FixtureLanguage.swahili
        )
        await viewModel.send("We have a bed available.", speaker: .worker)
        return viewModel
    }

    private func waitForTranslationStart(_ translator: MockTranslator) async {
        for _ in 0..<100 {
            if translator.translateCallCount == 1 {
                return
            }
            await Task.yield()
        }
        XCTFail("translation did not start")
    }

    func testResidentVoiceTurnDetectsLanguageAndTranslatesToWorker() async throws {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )
        let translator = MockTranslator()
        translator.resultToReturn = "I need help."
        let viewModel = makeViewModel(stt: stt, translator: translator)
        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        let message = try XCTUnwrap(viewModel.messages.first)
        XCTAssertEqual(message.translatedText, "I need help.")
        XCTAssertEqual(message.sourceLanguage, TestFixtures.FixtureLanguage.swahili)
        XCTAssertEqual(message.targetLanguage.code, "en")
        XCTAssertEqual(viewModel.residentLanguage, TestFixtures.FixtureLanguage.swahili)
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testWorkerTypedTurnTranslatesToInjectedResidentLanguage() async throws {
        let viewModel = await makeWorkerMessage(tts: MockTTS())
        let message = try XCTUnwrap(viewModel.messages.first)
        XCTAssertEqual(message.speaker, .worker)
        XCTAssertEqual(message.translatedText, "Tuna kitanda kinachopatikana.")
        XCTAssertEqual(message.targetLanguage, TestFixtures.FixtureLanguage.swahili)
    }

    func testTypedAndVoiceWorkerTurnsRequireResidentLanguage() async {
        let translator = MockTranslator()
        let viewModel = makeViewModel(translator: translator)
        await viewModel.send("Hello", speaker: .worker)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNotNil(viewModel.error)
        viewModel.startRecording(.worker)
        await viewModel.finishRecording(.worker, audio: someAudio)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(translator.translateCallCount, 0)
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testOverlappingIntentsAreIgnored() async {
        let stt = MockSTT()
        let viewModel = makeViewModel(stt: stt)
        viewModel.startRecording(.resident)
        viewModel.startRecording(.worker)
        await viewModel.send("Hello", speaker: .worker)
        await viewModel.finishRecording(.worker, audio: someAudio)
        XCTAssertEqual(viewModel.phase, .recording(.resident))
        XCTAssertEqual(stt.transcribeCallCount, 0)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testBlankTypedAndVoiceInputsAreQuietNoOps() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(text: "   ")
        let viewModel = makeViewModel(stt: stt)
        await viewModel.send("   ", speaker: .resident)
        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testSTTFailureSetsReadableErrorAndReturnsToIdle() async {
        let stt = MockSTT()
        stt.errorToThrow = .audioTooShort
        let viewModel = makeViewModel(stt: stt)
        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        XCTAssertEqual(viewModel.error, "That was too short to hear. Hold the button and speak.")
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testTranslationFailureRecoversForNextTurn() async {
        let translator = MockTranslator()
        translator.errorToThrow = .translationFailed(reason: "unavailable")
        let viewModel = makeViewModel(
            translator: translator,
            residentLanguage: TestFixtures.FixtureLanguage.swahili
        )
        await viewModel.send("Hello", speaker: .worker)
        XCTAssertEqual(viewModel.error, "Couldn't translate that. Please try again.")
        XCTAssertEqual(viewModel.phase, .idle)
        translator.errorToThrow = nil
        translator.resultToReturn = "Jambo"
        await viewModel.send("Hello", speaker: .worker)
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertNil(viewModel.error)
    }

    func testReplayChoosesTextAndLanguageForEachViewer() async throws {
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en", "sw"]
        let viewModel = await makeWorkerMessage(tts: tts)
        let message = try XCTUnwrap(viewModel.messages.first)
        await viewModel.replay(message.id, for: .worker)
        XCTAssertEqual(tts.lastSpokenText, message.originalText)
        XCTAssertEqual(tts.lastSpokenLanguage, message.sourceLanguage)
        await viewModel.replay(message.id, for: .resident)
        XCTAssertEqual(tts.lastSpokenText, message.translatedText)
        XCTAssertEqual(tts.lastSpokenLanguage, message.targetLanguage)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertNil(viewModel.playingMessageID)
    }

    func testReplayQuietlyIgnoresUnsupportedOverlapAndUnknownMessage() async throws {
        let tts = MockTTS()
        let viewModel = await makeWorkerMessage(tts: tts)
        let message = try XCTUnwrap(viewModel.messages.first)
        await viewModel.replay(message.id, for: .resident)
        XCTAssertEqual(tts.speakCallCount, 0)
        XCTAssertNil(viewModel.error)
        tts.supportedLanguageCodes = ["sw"]
        viewModel.startRecording(.resident)
        await viewModel.replay(message.id, for: .resident)
        XCTAssertEqual(tts.speakCallCount, 0)
        XCTAssertEqual(viewModel.phase, .recording(.resident))
        let emptyViewModel = makeViewModel(tts: tts)
        await emptyViewModel.replay(UUID(), for: .worker)
        XCTAssertEqual(tts.speakCallCount, 0)
    }

    func testReplayFailureSetsReadableErrorAndRecoversState() async throws {
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["sw"]
        tts.errorToThrow = .synthesisFailed(reason: "voice unavailable")
        let viewModel = await makeWorkerMessage(tts: tts)
        let message = try XCTUnwrap(viewModel.messages.first)
        await viewModel.replay(message.id, for: .resident)
        XCTAssertEqual(viewModel.error, "Could not play that message. You can still read the translation.")
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertNil(viewModel.playingMessageID)
    }

    func testEndSessionStopsSpeechAndClearsEverySessionValue() async {
        let tts = MockTTS()
        let viewModel = await makeWorkerMessage(tts: tts)
        viewModel.endSession()
        XCTAssertEqual(tts.stopCallCount, 1)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.playingMessageID)
        XCTAssertNil(viewModel.residentLanguage)
    }

    func testEndSessionInvalidatesInFlightTranslationDeterministically() async {
        let translator = MockTranslator()
        translator.translateDelaySeconds = 0.1
        translator.resultToReturn = "Jambo"
        let tts = MockTTS()
        let viewModel = makeViewModel(
            translator: translator,
            tts: tts,
            residentLanguage: TestFixtures.FixtureLanguage.swahili
        )
        let task = Task {
            await viewModel.send("Hello", speaker: .worker)
        }
        await waitForTranslationStart(translator)
        viewModel.endSession()
        await task.value
        XCTAssertEqual(translator.translateCallCount, 1)
        XCTAssertEqual(tts.stopCallCount, 1)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.playingMessageID)
        XCTAssertNil(viewModel.residentLanguage)
    }
}
