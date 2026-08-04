import Foundation
import Observation

/// Drives one in-memory conversation session through injected engine protocols.
/// `endSession()` wipes every session value (ADR-006).
@MainActor
@Observable
final class ConversationViewModel {
    private(set) var messages: [Message] = []
    private(set) var phase: SessionPhase = .idle
    private(set) var error: String?
    private(set) var playingMessageID: UUID?

    /// Set by voice detection or an injected debug/test fixture (PRD §3).
    private(set) var residentLanguage: Language?

    private let speechToText: SpeechToText
    private let translationEngine: TranslationEngine
    private let textToSpeech: TextToSpeech
    private let workerLanguage: Language
    @ObservationIgnored private var sessionGeneration = 0

    init(
        speechToText: SpeechToText,
        translationEngine: TranslationEngine,
        textToSpeech: TextToSpeech,
        workerLanguage: Language? = nil,
        residentLanguage: Language? = nil
    ) {
        self.speechToText = speechToText
        self.translationEngine = translationEngine
        self.textToSpeech = textToSpeech
        self.workerLanguage = workerLanguage ?? Language(code: "en", displayName: "English")
        self.residentLanguage = residentLanguage
    }

    func startRecording(_ speaker: Speaker) {
        guard case .idle = phase else { return }
        error = nil
        phase = .recording(speaker)
    }

    func finishRecording(_ speaker: Speaker, audio: AudioBuffer) async {
        guard case .recording(let recordingSpeaker) = phase, recordingSpeaker == speaker else {
            return
        }
        let generation = sessionGeneration
        phase = .transcribing(speaker)
        do {
            let transcription = try await speechToText.transcribe(audio)
            guard generation == sessionGeneration else { return }
            let transcript = transcription.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !transcript.isEmpty else {
                phase = .idle
                return
            }
            if speaker == .resident, let detected = transcription.detectedLanguage {
                residentLanguage = detected
            }
            await translateAndAppend(transcript, speaker: speaker)
        } catch let sttError as SpeechToTextError {
            guard generation == sessionGeneration else { return }
            error = Self.userFacingMessage(for: sttError)
            phase = .idle
        } catch {
            guard generation == sessionGeneration else { return }
            self.error = "Something went wrong understanding that. Please try again."
            phase = .idle
        }
    }

    func send(_ text: String, speaker: Speaker) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, case .idle = phase else { return }
        guard residentLanguage != nil else {
            error = "We don't know the resident's language yet. Have them speak first."
            return
        }
        error = nil
        await translateAndAppend(trimmed, speaker: speaker)
    }

    /// Replay the message text facing `viewer`. Unsupported languages stay text-only.
    func replay(_ messageID: UUID, for viewer: Speaker) async {
        guard case .idle = phase, playingMessageID == nil else { return }
        guard let message = messages.first(where: { $0.id == messageID }) else { return }
        let isOriginalSide = message.speaker == viewer
        let text = isOriginalSide ? message.originalText : message.translatedText
        let language = isOriginalSide ? message.sourceLanguage : message.targetLanguage
        guard textToSpeech.supports(language) else { return }
        let generation = sessionGeneration
        playingMessageID = messageID
        phase = .speaking(message.speaker)
        defer {
            if generation == sessionGeneration {
                playingMessageID = nil
                phase = .idle
            }
        }
        do {
            try await textToSpeech.speak(text, language: language)
        } catch {
            guard generation == sessionGeneration else { return }
            self.error = "Could not play that message. You can still read the translation."
        }
    }

    func dismissError() {
        error = nil
    }

    /// Stop speech, invalidate async work, and wipe all in-memory session state.
    func endSession() {
        sessionGeneration += 1
        textToSpeech.stop()
        messages = []
        phase = .idle
        error = nil
        playingMessageID = nil
        residentLanguage = nil
    }

    private func translateAndAppend(_ text: String, speaker: Speaker) async {
        let sourceLanguage: Language
        let targetLanguage: Language
        switch speaker {
        case .resident:
            guard let residentLanguage else {
                error = "We don't know the resident's language yet."
                phase = .idle
                return
            }
            sourceLanguage = residentLanguage
            targetLanguage = workerLanguage
        case .worker:
            guard let residentLanguage else {
                error = "We don't know the resident's language yet. Have them speak first."
                phase = .idle
                return
            }
            sourceLanguage = workerLanguage
            targetLanguage = residentLanguage
        }
        let generation = sessionGeneration
        phase = .translating(speaker)
        do {
            let translated = try await translationEngine.translate(
                text,
                from: sourceLanguage,
                to: targetLanguage
            )
            guard generation == sessionGeneration else { return }
            let message = Message(
                speaker: speaker,
                originalText: text,
                translatedText: translated,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
            messages.append(message)
            phase = .idle
        } catch let translationError as TranslationError {
            guard generation == sessionGeneration else { return }
            error = Self.userFacingMessage(for: translationError)
            phase = .idle
        } catch {
            guard generation == sessionGeneration else { return }
            self.error = "Something went wrong translating that. Please try again."
            phase = .idle
        }
    }

    private static func userFacingMessage(for error: SpeechToTextError) -> String {
        switch error {
        case .notPrepared:
            return "Still getting ready. Please wait a moment and try again."
        case .audioTooShort:
            return "That was too short to hear. Hold the button and speak."
        case .transcriptionFailed:
            return "Couldn't understand that. Please try again."
        }
    }

    private static func userFacingMessage(for error: TranslationError) -> String {
        switch error {
        case .notPrepared:
            return "Still getting ready. Please wait a moment and try again."
        case .emptyInput:
            return "Nothing to translate."
        case .translationFailed:
            return "Couldn't translate that. Please try again."
        }
    }
}
