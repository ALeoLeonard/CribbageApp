import SwiftUI

struct GameOverView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(ThemeManager.self) private var themeManager
    let winner: String
    @State private var trophyPulsing = false

    var playerWon: Bool { winner == viewModel.humanName }

    var body: some View {
        ZStack {
            // Confetti for wins
            if playerWon {
                ConfettiView()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 24) {
                Spacer()

                // Trophy icon
                Image(systemName: playerWon ? "trophy.fill" : "hand.thumbsdown.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(playerWon ? CribbageTheme.gold : CribbageTheme.ivory.opacity(0.4))
                    .shadow(
                        color: playerWon ? CribbageTheme.gold.opacity(trophyPulsing ? 0.6 : 0.2) : .clear,
                        radius: trophyPulsing ? 16 : 6
                    )
                    .scaleEffect(playerWon ? (trophyPulsing ? 1.05 : 1.0) : 0.85)
                    .scorePop()
                    .onAppear {
                        if playerWon {
                            HapticManager.success()
                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                trophyPulsing = true
                            }
                        } else {
                            HapticManager.error()
                        }
                    }

                // Result
                Text(playerWon ? "You Win!" : "You Lose")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(playerWon ? CribbageTheme.gold : CribbageTheme.ivory)

                // Final scores
                VStack(spacing: 8) {
                    scoreRow(name: viewModel.humanName, score: viewModel.humanScore, highlight: playerWon)
                    scoreRow(name: viewModel.opponentName, score: viewModel.opponentScore, highlight: !playerWon)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [themeManager.activeBoard.woodLight, themeManager.activeBoard.woodDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                )
                .padding(.horizontal)

                // Quick stats
                quickStats

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        viewModel.restartGame()
                    } label: {
                        Label("Play Again", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CribbageTheme.feltGreenDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: CribbageTheme.gold.opacity(0.3), radius: 4, y: 2)
                    }

                    Button {
                        viewModel.engine = nil
                        viewModel.selectedIndices = []
                    } label: {
                        Label("Main Menu", systemImage: "house.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CribbageTheme.ivory)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(CribbageTheme.gold.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .feltBackground()
    }

    private var quickStats: some View {
        let stats = StatsManager.shared
        return HStack(spacing: 20) {
            VStack(spacing: 2) {
                Text("\(stats.totalWins)")
                    .font(.subheadline.bold())
                    .foregroundStyle(CribbageTheme.gold)
                Text("Wins")
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            }
            VStack(spacing: 2) {
                Text("\(stats.currentWinStreak)")
                    .font(.subheadline.bold())
                    .foregroundStyle(CribbageTheme.gold)
                Text("Streak")
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            }
            VStack(spacing: 2) {
                Text(stats.totalGamesPlayed > 0 ? "\(Int(stats.winRate * 100))%" : "—")
                    .font(.subheadline.bold())
                    .foregroundStyle(CribbageTheme.gold)
                Text("Win %")
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            }
        }
    }

    private func scoreRow(name: String, score: Int, highlight: Bool) -> some View {
        HStack {
            Text(name)
                .font(.headline)
                .foregroundStyle(CribbageTheme.ivory)
            Spacer()
            Text("\(score)")
                .font(.title2.bold())
                .foregroundStyle(highlight ? CribbageTheme.gold : CribbageTheme.ivory.opacity(0.7))
        }
    }
}

// MARK: - Confetti

private struct ConfettiView: View {
    @State private var animating = false

    private let particleCount = 60
    private let colors: [Color] = [
        CribbageTheme.gold, CribbageTheme.goldLight,
        .red, .blue, .green, .orange, .purple, .pink
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                for i in 0..<particleCount {
                    let seed = Double(i)
                    let x = fmod((seed * 137.508 + time * (30 + seed * 2)), size.width)
                    let fallSpeed = 50 + seed * 3
                    let y = fmod(seed * 73.13 + time * fallSpeed, size.height + 40) - 20
                    let wobble = sin(time * 3 + seed) * 8
                    let rotation = Angle.degrees(time * (60 + seed * 5))
                    let colorIndex = Int(seed) % colors.count
                    let particleSize: CGFloat = 4 + CGFloat(fmod(seed * 3.7, 4))

                    context.translateBy(x: x + wobble, y: y)
                    context.rotate(by: rotation)
                    context.fill(
                        Path(CGRect(x: -particleSize / 2, y: -particleSize / 2,
                                    width: particleSize, height: particleSize * 0.6)),
                        with: .color(colors[colorIndex])
                    )
                    context.rotate(by: -rotation)
                    context.translateBy(x: -(x + wobble), y: -y)
                }
            }
        }
        .ignoresSafeArea()
    }
}
