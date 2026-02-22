import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.engine != nil {
                    GameBoardView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    MainMenuView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: viewModel.engine != nil)
        }
    }
}
