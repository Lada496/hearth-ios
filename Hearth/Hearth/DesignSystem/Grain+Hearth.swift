import CoreImage
import SwiftUI

/// Builds the UI-SPEC.md §1 paper-grain tile once per process from Apple's local Core Image
/// generator. The result is decorative, contains no user data, and requires no bundled asset.
private enum GrainTextureHearth {
    static let image: Image? = {
        guard let randomNoise = CIFilter(name: "CIRandomGenerator")?.outputImage else {
            return nil
        }

        let tileRect = CGRect(
            origin: .zero,
            size: CGSize(width: MaterialHearth.grainTileSize, height: MaterialHearth.grainTileSize)
        )
        let monochromeNoise = randomNoise
            .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0])
            .cropped(to: tileRect)
        let context = CIContext()

        guard let tile = context.createCGImage(monochromeNoise, from: tileRect) else {
            return nil
        }

        return Image(decorative: tile, scale: 1)
    }()
}

private struct GrainOverlayHearth: View {
    var body: some View {
        if let image = GrainTextureHearth.image {
            Rectangle()
                .fill(ImagePaint(image: image, scale: 1))
                .opacity(MaterialHearth.grainOpacity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

extension View {
    /// Applies Hearth's noninteractive 3.5% paper-grain treatment over the complete receiver.
    func hearthGrainOverlay() -> some View {
        overlay {
            GrainOverlayHearth()
        }
    }
}
