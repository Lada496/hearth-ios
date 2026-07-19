import SwiftUI

struct AppRootView: View {
    var body: some View {
        Text("Hearth")
            .accessibilityIdentifier("app-root-title")
    }
}

#Preview {
    AppRootView()
}
