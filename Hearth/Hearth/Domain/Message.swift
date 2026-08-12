import Foundation

/// One conversation turn: what was said, by whom, in which languages, and when.
/// Contains only what the language-neutral UI and ViewModel need.
///
/// In-memory only — never persisted (ADR-006). `hasPlayableAudio` is UI-only metadata set
/// after a TTS engine successfully synthesizes audio for this message; it is not audio data
/// itself and carries no engine-specific detail.
struct Message: Sendable, Equatable, Identifiable {
    let id: UUID
    let speaker: Speaker
    let originalText: String
    let translatedText: String
    let sourceLanguage: Language
    let targetLanguage: Language
    let timestamp: Date
    var hasPlayableAudio: Bool

    init(
        id: UUID = UUID(),
        speaker: Speaker,
        originalText: String,
        translatedText: String,
        sourceLanguage: Language,
        targetLanguage: Language,
        timestamp: Date = Date(),
        hasPlayableAudio: Bool = false
    ) {
        self.id = id
        self.speaker = speaker
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = timestamp
        self.hasPlayableAudio = hasPlayableAudio
    }
}
