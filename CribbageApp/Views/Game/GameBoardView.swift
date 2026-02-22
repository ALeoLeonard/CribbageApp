import SwiftUI

struct GameBoardView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(ThemeManager.self) private var themeManager

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
                .padding(.horizontal, 12)
                .padding(.top, 4)

            // Cribbage board
            CribbageBoardView(
                playerScore: viewModel.humanScore,
                opponentScore: viewModel.opponentScore
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Opponent area
            opponentArea
                .padding(.horizontal)
                .padding(.bottom, 4)

            Spacer()

            // Center: deck during ceremony, or play area during gameplay
            if viewModel.isDealCeremony {
                dealCeremonyView
                    .transition(.opacity)
            } else {
                VStack(spacing: 6) {
                    // Play area
                    PlayAreaView(
                        playPile: viewModel.playPile,
                        runningTotal: viewModel.runningTotal,
                        starter: viewModel.starter,
                        starterCeremonyPhase: viewModel.starterCeremonyPhase
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
                            .foregroundStyle(CribbageTheme.ivory)
                            .padding(.vertical, 4)
                            .transition(.opacity)
                    }

                    // Last action message
                    if viewModel.statusMessage == nil, let lastAction = viewModel.lastAction {
                        Text(lastAction.message)
                            .font(.caption)
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                            .padding(.vertical, 2)
                    }
                }
            }

            Spacer()

            // Action bar
            ActionBarView()
                .padding(.bottom, 4)

            // Player's hand with turn glow
            ZStack {
                if viewModel.yourTurn && viewModel.phase == .play {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(CribbageTheme.gold.opacity(0.12))
                        .blur(radius: 14)
                        .frame(height: 130)
                }
                playerHand
            }
            .padding(.bottom, 8)

            // Player info
            playerInfo
                .padding(.horizontal)
                .padding(.bottom, 4)
        }
        .feltBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Round \(viewModel.roundNumber)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CribbageTheme.gold)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.engine = nil
                    viewModel.selectedIndices = []
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(CribbageTheme.ivory)
                }
            }
        }
        .toolbarBackground(themeManager.activeTable.secondaryColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .animation(.easeInOut(duration: 0.3), value: viewModel.phase)
        .animation(.easeInOut(duration: 0.3), value: viewModel.dealPhase)
    }

    // MARK: - Deal Ceremony View

    private var dealCeremonyView: some View {
        VStack(spacing: 16) {
            DeckView(
                cardCount: 52,
                isShuffling: viewModel.dealPhase == .shuffling
            )

            if viewModel.dealPhase == .shuffling {
                Text("Shuffling...")
                    .font(.subheadline)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                    .transition(.opacity)
            } else if case .dealing(let n) = viewModel.dealPhase {
                Text("Dealing... \(n + 1)/6")
                    .font(.subheadline)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Score Bar

    private var scoreBar: some View {
        HStack {
            // Player score
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0.37, green: 0.65, blue: 0.95))
                        .frame(width: 8, height: 8)
                    Text(viewModel.humanName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory)
                }
                Text("\(viewModel.humanScore)")
                    .font(.title3.bold())
                    .foregroundStyle(CribbageTheme.gold)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.3), value: viewModel.humanScore)
            }

            Spacer()

            // Crib + dealer indicator
            VStack(spacing: 2) {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundStyle(CribbageTheme.gold.opacity(0.8))
                    .font(.caption)
                Text("Crib: \(viewModel.cribCount)")
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            }

            Spacer()

            // Opponent score
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text(viewModel.opponentName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory)
                    Circle()
                        .fill(Color(red: 0.94, green: 0.35, blue: 0.35))
                        .frame(width: 8, height: 8)
                }
                Text("\(viewModel.opponentScore)")
                    .font(.title3.bold())
                    .foregroundStyle(CribbageTheme.gold)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.3), value: viewModel.opponentScore)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [themeManager.activeBoard.woodLight, themeManager.activeBoard.woodDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        )
    }

    // MARK: - Opponent Area

    private var opponentArea: some View {
        HStack(spacing: 4) {
            if viewModel.isDealCeremony {
                // Show dealt opponent cards appearing during ceremony
                let oppCount = viewModel.dealtCardCount
                ForEach(0..<oppCount, id: \.self) { _ in
                    CardView(card: Card(suit: .spades, rank: .ace), isFaceDown: true, isSmall: true)
                }
            } else if viewModel.opponentHandCount > 0 {
                ForEach(0..<viewModel.opponentHandCount, id: \.self) { _ in
                    CardView(card: Card(suit: .spades, rank: .ace), isFaceDown: true, isSmall: true)
                }
            } else if viewModel.phase == .play {
                Text("No cards")
                    .font(.caption)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
            }
        }
    }

    // MARK: - Player Hand

    private var playerHand: some View {
        Group {
            if viewModel.isDealCeremony {
                // During deal ceremony, show cards as they're dealt
                CardFanView(
                    cards: viewModel.humanHand,
                    selectedIndices: [],
                    selectable: false,
                    visibleCount: viewModel.dealtCardCount,
                    dealFromDeck: true
                )
            } else if viewModel.phase == .discard {
                CardFanView(
                    cards: viewModel.humanHand,
                    selectedIndices: viewModel.selectedIndices,
                    selectable: viewModel.dealPhase == .ready,
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
                    .foregroundStyle(CribbageTheme.gold)
            }
            Spacer()
            if viewModel.opponentIsDealer {
                Label("Dealer", systemImage: "d.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.gold)
            }
        }
    }
}
