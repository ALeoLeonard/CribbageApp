import SwiftUI

@main
struct CribbageAppApp: App {
    @State private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
