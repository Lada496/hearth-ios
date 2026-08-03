import Foundation

/// A language identified at runtime (e.g. from WhisperKit detection or a manual override).
///
/// Deliberately excludes tier, region, or any "supported languages" concept — the final
/// launch-language list is still undecided (see `docs/PRD.md` §3). This type only carries
/// what the UI and engines need to route a turn: a normalized code, a display name, and an
/// optional flag for the badge.
struct Language: Sendable, Equatable, Hashable {
    /// Normalized language code (lowercased, whitespace-trimmed), e.g. `"en"`, `"sw"`, `"ar"`.
    /// Not validated against ISO 639 — WhisperKit's detected codes are trusted as-is.
    let code: String

    /// Human-readable name for display, e.g. `"English"`, `"Kiswahili"`.
    let displayName: String

    /// Flag emoji for the language badge, if one is available for this code.
    let flag: String?

    /// - Parameter code: normalized on init (lowercased, trimmed) so equality/hashing is
    ///   consistent regardless of how the caller (engine output, manual entry) formatted it.
    init(code: String, displayName: String, flag: String? = nil) {
        self.code = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.displayName = displayName
        self.flag = flag
    }
}
