/// Configurable stand-in for `TextToSpeech`, used by SwiftUI previews, the ViewModel (#9),
/// and unit tests so the whole app can be built and demoed before the system-TTS adapter
/// lands (#32).
@MainActor
final class MockTTS: TextToSpeech {
    /// Simulated delay for `speak(_:language:)`, in seconds.
    var speakDelaySeconds: Double = 0

    /// Language codes `supports(_:)` reports as having a voice. Empty by default, meaning no
    /// language is supported — the caller must opt a code in explicitly.
    var supportedLanguageCodes: Set<String> = []

    /// When set, `speak(_:language:)` throws this instead of succeeding.
    var errorToThrow: TextToSpeechError?

    private(set) var speakCallCount = 0
    private(set) var stopCallCount = 0
    private(set) var lastSpokenText: String?
    private(set) var lastSpokenLanguage: Language?

    init() {}

    func supports(_ language: Language) -> Bool {
        supportedLanguageCodes.contains(language.code)
    }

    func speak(_ text: String, language: Language) async throws {
        speakCallCount += 1
        if speakDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(speakDelaySeconds * 1_000_000_000))
        }
        if let errorToThrow {
            throw errorToThrow
        }
        guard supports(language) else {
            throw TextToSpeechError.unsupportedLanguage
        }
        lastSpokenText = text
        lastSpokenLanguage = language
    }

    func stop() {
        stopCallCount += 1
    }
}
