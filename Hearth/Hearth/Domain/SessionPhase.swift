/// What the conversation is doing right now. Ports the shape of `RecordingState` from
/// `reference/frontend/types.ts`, extended with the transcribing/translating/speaking steps
/// that prototype didn't need to model explicitly (it called a single backend endpoint).
enum SessionPhase: Sendable, Equatable {
    /// Nothing in flight; either mic can start recording.
    case idle

    /// Model preparation before first use (e.g. Tiny-Aya/WhisperKit warm-up).
    case loading

    /// Holding the mic for `speaker`.
    case recording(Speaker)

    /// Speech-to-text running for `speaker`'s held recording.
    case transcribing(Speaker)

    /// Translation running for `speaker`'s transcript.
    case translating(Speaker)

    /// Text-to-speech synthesizing/playing the translation for `speaker`'s turn.
    case speaking(Speaker)
}
