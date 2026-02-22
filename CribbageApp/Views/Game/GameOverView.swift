import SwiftUI

struct GameOverView: View {
    @Environment(GameViewModel.self) private var viewModel
    let winner: String

    var playerWon: Bool { winner == viewModel.humanName }

    var body: some View {
        VStack(spacing: 24) {
            // Trophy icon
            Image(systemName: playerWon ? "trophy.fill" : "hand.thumbsdown.fill")
                .font(.system(size: 60))
                .foregroundStyle(playerWon ? .yellow : .secondary)

            // Result
            Text(playerWon ? "You Win!" : "You Lose")
                .font(.largeTitle.bold())

            // Final scores
            VStack(spacing: 8) {
                scoreRow(name: viewModel.humanName, score: viewModel.humanScore, highlight: playerWon)
                scoreRow(name: viewModel.opponentName, score: viewModel.opponentScore, highlight: !playerWon)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            // Buttons
            VStack(spacing: 12) {
                Button {
                    viewModel.restartGame()
                } label: {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    viewModel.engine = nil
                    viewModel.selectedIndices = []
                } label: {
                    Label("Main Menu", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(32)
    }

    private func scoreRow(name: String, score: Int, highlight: Bool) -> some View {
        HStack {
            Text(name)
                .font(.headline)
            Spacer()
            Text("\(score)")
                .font(.title2.bold())
                .foregroundStyle(highlight ? .green : .primary)
        }
    }
}
