import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            if viewModel.engine != nil {
                GameBoardView()
            } else {
                MainMenuView()
            }
        }
    }
}
