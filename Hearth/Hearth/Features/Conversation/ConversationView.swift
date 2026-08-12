import SwiftUI

/// The dual-pane conversation shell (UI-SPEC.md §4, `screenshots/translation.png`). Renders
/// two equal-height panes — a rotated resident pane on top and a normal-orientation worker
/// pane on the bottom — separated by the glass center divider. Pure layout: message
/// content, mic input, and text input are supplied by the caller so this view has no
/// engine or ViewModel dependency (those land in #25/#26/#27/#31).
struct ConversationView<TopContent: View, BottomContent: View>: View {
    let residentLanguageName: String?
    let workerLanguageName: String
    @ViewBuilder let topContent: () -> TopContent
    @ViewBuilder let bottomContent: () -> BottomContent

    var body: some View {
        VStack(spacing: 0) {
            ConversationPaneView(background: Color.Hearth.sideTop, rotated: true) {
                topContent()
            }

            CenterDividerView(
                residentLanguageName: residentLanguageName,
                workerLanguageName: workerLanguageName
            )

            ConversationPaneView(background: Color.Hearth.sideBottom, rotated: false) {
                bottomContent()
            }
        }
        .frame(maxWidth: 420, maxHeight: .infinity)
        .background(Color.Hearth.cream)
        .clipped()
        .ignoresSafeArea()
    }
}

/// One half of the conversation shell. The resident (top) pane is rotated 180° as a whole
/// so its content faces the resident correctly when the phone is passed across the divider
/// (UI-SPEC.md §4).
private struct ConversationPaneView<Content: View>: View {
    let background: Color
    let rotated: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .rotationEffect(.degrees(rotated ? 180 : 0))
    }
}

/// Glass divider between the two panes. Shows session-language metadata only — no
/// supported-language list or picker here (UI-SPEC.md §4e; the prototype's region picker
/// is cut per ADR-003). The two names are composed with an SF Symbol arrow rather than a
/// caller-supplied separator character, since some Unicode arrows (e.g. "↔") render with
/// Apple's colorful emoji presentation by default, which reads as out of place against the
/// app's warm, understated tone.
private struct CenterDividerView: View {
    let residentLanguageName: String?
    let workerLanguageName: String

    var body: some View {
        Group {
            if let residentLanguageName {
                HStack(spacing: 8) {
                    Text(workerLanguageName)
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.Hearth.headingInk.opacity(0.5))
                    Text(residentLanguageName)
                }
            } else {
                Text("Language detected after first turn")
            }
        }
        .font(FontHearth.bodySemibold)
        .foregroundStyle(Color.Hearth.headingInk)
        .padding(.vertical, SpacingHearth.dividerVerticalPadding)
        .frame(maxWidth: .infinity)
        .hearthCenterDividerGlass()
    }
}

#Preview("Conversation shell — fixture content") {
    ConversationView(
        residentLanguageName: TestFixtures.FixtureLanguage.swahili.displayName,
        workerLanguageName: TestFixtures.FixtureLanguage.english.displayName
    ) {
        VStack {
            Spacer()
            // Resident pane shows the worker's reply translated into Swahili, since that's
            // the language the resident actually reads.
            Text(TestFixtures.FixtureMessage.workerTurn.translatedText)
                .hearthTypography(TypographyHearth.latestTranslation)
                .foregroundStyle(Color.Hearth.headingInk)
                .padding()
            Spacer()
        }
    } bottomContent: {
        VStack {
            Spacer()
            // Worker pane shows the resident's message translated into English, since
            // that's the language the worker actually reads.
            Text(TestFixtures.FixtureMessage.residentTurn.translatedText)
                .hearthTypography(TypographyHearth.latestTranslation)
                .foregroundStyle(Color.Hearth.headingInk)
                .padding()
            Spacer()
        }
    }
}

#Preview("Conversation shell — resident language not yet detected") {
    ConversationView(
        residentLanguageName: nil,
        workerLanguageName: TestFixtures.FixtureLanguage.english.displayName
    ) {
        Color.clear
    } bottomContent: {
        Color.clear
    }
}
