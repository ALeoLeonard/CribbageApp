import Foundation

/// Persists game statistics to UserDefaults.
@MainActor @Observable
final class StatsManager {

    static let shared = StatsManager()

    // MARK: - Persisted stats

    var totalGamesPlayed: Int {
        get { defaults.integer(forKey: "stats.totalGamesPlayed") }
        set { defaults.set(newValue, forKey: "stats.totalGamesPlayed") }
    }

    var totalWins: Int {
        get { defaults.integer(forKey: "stats.totalWins") }
        set { defaults.set(newValue, forKey: "stats.totalWins") }
    }

    var totalLosses: Int {
        get { defaults.integer(forKey: "stats.totalLosses") }
        set { defaults.set(newValue, forKey: "stats.totalLosses") }
    }

    var currentWinStreak: Int {
        get { defaults.integer(forKey: "stats.currentWinStreak") }
        set { defaults.set(newValue, forKey: "stats.currentWinStreak") }
    }

    var bestWinStreak: Int {
        get { defaults.integer(forKey: "stats.bestWinStreak") }
        set { defaults.set(newValue, forKey: "stats.bestWinStreak") }
    }

    var highestHandScore: Int {
        get { defaults.integer(forKey: "stats.highestHandScore") }
        set { defaults.set(newValue, forKey: "stats.highestHandScore") }
    }

    var highestCribScore: Int {
        get { defaults.integer(forKey: "stats.highestCribScore") }
        set { defaults.set(newValue, forKey: "stats.highestCribScore") }
    }

    var totalHandPoints: Int {
        get { defaults.integer(forKey: "stats.totalHandPoints") }
        set { defaults.set(newValue, forKey: "stats.totalHandPoints") }
    }

    var totalHandsCounted: Int {
        get { defaults.integer(forKey: "stats.totalHandsCounted") }
        set { defaults.set(newValue, forKey: "stats.totalHandsCounted") }
    }

    var winsPerDifficulty: [String: Int] {
        get { defaults.dictionary(forKey: "stats.winsPerDifficulty") as? [String: Int] ?? [:] }
        set { defaults.set(newValue, forKey: "stats.winsPerDifficulty") }
    }

    // MARK: - Computed

    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalWins) / Double(totalGamesPlayed)
    }

    var averageHandScore: Double {
        guard totalHandsCounted > 0 else { return 0 }
        return Double(totalHandPoints) / Double(totalHandsCounted)
    }

    // MARK: - Actions

    func recordGameResult(won: Bool, difficulty: AIDifficulty) {
        totalGamesPlayed += 1
        if won {
            totalWins += 1
            currentWinStreak += 1
            bestWinStreak = max(bestWinStreak, currentWinStreak)
            var perDiff = winsPerDifficulty
            perDiff[difficulty.rawValue, default: 0] += 1
            winsPerDifficulty = perDiff
        } else {
            totalLosses += 1
            currentWinStreak = 0
        }
    }

    func recordHandScore(_ score: Int) {
        totalHandPoints += score
        totalHandsCounted += 1
        highestHandScore = max(highestHandScore, score)
    }

    func recordCribScore(_ score: Int) {
        highestCribScore = max(highestCribScore, score)
    }

    func resetAll() {
        let keys = [
            "stats.totalGamesPlayed", "stats.totalWins", "stats.totalLosses",
            "stats.currentWinStreak", "stats.bestWinStreak",
            "stats.highestHandScore", "stats.highestCribScore",
            "stats.totalHandPoints", "stats.totalHandsCounted",
            "stats.winsPerDifficulty"
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Private

    private let defaults = UserDefaults.standard
    private init() {}
}
