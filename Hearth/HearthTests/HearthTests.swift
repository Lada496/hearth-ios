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
        XCTAssertEqual(SpacingHearth.dividerVerticalPadding, 6)
        XCTAssertEqual(SpacingHearth.messageBubbleVerticalPadding, 10)
        XCTAssertEqual(SpacingHearth.messageBubbleHorizontalPadding, 14)
        XCTAssertEqual(SpacingHearth.inputHorizontalMargin, 12)
        XCTAssertEqual(SpacingHearth.collapsedInputLeadingMargin, 24)
    }

    #if canImport(UIKit)
    func testHearthFontsRegisterAndResolve() {
        FontRegistration.registerHearthFonts()

        XCTAssertNotNil(UIFont(name: "Nunito", size: 12), "Nunito did not register")
        XCTAssertNotNil(UIFont(name: "Playfair Display", size: 12), "Playfair Display did not register")
    }
    #endif
}
