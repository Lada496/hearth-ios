import SwiftUI

@main
struct HearthApp: App {
    init() {
        FontRegistration.registerHearthFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
