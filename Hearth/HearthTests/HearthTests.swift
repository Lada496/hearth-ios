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

    #if canImport(UIKit)
    func testHearthFontsRegisterAndResolve() {
        FontRegistration.registerHearthFonts()

        XCTAssertNotNil(UIFont(name: "Nunito", size: 12), "Nunito did not register")
        XCTAssertNotNil(UIFont(name: "Playfair Display", size: 12), "Playfair Display did not register")
    }
    #endif
}
