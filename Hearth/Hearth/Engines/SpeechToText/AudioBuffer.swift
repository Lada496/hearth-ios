/// Raw 16 kHz mono PCM audio, produced by `AudioSessionManager` (#13) and consumed by
/// `SpeechToText`. No audio-framework type crosses the engine boundary.
struct AudioBuffer: Sendable, Equatable {
    static let sampleRate: Double = 16_000

    /// Mono, normalized PCM Float samples at `sampleRate`.
    let samples: [Float]
}
