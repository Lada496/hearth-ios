import XCTest
@testable import Hearth

@MainActor
final class ConversationViewModelTests: XCTestCase {
    private func makeViewModel(
        stt: MockSTT = MockSTT(),
        translator: MockTranslator = MockTranslator(),
        tts: MockTTS = MockTTS()
    ) -> ConversationViewModel {
        ConversationViewModel(speechToText: stt, translationEngine: translator, textToSpeech: tts)
    }

    private let someAudio = AudioBuffer(pcmData: Data([0x00, 0x01]))

    // MARK: - Both directions, end to end

    func testResidentTurnSetsResidentLanguageAndAppendsMessage() async {
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

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages[0].translatedText, "I need help.")
        XCTAssertEqual(viewModel.messages[0].speaker, .resident)
        XCTAssertEqual(viewModel.residentLanguage, TestFixtures.FixtureLanguage.swahili)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertNil(viewModel.error)
    }

    func testWorkerTurnTranslatesIntoKnownResidentLanguage() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )
        let translator = MockTranslator()
        let viewModel = makeViewModel(stt: stt, translator: translator)

        // Establish resident language first.
        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)

        translator.resultToReturn = "Tuna kitanda kinachopatikana."
        await viewModel.send("We have a bed available.", speaker: .worker)

        XCTAssertEqual(viewModel.messages.count, 2)
        let workerMessage = viewModel.messages[1]
        XCTAssertEqual(workerMessage.speaker, .worker)
        XCTAssertEqual(workerMessage.translatedText, "Tuna kitanda kinachopatikana.")
        XCTAssertEqual(workerMessage.targetLanguage, TestFixtures.FixtureLanguage.swahili)
    }

    // MARK: - Missing resident language

    func testWorkerSendBlockedWhenResidentLanguageUnknown() async {
        let viewModel = makeViewModel()

        await viewModel.send("Hello", speaker: .worker)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testWorkerFinishRecordingBlockedWhenResidentLanguageUnknown() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(text: "We have a bed.")
        let viewModel = makeViewModel(stt: stt)

        viewModel.startRecording(.worker)
        await viewModel.finishRecording(.worker, audio: someAudio)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.phase, .idle)
    }

    // MARK: - Concurrency guards

    func testStartRecordingNoOpsWhenNotIdle() async {
        let viewModel = makeViewModel()

        viewModel.startRecording(.resident)
        viewModel.startRecording(.worker)

        XCTAssertEqual(viewModel.phase, .recording(.resident), "second start should be ignored")
    }

    func testFinishRecordingIgnoresWrongSpeaker() async {
        let viewModel = makeViewModel()

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.worker, audio: someAudio)

        XCTAssertEqual(viewModel.phase, .recording(.resident), "stop for the wrong speaker should be ignored")
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testFinishRecordingNoOpsWhenNotRecording() async {
        let viewModel = makeViewModel()

        await viewModel.finishRecording(.resident, audio: someAudio)

        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testSendNoOpsWhenNotIdle() async {
        let viewModel = makeViewModel()
        viewModel.startRecording(.resident)

        await viewModel.send("Hello", speaker: .resident)

        XCTAssertTrue(viewModel.messages.isEmpty, "send should be ignored while a recording is in flight")
    }

    // MARK: - Empty input

    func testEmptyTranscriptIsNoOpAndReturnsToIdle() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(text: "   ")
        let viewModel = makeViewModel(stt: stt)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNil(viewModel.error, "an empty transcript is a quiet no-op, not an error")
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testEmptyTextSendIsNoOp() async {
        let viewModel = makeViewModel()

        await viewModel.send("   ", speaker: .resident)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Per-engine failure

    func testSTTFailureSetsErrorAndReturnsToIdle() async {
        let stt = MockSTT()
        stt.errorToThrow = .audioTooShort
        let viewModel = makeViewModel(stt: stt)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)

        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testTranslationFailureSetsErrorAndReturnsToIdle() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )
        let translator = MockTranslator()
        translator.errorToThrow = .translationFailed(reason: "model unavailable")
        let viewModel = makeViewModel(stt: stt, translator: translator)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)

        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    // MARK: - Replay

    func testReplaySpeaksSupportedLanguageAndClearsPlayingID() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.english
        )
        let tts = MockTTS()
        tts.supportedLanguageCodes = ["en"]
        let viewModel = makeViewModel(stt: stt, tts: tts)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        let messageID = viewModel.messages[0].id

        await viewModel.replay(messageID)

        XCTAssertEqual(tts.speakCallCount, 1)
        XCTAssertNil(viewModel.playingMessageID, "should clear once playback finishes")
    }

    func testReplayNoOpsForUnsupportedLanguage() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )
        let tts = MockTTS() // no supported codes configured
        let viewModel = makeViewModel(stt: stt, tts: tts)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        await viewModel.replay(viewModel.messages[0].id)

        XCTAssertEqual(tts.speakCallCount, 0)
    }

    func testReplayNoOpsForUnknownMessageID() async {
        let tts = MockTTS()
        let viewModel = makeViewModel(tts: tts)

        await viewModel.replay(UUID())

        XCTAssertEqual(tts.speakCallCount, 0)
    }

    // MARK: - Error dismissal and idle recovery

    func testDismissErrorClearsError() async {
        let stt = MockSTT()
        stt.errorToThrow = .audioTooShort
        let viewModel = makeViewModel(stt: stt)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        XCTAssertNotNil(viewModel.error)

        viewModel.dismissError()

        XCTAssertNil(viewModel.error)
    }

    func testIdleRecoveryAfterFailureAllowsNextTurnToSucceed() async {
        let stt = MockSTT()
        stt.errorToThrow = .audioTooShort
        let translator = MockTranslator()
        let viewModel = makeViewModel(stt: stt, translator: translator)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        XCTAssertNotNil(viewModel.error)

        // Fix the mock and confirm a subsequent turn works normally.
        stt.errorToThrow = nil
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )
        translator.resultToReturn = "I need help."

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Session end

    func testEndSessionResetsAllState() async {
        let stt = MockSTT()
        stt.resultToReturn = SpeechToTextResult(
            text: "Ninahitaji msaada.",
            detectedLanguage: TestFixtures.FixtureLanguage.swahili
        )
        let viewModel = makeViewModel(stt: stt)

        viewModel.startRecording(.resident)
        await viewModel.finishRecording(.resident, audio: someAudio)
        XCTAssertFalse(viewModel.messages.isEmpty)

        viewModel.endSession()

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.phase, .idle)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.playingMessageID)
        XCTAssertNil(viewModel.residentLanguage)
    }
}
