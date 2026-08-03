import Foundation

/// Sample domain values for SwiftUI previews and unit tests only.
///
/// These are fixtures, not a supported-language list — production code must never read
/// `TestFixtures` or treat these codes/names as a commitment (`docs/PRD.md` §3, `docs/ROADMAP.md`
/// guardrail 2). The final launch-language list is still undecided.
#if DEBUG
enum TestFixtures {
    enum FixtureLanguage {
        static let english = Language(code: "en", displayName: "English", flag: "🇬🇧")
        static let swahili = Language(code: "sw", displayName: "Kiswahili", flag: "🇰🇪")
        static let arabic = Language(code: "ar", displayName: "العربية", flag: "🇸🇦")
    }

    enum FixtureMessage {
        static let residentTurn = Message(
            speaker: .resident,
            originalText: "Ninahitaji msaada kupata makazi usiku wa leo.",
            translatedText: "I need help finding shelter tonight.",
            sourceLanguage: FixtureLanguage.swahili,
            targetLanguage: FixtureLanguage.english
        )

        static let workerTurn = Message(
            speaker: .worker,
            originalText: "We have a bed available. Follow me.",
            translatedText: "Tuna kitanda kinachopatikana. Nifuate.",
            sourceLanguage: FixtureLanguage.english,
            targetLanguage: FixtureLanguage.swahili,
            hasPlayableAudio: true
        )
    }
}
#endif
