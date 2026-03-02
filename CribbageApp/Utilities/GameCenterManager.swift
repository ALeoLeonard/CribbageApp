import Foundation
import GameKit

/// Manages Game Center authentication and leaderboard submissions.
@MainActor @Observable
final class GameCenterManager {

    static let shared = GameCenterManager()

    private(set) var isAuthenticated = false
    private(set) var localPlayerName: String?

    // MARK: - Leaderboard IDs

    static let winStreakID = "com.cribbage.leaderboard.winstreak"
    static let highestHandID = "com.cribbage.leaderboard.highesthand"
    static let totalWinsID = "com.cribbage.leaderboard.totalwins"

    private init() {}

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, error in
            Task { @MainActor in
                guard let self else { return }
                let player = GKLocalPlayer.local
                self.isAuthenticated = player.isAuthenticated
                self.localPlayerName = player.isAuthenticated ? player.displayName : nil
                if let error {
                    print("Game Center auth error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int, leaderboardID: String) {
        guard isAuthenticated, score > 0 else { return }
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardID]
                )
            } catch {
                print("Leaderboard submit error: \(error.localizedDescription)")
            }
        }
    }

    /// Submit all stats-based leaderboard scores.
    func submitAllStats() {
        let stats = StatsManager.shared
        submitScore(stats.bestWinStreak, leaderboardID: Self.winStreakID)
        submitScore(stats.highestHandScore, leaderboardID: Self.highestHandID)
        submitScore(stats.totalWins, leaderboardID: Self.totalWinsID)
    }
}
