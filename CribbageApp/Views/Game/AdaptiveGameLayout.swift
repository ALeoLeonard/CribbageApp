import SwiftUI

struct AdaptiveGameLayout<Scores: View, Board: View, Opponent: View, Center: View, Actions: View, Hand: View, PlayerInfo: View>: View {
    let scores: Scores
    let board: Board
    let opponent: Opponent
    let center: Center
    let actions: Actions
    let hand: Hand
    let playerInfo: PlayerInfo

    init(
        @ViewBuilder scores: () -> Scores,
        @ViewBuilder board: () -> Board,
        @ViewBuilder opponent: () -> Opponent,
        @ViewBuilder center: () -> Center,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder hand: () -> Hand,
        @ViewBuilder playerInfo: () -> PlayerInfo
    ) {
        self.scores = scores()
        self.board = board()
        self.opponent = opponent()
        self.center = center()
        self.actions = actions()
        self.hand = hand()
        self.playerInfo = playerInfo()
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left column: scores, board, opponent
            VStack(spacing: 8) {
                scores
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                board
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                opponent
                    .padding(.horizontal)
                Spacer()
                playerInfo
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .background(CribbageTheme.gold.opacity(0.3))

            // Right column: play area, actions, hand
            VStack(spacing: 0) {
                Spacer()
                center
                Spacer()
                actions
                    .padding(.bottom, 4)
                hand
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
