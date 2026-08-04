/// Speaks translated text aloud when a voice is available for the language; the ViewModel
/// falls back to large-type text display when `supports(_:)` returns `false`. Implemented for
/// real use by an `AVSpeechSynthesizer` adapter (#32); `MockTTS` stands in until then.
///
/// Frozen per `AGENTS.md` once merged — signature changes need a new two-human-reviewed PR.
protocol TextToSpeech: Sendable {
    /// Whether a voice exists for `language` on this device right now. Capability-driven, not
    /// a fixed tier list — the answer can differ by device/OS version.
    func supports(_ language: Language) -> Bool

    /// Synthesizes and plays `text` in `language`. Callers must check `supports(_:)` first;
    /// implementations throw `TextToSpeechError.unsupportedLanguage` otherwise.
    func speak(_ text: String, language: Language) async throws

    /// Stops playback immediately, if any is in progress. Never throws — always safe to call.
    func stop()
}

/// User-facing error boundary — no AVFoundation-specific error type crosses out of the
/// engine folder.
enum TextToSpeechError: Error, Sendable, Equatable {
    /// `speak` was called for a language `supports(_:)` had already reported `false` for.
    case unsupportedLanguage

    /// The underlying engine failed; `reason` is safe to show or log, not an internal type.
    case synthesisFailed(reason: String)
}
