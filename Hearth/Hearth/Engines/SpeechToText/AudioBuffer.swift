import Foundation

/// Raw 16 kHz mono PCM audio, produced by `AudioSessionManager` (#13) and consumed by
/// `SpeechToText`. Deliberately just `Data` — no `AVAudioPCMBuffer` or other framework type
/// crosses the engine boundary.
struct AudioBuffer: Sendable, Equatable {
    let pcmData: Data
    let sampleRate: Double

    init(pcmData: Data, sampleRate: Double = 16_000) {
        self.pcmData = pcmData
        self.sampleRate = sampleRate
    }
}
