import CoreText
import Foundation

/// Registers the bundled Nunito and Playfair Display variable fonts (UI-SPEC.md §2) so
/// `FontHearth`'s `Font.custom` lookups resolve. Call once, before any Hearth font token is
/// first rendered (e.g. from `HearthApp.init`).
///
/// These fonts aren't declared via Info.plist `UIAppFonts` because this target's Info.plist
/// is Xcode-generated across multiple platforms (iOS/macOS/visionOS); `CTFontManager`
/// registration works identically on every platform without touching per-platform plist keys.
enum FontRegistration {
    private static let fontFileNames = [
        "Nunito[wght]",
        "Nunito-Italic[wght]",
        "PlayfairDisplay[wght]",
        "PlayfairDisplay-Italic[wght]",
    ]

    static func registerHearthFonts() {
        for fileName in fontFileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "ttf") else {
                assertionFailure("Missing bundled font resource: \(fileName).ttf")
                continue
            }

            var registrationError: Unmanaged<CFError>?
            let didRegister = CTFontManagerRegisterFontsForURL(
                url as CFURL,
                .process,
                &registrationError
            )

            if !didRegister, let registrationError {
                let error = registrationError.takeRetainedValue()
                let alreadyRegistered = CFErrorGetCode(error) == CTFontManagerError.alreadyRegistered.rawValue
                if !alreadyRegistered {
                    assertionFailure("Failed to register font \(fileName): \(error)")
                }
            }
        }
    }
}
