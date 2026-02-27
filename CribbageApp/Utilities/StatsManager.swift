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

    // Skunk tracking
    var skunksGiven: Int {
        get { defaults.integer(forKey: "stats.skunksGiven") }
        set { defaults.set(newValue, forKey: "stats.skunksGiven") }
    }

    var skunksReceived: Int {
        get { defaults.integer(forKey: "stats.skunksReceived") }
        set { defaults.set(newValue, forKey: "stats.skunksReceived") }
    }

    var doubleSkunksGiven: Int {
        get { defaults.integer(forKey: "stats.doubleSkunksGiven") }
        set { defaults.set(newValue, forKey: "stats.doubleSkunksGiven") }
    }

    var doubleSkunksReceived: Int {
        get { defaults.integer(forKey: "stats.doubleSkunksReceived") }
        set { defaults.set(newValue, forKey: "stats.doubleSkunksReceived") }
    }

    // Pegging tracking
    var totalPeggingPoints: Int {
        get { defaults.integer(forKey: "stats.totalPeggingPoints") }
        set { defaults.set(newValue, forKey: "stats.totalPeggingPoints") }
    }

    var totalPeggingRounds: Int {
        get { defaults.integer(forKey: "stats.totalPeggingRounds") }
        set { defaults.set(newValue, forKey: "stats.totalPeggingRounds") }
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

    var averagePeggingScore: Double {
        guard totalPeggingRounds > 0 else { return 0 }
        return Double(totalPeggingPoints) / Double(totalPeggingRounds)
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

    /// Record skunk result at end of game.
    /// - Parameters:
    ///   - won: Whether the human won
    ///   - winnerScore: The winner's final score
    ///   - loserScore: The loser's final score
    func recordSkunkResult(won: Bool, loserScore: Int) {
        if loserScore < 61 {
            // Double skunk
            if won {
                doubleSkunksGiven += 1
            } else {
                doubleSkunksReceived += 1
            }
        } else if loserScore < 91 {
            // Skunk
            if won {
                skunksGiven += 1
            } else {
                skunksReceived += 1
            }
        }
    }

    func recordPeggingPoints(_ points: Int) {
        totalPeggingPoints += points
        totalPeggingRounds += 1
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
            "stats.winsPerDifficulty",
            "stats.skunksGiven", "stats.skunksReceived",
            "stats.doubleSkunksGiven", "stats.doubleSkunksReceived",
            "stats.totalPeggingPoints", "stats.totalPeggingRounds"
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Private

    private let defaults = UserDefaults.standard
    private init() {}
}
