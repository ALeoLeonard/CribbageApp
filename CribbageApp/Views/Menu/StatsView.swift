import SwiftUI

struct StatsView: View {
    private let stats = StatsManager.shared
    @State private var showResetConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Win/Loss summary
                summaryCard

                // Records
                recordsCard

                // Per-difficulty breakdown
                difficultyCard

                // Reset button
                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    Label("Reset Statistics", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.red.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .confirmationDialog("Reset all statistics?", isPresented: $showResetConfirm) {
                    Button("Reset", role: .destructive) {
                        stats.resetAll()
                    }
                }
            }
            .padding(.vertical)
        }
        .feltBackground()
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CribbageTheme.feltGreenDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CribbageTheme.gold)

            HStack(spacing: 0) {
                statColumn(value: "\(stats.totalGamesPlayed)", label: "Played")
                statDivider
                statColumn(value: "\(stats.totalWins)", label: "Wins")
                statDivider
                statColumn(value: "\(stats.totalLosses)", label: "Losses")
                statDivider
                statColumn(value: winRateText, label: "Win %")
            }
        }
        .padding()
        .background(statsCardBackground)
        .padding(.horizontal)
    }

    // MARK: - Records Card

    private var recordsCard: some View {
        VStack(spacing: 12) {
            Text("Records")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CribbageTheme.gold)

            VStack(spacing: 8) {
                statRow(icon: "flame.fill", label: "Current Streak", value: "\(stats.currentWinStreak)")
                statRow(icon: "trophy.fill", label: "Best Streak", value: "\(stats.bestWinStreak)")
                Divider().overlay(CribbageTheme.gold.opacity(0.2))
                statRow(icon: "hand.raised.fill", label: "Best Hand", value: "\(stats.highestHandScore)")
                statRow(icon: "rectangle.stack.fill", label: "Best Crib", value: "\(stats.highestCribScore)")
                statRow(icon: "chart.bar.fill", label: "Avg Hand", value: avgHandText)
            }
        }
        .padding()
        .background(statsCardBackground)
        .padding(.horizontal)
    }

    // MARK: - Difficulty Card

    private var difficultyCard: some View {
        VStack(spacing: 12) {
            Text("Wins by Difficulty")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CribbageTheme.gold)

            HStack(spacing: 0) {
                ForEach(AIDifficulty.allCases) { diff in
                    let wins = stats.winsPerDifficulty[diff.rawValue] ?? 0
                    statColumn(value: "\(wins)", label: diff.displayName)
                    if diff != AIDifficulty.allCases.last {
                        statDivider
                    }
                }
            }
        }
        .padding()
        .background(statsCardBackground)
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(CribbageTheme.ivory)
            Text(label)
                .font(.caption)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(CribbageTheme.gold.opacity(0.2))
            .frame(width: 1, height: 40)
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(CribbageTheme.gold)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CribbageTheme.ivory)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(CribbageTheme.gold)
        }
    }

    private var statsCardBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(CribbageTheme.feltGreenDark.opacity(0.8))
            .strokeBorder(CribbageTheme.gold.opacity(0.2), lineWidth: 1)
    }

    private var winRateText: String {
        stats.totalGamesPlayed > 0
            ? "\(Int(stats.winRate * 100))%"
            : "—"
    }

    private var avgHandText: String {
        stats.totalHandsCounted > 0
            ? String(format: "%.1f", stats.averageHandScore)
            : "—"
    }
}
