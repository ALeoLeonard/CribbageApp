import SwiftUI

struct GameBoardView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        if let winner = viewModel.winner {
            GameOverView(winner: winner)
        } else {
            gameBoard
        }
    }

    private var gameBoard: some View {
        VStack(spacing: 0) {
            // Score bar
            scoreBar
                .padding(.horizontal)
                .padding(.top, 4)

            Divider()
                .padding(.vertical, 4)

            // Opponent area
            opponentArea
                .padding(.horizontal)

            Spacer()

            // Play area (center)
            PlayAreaView(
                playPile: viewModel.playPile,
                runningTotal: viewModel.runningTotal,
                starter: viewModel.starter
            )

            // Score breakdown during counting phases
            if let breakdown = viewModel.scoreBreakdown,
               [.countNonDealer, .countDealer, .countCrib].contains(viewModel.phase) {
                ScoreBreakdownView(breakdown: breakdown)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Status message
            if let message = viewModel.statusMessage {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                    .transition(.opacity)
            }

            // Last action message
            if viewModel.statusMessage == nil, let lastAction = viewModel.lastAction {
                Text(lastAction.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 2)
            }

            Spacer()

            // Action bar
            ActionBarView()
                .padding(.bottom, 4)

            // Player's hand
            playerHand
                .padding(.bottom, 8)

            // Player info
            playerInfo
                .padding(.horizontal)
                .padding(.bottom, 4)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Round \(viewModel.roundNumber)")
                    .font(.subheadline.weight(.medium))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.engine = nil
                    viewModel.selectedIndices = []
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.phase)
    }

    // MARK: - Score Bar

    private var scoreBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.humanName)
                    .font(.caption.weight(.medium))
                Text("\(viewModel.humanScore)")
                    .font(.title3.bold())
            }

            Spacer()

            // Crib indicator
            VStack {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundStyle(.secondary)
                Text("Crib: \(viewModel.cribCount)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(viewModel.opponentName)
                    .font(.caption.weight(.medium))
                Text("\(viewModel.opponentScore)")
                    .font(.title3.bold())
            }
        }
    }

    // MARK: - Opponent Area

    private var opponentArea: some View {
        HStack(spacing: 4) {
            ForEach(0..<viewModel.opponentHandCount, id: \.self) { _ in
                CardView(card: Card(suit: .spades, rank: .ace), isFaceDown: true, isSmall: true)
            }

            if viewModel.opponentHandCount == 0 && viewModel.phase == .play {
                Text("No cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Player Hand

    private var playerHand: some View {
        Group {
            if viewModel.phase == .discard {
                CardFanView(
                    cards: viewModel.humanHand,
                    selectedIndices: viewModel.selectedIndices,
                    selectable: true,
                    onTap: { viewModel.toggleSelect($0) }
                )
            } else if viewModel.phase == .play {
                CardFanView(
                    cards: viewModel.humanHand,
                    selectedIndices: [],
                    selectable: viewModel.yourTurn && viewModel.humanCanPlay && !viewModel.isProcessing,
                    onTap: { viewModel.playCard($0) }
                )
            } else {
                CardFanView(
                    cards: viewModel.humanHand,
                    selectedIndices: [],
                    selectable: false
                )
            }
        }
    }

    // MARK: - Player Info

    private var playerInfo: some View {
        HStack {
            if viewModel.humanIsDealer {
                Label("Dealer", systemImage: "d.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            Spacer()
            if viewModel.opponentIsDealer {
                Label("Dealer", systemImage: "d.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}
