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

    // MARK: - Achievement IDs

    enum Achievement: String, CaseIterable {
        case perfect29 = "com.cribbage.achievement.perfect29"
        case hand24plus = "com.cribbage.achievement.hand24plus"
        case flush = "com.cribbage.achievement.flush"
        case nobs = "com.cribbage.achievement.nobs"
        case streak3 = "com.cribbage.achievement.streak3"
        case streak5 = "com.cribbage.achievement.streak5"
        case streak10 = "com.cribbage.achievement.streak10"
        case firstwin = "com.cribbage.achievement.firstwin"
        case games50 = "com.cribbage.achievement.games50"
        case games100 = "com.cribbage.achievement.games100"
        case firstskunk = "com.cribbage.achievement.firstskunk"
        case doubleskunk = "com.cribbage.achievement.doubleskunk"
        case winonhard = "com.cribbage.achievement.winonhard"
    }

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

    // MARK: - Achievements

    func unlockAchievement(_ achievement: Achievement) {
        guard isAuthenticated else { return }
        Task {
            let gkAchievement = GKAchievement(identifier: achievement.rawValue)
            gkAchievement.percentComplete = 100
            gkAchievement.showsCompletionBanner = true
            do {
                try await GKAchievement.report([gkAchievement])
                AnalyticsManager.shared.trackAchievementUnlocked(achievementID: achievement.rawValue)
            } catch {
                print("Achievement report error: \(error.localizedDescription)")
            }
        }
    }

    func reportProgress(_ achievement: Achievement, current: Int, goal: Int) {
        guard isAuthenticated, goal > 0 else { return }
        let percent = min(Double(current) / Double(goal) * 100, 100)
        Task {
            let gkAchievement = GKAchievement(identifier: achievement.rawValue)
            gkAchievement.percentComplete = percent
            gkAchievement.showsCompletionBanner = true
            do {
                try await GKAchievement.report([gkAchievement])
                if percent >= 100 {
                    AnalyticsManager.shared.trackAchievementUnlocked(achievementID: achievement.rawValue)
                }
            } catch {
                print("Achievement progress error: \(error.localizedDescription)")
            }
        }
    }

    /// Batch-check all achievements against current stats on launch.
    func checkAllAchievements() {
        let stats = StatsManager.shared

        if stats.totalWins >= 1 { unlockAchievement(.firstwin) }
        if stats.bestWinStreak >= 3 { unlockAchievement(.streak3) }
        if stats.bestWinStreak >= 5 { unlockAchievement(.streak5) }
        if stats.bestWinStreak >= 10 { unlockAchievement(.streak10) }
        if stats.skunksGiven > 0 { unlockAchievement(.firstskunk) }
        if stats.doubleSkunksGiven > 0 { unlockAchievement(.doubleskunk) }
        if (stats.winsPerDifficulty["hard"] ?? 0) >= 1 { unlockAchievement(.winonhard) }

        // Progress-based
        reportProgress(.games50, current: stats.totalGamesPlayed, goal: 50)
        reportProgress(.games100, current: stats.totalGamesPlayed, goal: 100)
    }
}
