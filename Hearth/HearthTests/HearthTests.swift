import SwiftUI
import XCTest
@testable import Hearth

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class HearthTests: XCTestCase {
    func testAppRootViewCanBeConstructedWithoutModelResources() {
        _ = AppRootView()
    }

    func testSpacingTokensMatchUISpec() {
        XCTAssertEqual(SpacingHearth.landingContentGap, 20)
        XCTAssertEqual(SpacingHearth.ctaVerticalPadding, 16)
        XCTAssertEqual(SpacingHearth.ctaHorizontalPadding, 48)
        XCTAssertEqual(SpacingHearth.dividerVerticalPadding, 5)
        XCTAssertEqual(SpacingHearth.messageBubbleVerticalPadding, 10)
        XCTAssertEqual(SpacingHearth.messageBubbleHorizontalPadding, 14)
        XCTAssertEqual(SpacingHearth.inputHorizontalMargin, 12)
        XCTAssertEqual(SpacingHearth.collapsedInputLeadingMargin, 24)
    }

    func testTypographyMetricsMatchUISpec() {
        XCTAssertEqual(TypographyHearth.landingTitle.tracking, -1)
        XCTAssertEqual(TypographyHearth.landingTitle.lineHeightMultiplier, 1)
        XCTAssertEqual(TypographyHearth.latestTranslation.lineHeightMultiplier, 1.4)
        XCTAssertEqual(TypographyHearth.latestTranslation.lineSpacing, 9.6, accuracy: 0.001)
        XCTAssertEqual(TypographyHearth.bubbleTranslation.lineHeightMultiplier, 1.35)
        XCTAssertEqual(TypographyHearth.bubbleTranslation.lineSpacing, 5.25, accuracy: 0.001)
        XCTAssertEqual(TypographyHearth.bubbleOriginal.lineHeightMultiplier, 1.4)
        XCTAssertEqual(TypographyHearth.bubbleOriginal.lineSpacing, 4.8, accuracy: 0.001)
    }

    func testMaterialScalarsMatchUISpec() {
        XCTAssertEqual(MaterialHearth.grainOpacity, 0.035)
        XCTAssertEqual(MaterialHearth.grainTileSize, 64)
        XCTAssertEqual(MaterialHearth.borderWidth, 1)
    }

    #if canImport(UIKit)
    func testInputIconMutedColorMatchesUISpec() {
        let color = UIColor(Color.Hearth.inputIconMuted)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        XCTAssertTrue(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        XCTAssertEqual(red, CGFloat(0x8A) / 255, accuracy: 0.001)
        XCTAssertEqual(green, CGFloat(0x82) / 255, accuracy: 0.001)
        XCTAssertEqual(blue, CGFloat(0x7D) / 255, accuracy: 0.001)
        XCTAssertEqual(alpha, 1, accuracy: 0.001)
    }

    func testHearthFontsRegisterAndResolve() {
        FontRegistration.registerHearthFonts()

        XCTAssertNotNil(UIFont(name: "Nunito", size: 12), "Nunito did not register")
        XCTAssertNotNil(UIFont(name: "Playfair Display", size: 12), "Playfair Display did not register")
    }
    #endif
}
