/// Configurable stand-in for `SpeechToText`, used by SwiftUI previews, the ViewModel (#9),
/// and unit tests so the whole app can be built and demoed before WhisperKit lands (#22).
final class MockSTT: SpeechToText, @unchecked Sendable {
    /// Simulated delay for `prepare()`, in seconds. Zero by default so tests stay fast.
    var prepareDelaySeconds: Double = 0

    /// Simulated delay for `transcribe(_:)`, in seconds.
    var transcribeDelaySeconds: Double = 0

    /// Result returned by `transcribe(_:)` when no failure is injected.
    var resultToReturn = SpeechToTextResult(text: "Mock transcript")

    /// When set, both `prepare()` and `transcribe(_:)` throw this instead of succeeding.
    var errorToThrow: SpeechToTextError?

    private(set) var prepareCallCount = 0
    private(set) var transcribeCallCount = 0

    init() {}

    func prepare() async throws {
        prepareCallCount += 1
        if prepareDelaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(prepareDelaySeconds * 1_000_000_000))
        }
        if let errorToThrow {
            throw errorToThrow
        }
    }

    func transcribe(_ audio: AudioBuffer) async throws -> SpeechToTextResult {
        transcribeCallCount += 1
        if transcribeDelaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(transcribeDelaySeconds * 1_000_000_000))
        }
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }
}
