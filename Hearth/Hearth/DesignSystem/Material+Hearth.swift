import SwiftUI

/// Glass material tokens from UI-SPEC.md §4. The tint and border values are kept
/// together so feature views do not have to reconstruct either treatment.
enum MaterialHearth {
    static let glass = Material.ultraThin

    static let grainOpacity = 0.035
    static let grainTileSize: CGFloat = 64

    static let dividerTint = Color.Hearth.sand.opacity(0.55)
    static let dividerBorder = Color.white.opacity(0.5)

    static let inputCardTint = Color(
        red: 255 / 255,
        green: 248 / 255,
        blue: 235 / 255,
        opacity: 0.35
    )
    static let inputCardBorder = Color(
        red: 180 / 255,
        green: 150 / 255,
        blue: 120 / 255,
        opacity: 0.18
    )

    static let borderWidth: CGFloat = 1
}

extension View {
    /// Applies the complete glass treatment for the expanded conversation input card.
    func hearthInputCardGlass() -> some View {
        background {
            RoundedRectangle(cornerRadius: RadiusHearth.card)
                .fill(MaterialHearth.glass)
                .overlay {
                    RoundedRectangle(cornerRadius: RadiusHearth.card)
                        .fill(MaterialHearth.inputCardTint)
                }
                .hearthShadow(ShadowHearth.glassCard)
        }
        .overlay {
            RoundedRectangle(cornerRadius: RadiusHearth.card)
                .stroke(MaterialHearth.inputCardBorder, lineWidth: MaterialHearth.borderWidth)
        }
    }

    /// Applies the tinted glass and horizontal hairlines used by the center divider.
    func hearthCenterDividerGlass() -> some View {
        background {
            ZStack {
                Rectangle()
                    .fill(MaterialHearth.glass)
                Rectangle()
                    .fill(MaterialHearth.dividerTint)
            }
        }
        .overlay(alignment: .top) {
            dividerBorder
        }
        .overlay(alignment: .bottom) {
            dividerBorder
        }
    }

    private var dividerBorder: some View {
        Rectangle()
            .fill(MaterialHearth.dividerBorder)
            .frame(height: MaterialHearth.borderWidth)
    }
}
