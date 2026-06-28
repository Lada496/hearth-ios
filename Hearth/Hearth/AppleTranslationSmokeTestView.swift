//
//  AppleTranslationSmokeTestView.swift
//  Hearth
//
//  Created by Yuko Murayama on 2026-06-27.
//

// This is only for AppleTranslationSmokeTest
import SwiftUI
import Translation

struct AppleTranslationSmokeTestView: View {
    @State private var configuration: TranslationSession.Configuration?
    @State private var result = "Tap a button to test."

    var body: some View {
        VStack(spacing: 16) {
            Button("English → Japanese") {
                configuration = .init(
                    source: Locale.Language(identifier: "en"),
                    target: Locale.Language(identifier: "ja")
                )
            }

            Button("English → Arabic") {
                configuration = .init(
                    source: Locale.Language(identifier: "en"),
                    target: Locale.Language(identifier: "ar")
                )
            }

            Button("English → Chinese") {
                configuration = .init(
                    source: Locale.Language(identifier: "en"),
                    target: Locale.Language(identifier: "zh-Hans")
                )
            }

            Text(result)
                .padding()
        }
        .padding()
        .translationTask(configuration) { session in
            do {
                try await session.prepareTranslation()
                let response = try await session.translate("Hello. Do you need help?")
                result = response.targetText
            } catch {
                result = "FAILED: \(error.localizedDescription)"
            }
        }
    }
}
