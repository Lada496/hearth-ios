import Foundation
import Observation

/// Drives one conversation session against the frozen engine protocols (#8). Views must call
/// only the intent methods below — never `SpeechToText`/`TranslationEngine`/`TextToSpeech`
/// directly. Ports the guards from `reference/frontend/hooks.ts` `useConversation` (lines
/// 35-254), adapted for on-device engines that need an explicit source/target `Language`
/// rather than the prototype's backend auto-detection.
///
/// In-memory only — `endSession()` wipes everything (ADR-006); no persistence, no singleton.
@MainActor
@Observable
final class ConversationViewModel {
    private(set) var messages: [Message] = []
    private(set) var phase: SessionPhase = .idle
    private(set) var error: String?
    private(set) var playingMessageID: UUID?

    /// The resident's language, once known from a voice turn's detection (or a test/debug
    /// fixture). `nil` means no resident turn has happened yet this session — per PRD §3,
    /// typed exchange in either direction needs this already established, since only voice
    /// detection (not typed text) can determine what language the resident speaks.
    private(set) var residentLanguage: Language?

    private let speechToText: SpeechToText
    private let translationEngine: TranslationEngine
    private let textToSpeech: TextToSpeech
    private let workerLanguage: Language

    init(
        speechToText: SpeechToText,
        translationEngine: TranslationEngine,
        textToSpeech: TextToSpeech,
        workerLanguage: Language = Language(code: "en", displayName: "English")
    ) {
        self.speechToText = speechToText
        self.translationEngine = translationEngine
        self.textToSpeech = textToSpeech
        self.workerLanguage = workerLanguage
    }

    // MARK: - Intents

    /// Begin holding the mic for `speaker`. No-op if a turn is already in flight for either
    /// speaker (prevents overlapping turns).
    func startRecording(_ speaker: Speaker) {
        guard case .idle = phase else { return }
        error = nil
        phase = .recording(speaker)
    }

    /// Stop the held recording for `speaker` and run it through STT + translation. No-op if
    /// nobody is recording, or if `speaker` doesn't match who is (ignores a stop event for the
    /// wrong speaker — e.g. a stale button release after the other side already finished).
    func finishRecording(_ speaker: Speaker, audio: AudioBuffer) async {
        guard case .recording(let recordingSpeaker) = phase, recordingSpeaker == speaker else {
            return
        }

        phase = .transcribing(speaker)
        do {
            let transcription = try await speechToText.transcribe(audio)
            let transcript = transcription.text.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !transcript.isEmpty else {
                phase = .idle
                return
            }

            if speaker == .resident, let detected = transcription.detectedLanguage {
                residentLanguage = detected
            }

            try await translateAndAppend(transcript, speaker: speaker)
        } catch let sttError as SpeechToTextError {
            error = Self.userFacingMessage(for: sttError)
            phase = .idle
        } catch {
            self.error = "Something went wrong understanding that. Please try again."
            phase = .idle
        }
    }

    /// Translate and send typed `text` from `speaker`. No-op on blank input or while another
    /// turn is in flight (same overlap guard as recording). Requires the resident's language
    /// to already be known, for either direction — typed text alone can't establish it.
    func send(_ text: String, speaker: Speaker) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, case .idle = phase else { return }

        guard residentLanguage != nil else {
            error = "We don't know the resident's language yet. Have them speak first."
            return
        }

        error = nil
        do {
            try await translateAndAppend(trimmed, speaker: speaker)
        } catch {
            self.error = "Something went wrong sending that. Please try again."
            phase = .idle
        }
    }

    /// Replay a past message's translation aloud. No-op if something is already playing, the
    /// message doesn't exist, or no voice is available for its language (the view should show
    /// large text instead in that case, not call this).
    func replay(_ messageID: UUID) async {
        guard playingMessageID == nil else { return }
        guard let message = messages.first(where: { $0.id == messageID }) else { return }
        guard textToSpeech.supports(message.targetLanguage) else { return }

        playingMessageID = messageID
        defer { playingMessageID = nil }
        try? await textToSpeech.speak(message.translatedText, language: message.targetLanguage)
    }

    /// Clear the current recoverable error.
    func dismissError() {
        error = nil
    }

    /// Wipe all session state — conversation content, in-flight phase, and the resident's
    /// detected language (ADR-006: nothing survives end-session).
    func endSession() {
        messages = []
        phase = .idle
        error = nil
        playingMessageID = nil
        residentLanguage = nil
    }

    // MARK: - Shared translate step

    private func translateAndAppend(_ text: String, speaker: Speaker) async throws {
        // Resident turns translate into English; worker turns translate into the resident's
        // language. `residentLanguage` is guaranteed non-nil for worker turns by `send`'s
        // guard above; `finishRecording` only reaches here after either detecting it (resident
        // turn) or it already being known (worker turn via the same guard, checked below).
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

        phase = .translating(speaker)
        do {
            let translated = try await translationEngine.translate(
                text,
                from: sourceLanguage,
                to: targetLanguage
            )
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
            error = Self.userFacingMessage(for: translationError)
            phase = .idle
        }
    }

    // MARK: - Error mapping

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
