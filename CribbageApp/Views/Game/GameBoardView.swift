import SwiftUI

struct GameBoardView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isIPadLandscape: Bool {
        sizeClass == .regular && verticalSizeClass == .regular
    }

    var body: some View {
        if let winner = viewModel.winner {
            GameOverView(winner: winner)
        } else {
            gameBoard
        }
    }

    // MARK: - Center Content

    private var centerContent: some View {
        Group {
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

                    // Scoring callouts during play
                    if !viewModel.scoringCallouts.isEmpty {
                        ScoringCalloutContainerView(callouts: viewModel.scoringCallouts)
                    }

                    // Score breakdown during counting phases
                    if viewModel.mugginsPending, let hand = viewModel.mugginsHandToCount {
                        // Muggins: show hand cards but hide score until claimed
                        MugginsHandView(
                            hand: hand,
                            starter: viewModel.starter,
                            result: viewModel.mugginsResult
                        )
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if let breakdown = viewModel.scoreBreakdown,
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
        }
    }

    // MARK: - Portrait Layout (iPhone)

    private var portraitLayout: some View {
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

            centerContent

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
    }

    private var gameBoard: some View {
        Group {
            if isIPadLandscape {
                AdaptiveGameLayout {
                    scoreBar
                } board: {
                    CribbageBoardView(playerScore: viewModel.humanScore, opponentScore: viewModel.opponentScore)
                } opponent: {
                    opponentArea
                } center: {
                    centerContent
                } actions: {
                    ActionBarView()
                } hand: {
                    ZStack {
                        if viewModel.yourTurn && viewModel.phase == .play {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(CribbageTheme.gold.opacity(0.12))
                                .blur(radius: 14)
                                .frame(height: 130)
                        }
                        playerHand
                    }
                } playerInfo: {
                    playerInfo
                }
            } else {
                portraitLayout
            }
        }
        .environment(\.cardScale, sizeClass == .regular ? 1.3 : 1.0)
        .feltBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    if viewModel.isPassAndPlay {
                        Text("Pass & Play")
                            .font(.caption2)
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
                    }
                    HStack(spacing: 6) {
                        Text("Round \(viewModel.roundNumber)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(CribbageTheme.gold)
                        if viewModel.mugginsEnabled && !viewModel.isPassAndPlay {
                            Text("M")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(CribbageTheme.feltGreenDark)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule().fill(CribbageTheme.gold.opacity(0.8))
                                )
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.engine = nil
                    viewModel.selectedIndices = []
                    viewModel.isPassAndPlay = false
                    viewModel.showingHandOver = false
                    viewModel.mugginsPending = false
                    viewModel.mugginsResult = nil
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
        .animation(.easeInOut(duration: 0.3), value: viewModel.mugginsPending)
        .animation(.easeInOut(duration: 0.3), value: viewModel.mugginsResult?.actualScore)
        .overlay {
            if viewModel.showingHandOver {
                HandOverView(playerName: viewModel.handOverPlayerName) {
                    viewModel.handOverReady()
                }
                .transition(.opacity)
            }
        }
        .overlay {
            if let step = viewModel.tutorialStep, viewModel.tutorialActive {
                TutorialOverlayView(
                    step: step,
                    onNext: { viewModel.advanceTutorial() },
                    onSkip: { viewModel.skipTutorial() }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.showingHandOver)
        .animation(.easeInOut(duration: 0.25), value: viewModel.tutorialStep)
        .onChange(of: viewModel.phase) {
            viewModel.tutorialCheckPhase()
        }
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
                ScoreLabel(score: viewModel.humanScore, color: CribbageTheme.gold)
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
                ScoreLabel(score: viewModel.opponentScore, color: CribbageTheme.gold)
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
                    hintIndices: viewModel.hintIndices,
                    onTap: { viewModel.toggleSelect($0) }
                )
            } else if viewModel.phase == .play {
                CardFanView(
                    cards: viewModel.humanHand,
                    selectedIndices: [],
                    selectable: viewModel.yourTurn && viewModel.humanCanPlay && !viewModel.isProcessing,
                    hintIndices: viewModel.hintIndices,
                    onTap: { viewModel.playCard($0) },
                    onInvalidTap: { _ in viewModel.invalidPlayAttempt() }
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

// MARK: - Score Label with Glow

/// Animated score label that pulses a glow when the value changes.
private struct ScoreLabel: View {
    let score: Int
    let color: Color

    @State private var glowing = false

    var body: some View {
        Text("\(score)")
            .font(.title3.bold())
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .animation(.easeOut(duration: 0.3), value: score)
            .background(
                Circle()
                    .fill(color.opacity(glowing ? 0.4 : 0))
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
            )
            .onChange(of: score) {
                withAnimation(.easeOut(duration: 0.15)) {
                    glowing = true
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                    glowing = false
                }
            }
    }
}
