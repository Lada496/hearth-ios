import SwiftUI

/// Debug-only screen rendering every color, typography, radius, and shadow token so a
/// reviewer can screenshot-compare it against UI-SPEC.md §§1-2 (issue #10 acceptance
/// criterion 1). Not part of the shipped app flow.
#if DEBUG
struct DesignSystemPreview: View {
    private let colorSwatches: [(name: String, color: Color)] = [
        ("cream", .Hearth.cream),
        ("sand", .Hearth.sand),
        ("sandLight", .Hearth.sandLight),
        ("warmth", .Hearth.warmth),
        ("text", .Hearth.text),
        ("divider", .Hearth.divider),
        ("sideTop", .Hearth.sideTop),
        ("sideBottom", .Hearth.sideBottom),
        ("recording", .Hearth.recording),
        ("processing", .Hearth.processing),
        ("textOnWarmth", .Hearth.textOnWarmth),
        ("bubbleOtherBg", .Hearth.bubbleOtherBg),
        ("bubbleMeOriginal", .Hearth.bubbleMeOriginal),
        ("bubbleOtherOriginal", .Hearth.bubbleOtherOriginal),
        ("bubbleMeTranslation", .Hearth.bubbleMeTranslation),
        ("bubbleOtherTranslation", .Hearth.bubbleOtherTranslation),
        ("headingInk", .Hearth.headingInk),
        ("errorBg", .Hearth.errorBg),
        ("placeholder", .Hearth.placeholder),
        ("bodyBehindShell", .Hearth.bodyBehindShell)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section("Colors") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(colorSwatches, id: \.name) { swatch in
                            VStack(alignment: .leading, spacing: 4) {
                                RoundedRectangle(cornerRadius: RadiusHearth.bubbleSenderCorner)
                                    .fill(swatch.color)
                                    .frame(height: 44)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: RadiusHearth.bubbleSenderCorner)
                                            .stroke(Color.Hearth.divider, lineWidth: 1)
                                    )
                                Text(swatch.name)
                                    .font(.caption)
                                    .foregroundStyle(Color.Hearth.text)
                            }
                        }
                    }
                }

                section("Typography") {
                    VStack(alignment: .leading, spacing: 12) {
                        labeled("landingTitle") {
                            Text("Hearth").font(FontHearth.landingTitle)
                        }
                        labeled("landingSubtitle") {
                            Text("Real-time translation, face to face").font(FontHearth.landingSubtitle)
                        }
                        labeled("ctaButton") {
                            Text("Start").font(FontHearth.ctaButton)
                        }
                        labeled("latestTranslation") {
                            Text("I need help finding shelter.").font(FontHearth.latestTranslation)
                        }
                        labeled("languageBadge") {
                            Text("Kiswahili").font(FontHearth.languageBadge)
                        }
                        labeled("bubbleTranslation") {
                            Text("I need help finding shelter.").font(FontHearth.bubbleTranslation)
                        }
                        labeled("bubbleOriginal") {
                            Text("Ninahitaji msaada.").font(FontHearth.bubbleOriginal)
                        }
                        labeled("tabLabel") {
                            Text("Translate").font(FontHearth.tabLabel)
                        }
                        labeled("textInput") {
                            Text("Type a message...").font(FontHearth.textInput)
                        }
                        labeled("bodyDynamic") {
                            Text("Body text scales with Dynamic Type.").font(FontHearth.bodyDynamic)
                        }
                    }
                }

                section("Radius") {
                    HStack(spacing: 16) {
                        radiusSample("pill", RadiusHearth.pill)
                        radiusSample("card", RadiusHearth.card)
                        radiusSample("toast", RadiusHearth.toast)
                        radiusSample("bubble", RadiusHearth.bubble)
                        radiusSample("senderCorner", RadiusHearth.bubbleSenderCorner)
                    }
                }

                section("Shadow") {
                    HStack(spacing: 24) {
                        shadowSample("micButtonIdle", ShadowHearth.micButtonIdle)
                        shadowSample("micButtonRecording", ShadowHearth.micButtonRecording)
                        shadowSample("glassCard", ShadowHearth.glassCard)
                    }
                }
            }
            .padding()
        }
        .background(Color.Hearth.cream)
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.Hearth.headingInk)
            content()
        }
    }

    @ViewBuilder
    private func labeled<Content: View>(_ name: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption2)
                .foregroundStyle(Color.Hearth.placeholder)
            content()
                .foregroundStyle(Color.Hearth.text)
        }
    }

    private func radiusSample(_ name: String, _ radius: CGFloat) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color.Hearth.warmth)
                .frame(width: 60, height: 60)
            Text(name).font(.caption2)
        }
    }

    private func shadowSample(_ name: String, _ token: ShadowToken) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.Hearth.warmth)
                .frame(width: 60, height: 60)
                .hearthShadow(token)
            Text(name).font(.caption2)
        }
    }
}

#Preview {
    DesignSystemPreview()
}
#endif
