import SwiftUI

/// The message text and language visible to one side of the conversation.
///
/// A speaker sees their original words; the other side sees the translated words. The
/// language is always taken from the message's runtime metadata rather than a fixed catalog.
enum MessagePresentationPerspective {
    static func isOwnMessage(_ message: Message, for viewer: Speaker) -> Bool {
        message.speaker == viewer
    }

    static func text(for message: Message, viewer: Speaker) -> String {
        isOwnMessage(message, for: viewer) ? message.originalText : message.translatedText
    }

    static func language(for message: Message, viewer: Speaker) -> Language {
        isOwnMessage(message, for: viewer) ? message.sourceLanguage : message.targetLanguage
    }

    static func languageLabel(for language: Language) -> String {
        guard let flag = language.flag, !flag.isEmpty else {
            return language.displayName
        }

        return "\(flag) \(language.displayName)"
    }
}

/// Displays the most recent translated turn in the center of one conversation pane.
///
/// The view does not access a speech engine. A parent ViewModel supplies `onPlayRequested`
/// when the message has playable audio.
struct LatestMessageView: View {
    let message: Message
    let viewer: Speaker
    let onPlayRequested: (Message) -> Void

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    private var displayedLanguage: Language {
        MessagePresentationPerspective.language(for: message, viewer: viewer)
    }

    private var displayedText: String {
        MessagePresentationPerspective.text(for: message, viewer: viewer)
    }

    var body: some View {
        VStack(spacing: SpacingHearth.landingContentGap) {
            Text(verbatim: MessagePresentationPerspective.languageLabel(for: displayedLanguage))
                .hearthTypography(TypographyHearth.languageBadge)
                .foregroundStyle(Color.Hearth.headingInk)

            Text(verbatim: displayedText)
                .hearthTypography(TypographyHearth.latestTranslation)
                .foregroundStyle(Color.Hearth.text)

            LatestMessageCapabilityView(
                message: message,
                onPlayRequested: onPlayRequested
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .transition(
            accessibilityReduceMotion
                ? .identity
                : .opacity.combined(with: .offset(y: SizeHearth.messageEntryOffset))
        )
    }
}

/// Shows whether the latest message can be replayed or is available as text only.
private struct LatestMessageCapabilityView: View {
    let message: Message
    let onPlayRequested: (Message) -> Void

    var body: some View {
        if message.hasPlayableAudio {
            Button {
                onPlayRequested(message)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: SizeHearth.messagePlaybackVisual))
                    .foregroundStyle(Color.Hearth.text)
                    .frame(
                        width: SizeHearth.messagePlaybackHitTarget,
                        height: SizeHearth.messagePlaybackHitTarget
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(MessagePlaybackButtonStyle())
            .accessibilityLabel("Play translation")
        } else {
            Text("Text only")
                .hearthTypography(TypographyHearth.appBodyRegular)
                .foregroundStyle(Color.Hearth.text)
                .padding(.vertical, SizeHearth.textOnlyVerticalPadding)
                .padding(.horizontal, SizeHearth.textOnlyHorizontalPadding)
                .background(Color.Hearth.sand.opacity(0.75), in: Capsule())
                .accessibilityLabel("Text only. Speech playback unavailable.")
        }
    }
}

/// Renders the latest message for a pane. History remains in memory and is supplied by the
/// parent; this view intentionally presents only the newest turn, matching the approved UI.
struct ConversationThreadView: View {
    let messages: [Message]
    let viewer: Speaker
    let onPlayRequested: (Message) -> Void

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    private var latestMessage: Message? {
        messages.last
    }

    var body: some View {
        Group {
            if let latestMessage {
                LatestMessageView(
                    message: latestMessage,
                    viewer: viewer,
                    onPlayRequested: onPlayRequested
                )
                .id(latestMessage.id)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(
            accessibilityReduceMotion ? nil : .easeOut(duration: 0.3),
            value: latestMessage?.id
        )
    }
}

/// A reusable translated-turn bubble for compact conversation history or previews.
struct MessageBubbleView: View {
    let message: Message
    let viewer: Speaker
    let onPlayRequested: (Message) -> Void

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    private var isOwnMessage: Bool {
        MessagePresentationPerspective.isOwnMessage(message, for: viewer)
    }

    private var bubbleBackground: Color {
        isOwnMessage ? Color.Hearth.warmth : Color.Hearth.bubbleOtherBg
    }

    private var originalTextColor: Color {
        isOwnMessage ? Color.Hearth.bubbleMeOriginal : Color.Hearth.bubbleOtherOriginal
    }

    private var translationTextColor: Color {
        isOwnMessage ? Color.Hearth.bubbleMeTranslation : Color.Hearth.bubbleOtherTranslation
    }

    var body: some View {
        MessageBubbleRowLayout(isOwnMessage: isOwnMessage) {
            VStack(alignment: .leading, spacing: SpacingHearth.dividerVerticalPadding) {
                Text(verbatim: MessagePresentationPerspective.languageLabel(for: message.targetLanguage))
                    .hearthTypography(TypographyHearth.bubbleLanguageRow)
                    .foregroundStyle(
                        isOwnMessage
                            ? Color.Hearth.textOnWarmth.opacity(0.7)
                            : Color.Hearth.bubbleOtherTranslation.opacity(0.7)
                    )

                Text(verbatim: message.originalText)
                    .hearthTypography(TypographyHearth.bubbleOriginal)
                    .foregroundStyle(originalTextColor)

                Text(verbatim: message.translatedText)
                    .hearthTypography(TypographyHearth.bubbleTranslation)
                    .foregroundStyle(translationTextColor)

                HStack {
                    if isOwnMessage {
                        MessageBubbleCapabilityView(
                            message: message,
                            isOwnMessage: isOwnMessage,
                            onPlayRequested: onPlayRequested
                        )
                        Spacer(minLength: 0)
                    } else {
                        Spacer(minLength: 0)
                        MessageBubbleCapabilityView(
                            message: message,
                            isOwnMessage: isOwnMessage,
                            onPlayRequested: onPlayRequested
                        )
                    }
                }
            }
            .padding(.vertical, SpacingHearth.messageBubbleVerticalPadding)
            .padding(.horizontal, SpacingHearth.messageBubbleHorizontalPadding)
            .background(bubbleBackground)
            .clipShape(MessageBubbleShape(isOwnMessage: isOwnMessage))
        }
        .accessibilityElement(children: .contain)
        .transition(
            accessibilityReduceMotion
                ? .identity
                : .opacity.combined(with: .offset(y: SizeHearth.messageEntryOffset))
        )
    }
}

private struct MessageBubbleCapabilityView: View {
    let message: Message
    let isOwnMessage: Bool
    let onPlayRequested: (Message) -> Void

    private var playbackForeground: Color {
        isOwnMessage ? Color.Hearth.textOnWarmth : Color.Hearth.bubbleOtherTranslation
    }

    var body: some View {
        if message.hasPlayableAudio {
            Button {
                onPlayRequested(message)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: SizeHearth.messagePlaybackVisual))
                    .foregroundStyle(playbackForeground)
                    .frame(
                        width: SizeHearth.messagePlaybackVisual,
                        height: SizeHearth.messagePlaybackVisual
                    )
                    .background(Color.Hearth.bubbleControlBackground, in: Circle())
                    .frame(
                        width: SizeHearth.messagePlaybackHitTarget,
                        height: SizeHearth.messagePlaybackHitTarget
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(MessagePlaybackButtonStyle())
            .accessibilityLabel("Play translation")
        } else {
            Text("Text only")
                .hearthTypography(TypographyHearth.appBodyRegular)
                .foregroundStyle(Color.Hearth.text.opacity(0.8))
                .padding(.vertical, SpacingHearth.dividerVerticalPadding)
                .padding(.horizontal, SpacingHearth.inputHorizontalMargin)
                .background(Color.Hearth.sand.opacity(0.7), in: Capsule())
                .accessibilityLabel("Text only. Speech playback unavailable.")
        }
    }
}

private struct MessagePlaybackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct MessageBubbleShape: Shape {
    let isOwnMessage: Bool

    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            topLeadingRadius: RadiusHearth.bubble,
            bottomLeadingRadius: isOwnMessage
                ? RadiusHearth.bubble
                : RadiusHearth.bubbleSenderCorner,
            bottomTrailingRadius: isOwnMessage
                ? RadiusHearth.bubbleSenderCorner
                : RadiusHearth.bubble,
            topTrailingRadius: RadiusHearth.bubble,
            style: .continuous
        )
        .path(in: rect)
    }
}

private struct MessageBubbleRowLayout: Layout {
    let isOwnMessage: Bool

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else {
            return .zero
        }

        guard let proposedWidth = proposal.width, proposedWidth > 0 else {
            return subview.sizeThatFits(proposal)
        }

        let bubbleWidth = proposedWidth * SizeHearth.messageBubbleMaxWidthFraction
        let bubbleSize = subview.sizeThatFits(
            ProposedViewSize(width: bubbleWidth, height: proposal.height)
        )
        return CGSize(width: proposedWidth, height: bubbleSize.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else {
            return
        }

        let bubbleWidth = bounds.width * SizeHearth.messageBubbleMaxWidthFraction
        let bubbleSize = subview.sizeThatFits(
            ProposedViewSize(width: bubbleWidth, height: proposal.height)
        )
        let bubbleX = isOwnMessage ? bounds.maxX - bubbleWidth : bounds.minX

        subview.place(
            at: CGPoint(x: bubbleX, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bubbleWidth, height: bubbleSize.height)
        )
    }
}

#if DEBUG
#Preview("Latest message") {
    ConversationThreadView(
        messages: [TestFixtures.FixtureMessage.workerTurn],
        viewer: .resident,
        onPlayRequested: { _ in }
    )
    .padding()
    .background(Color.Hearth.sideTop)
    .frame(height: 360)
}

#Preview("Message bubbles") {
    ScrollView {
        VStack(spacing: SpacingHearth.landingContentGap) {
            MessageBubbleView(
                message: TestFixtures.FixtureMessage.residentTurn,
                viewer: .resident,
                onPlayRequested: { _ in }
            )

            MessageBubbleView(
                message: TestFixtures.FixtureMessage.workerTurn,
                viewer: .resident,
                onPlayRequested: { _ in }
            )
        }
        .padding()
    }
    .background(Color.Hearth.sideBottom)
}
#endif
