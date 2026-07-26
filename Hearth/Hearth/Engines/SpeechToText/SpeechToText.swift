/// Transcribes recorded speech to text, with optional language detection. Implemented for
/// real use by a WhisperKit adapter (#22); `MockSTT` stands in until then.
///
/// Frozen per `AGENTS.md` once merged — signature changes need a new two-human-reviewed PR.
protocol SpeechToText: Sendable {
    /// One-time warm-up (e.g. loading the model). Safe to call again once already prepared.
    func prepare() async throws

    /// Transcribes `audio`. Detected language and confidence are optional because a given
    /// implementation (or a very short/silent clip) may not be able to supply them.
    func transcribe(_ audio: AudioBuffer) async throws -> SpeechToTextResult
}

struct SpeechToTextResult: Sendable, Equatable {
    let text: String
    let detectedLanguage: Language?
    let confidence: Double?

    init(text: String, detectedLanguage: Language? = nil, confidence: Double? = nil) {
        self.text = text
        self.detectedLanguage = detectedLanguage
        self.confidence = confidence
    }
}

/// User-facing error boundary — no CoreML/WhisperKit-specific error type crosses out of the
/// engine folder.
enum SpeechToTextError: Error, Sendable, Equatable {
    /// `transcribe` was called before a successful `prepare()`.
    case notPrepared

    /// The clip was too short/silent to plausibly contain speech.
    case audioTooShort

    /// The underlying engine failed; `reason` is safe to show or log, not an internal type.
    case transcriptionFailed(reason: String)
}
