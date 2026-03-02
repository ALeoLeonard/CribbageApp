import SwiftUI

@main
struct CribbageAppApp: App {
    @State private var viewModel = GameViewModel()
    @State private var themeManager = ThemeManager.shared
    private var store = StoreManager.shared

    init() {
        GameCenterManager.shared.authenticate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .environment(themeManager)
                .onChange(of: store.isPremium) { _, isPremium in
                    if isPremium {
                        ThemeManager.shared.unlockAllPremiumThemes()
                    } else {
                        ThemeManager.shared.lockPremiumThemes()
                    }
                }
        }
    }
}
