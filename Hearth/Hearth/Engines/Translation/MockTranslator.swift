/// Configurable stand-in for `TranslationEngine`, used by SwiftUI previews, the ViewModel
/// (#9), and unit tests so the whole app can be built and demoed before Tiny-Aya lands (#20).
final class MockTranslator: TranslationEngine, @unchecked Sendable {
    /// Simulated delay for `prepare()`, in seconds. Zero by default so tests stay fast.
    var prepareDelaySeconds: Double = 0

    /// Simulated delay for `translate(_:from:to:)`, in seconds.
    var translateDelaySeconds: Double = 0

    /// Result returned by `translate(_:from:to:)` when no failure is injected. If `nil`, the
    /// input text is echoed back unchanged — a harmless default for pipeline tests that don't
    /// care about the translated content.
    var resultToReturn: String?

    /// When set, both `prepare()` and `translate(_:from:to:)` throw this instead of succeeding.
    var errorToThrow: TranslationError?

    private(set) var prepareCallCount = 0
    private(set) var translateCallCount = 0

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

    func translate(_ text: String, from source: Language, to target: Language) async throws -> String {
        translateCallCount += 1
        if translateDelaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(translateDelaySeconds * 1_000_000_000))
        }
        if let errorToThrow {
            throw errorToThrow
        }
        if text.isEmpty {
            throw TranslationError.emptyInput
        }
        return resultToReturn ?? text
    }
}
