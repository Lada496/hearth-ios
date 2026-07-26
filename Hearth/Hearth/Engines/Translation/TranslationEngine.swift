/// Translates text between two runtime-detected languages. Implemented for real use by the
/// Tiny-Aya Earth adapter (#20); `MockTranslator` stands in until then.
///
/// Frozen per `AGENTS.md` once merged — signature changes need a new two-human-reviewed PR.
protocol TranslationEngine: Sendable {
    /// One-time warm-up (e.g. loading the model). Safe to call again once already prepared.
    func prepare() async throws

    /// Translates `text` from `source` to `target`.
    func translate(_ text: String, from source: Language, to target: Language) async throws -> String
}

/// User-facing error boundary — no llama.cpp-specific error type crosses out of the engine
/// folder.
enum TranslationError: Error, Sendable, Equatable {
    /// `translate` was called before a successful `prepare()`.
    case notPrepared

    /// There was nothing to translate.
    case emptyInput

    /// The underlying engine failed; `reason` is safe to show or log, not an internal type.
    case translationFailed(reason: String)
}
