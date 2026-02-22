import SwiftUI

@main
struct CribbageAppApp: App {
    @State private var viewModel = GameViewModel()
    @State private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .environment(themeManager)
        }
    }
}
