import Foundation

/// Syncs stats and unlocked themes across devices via iCloud Key-Value Store.
@MainActor @Observable
final class CloudSyncManager {

    static let shared = CloudSyncManager()

    private let kvStore = NSUbiquitousKeyValueStore.default

    private init() {}

    // MARK: - Listening

    func startListening() {
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: kvStore,
            queue: .main
        ) { [weak self] notification in
            let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
            Task { @MainActor in
                self?.handleExternalChange(reason: reason)
            }
        }
        kvStore.synchronize()
    }

    // MARK: - Push

    func pushStats() {
        let stats = StatsManager.shared

        kvStore.set(Int64(stats.totalGamesPlayed), forKey: "sync.totalGamesPlayed")
        kvStore.set(Int64(stats.totalWins), forKey: "sync.totalWins")
        kvStore.set(Int64(stats.totalLosses), forKey: "sync.totalLosses")
        kvStore.set(Int64(stats.currentWinStreak), forKey: "sync.currentWinStreak")
        kvStore.set(Int64(stats.bestWinStreak), forKey: "sync.bestWinStreak")
        kvStore.set(Int64(stats.highestHandScore), forKey: "sync.highestHandScore")
        kvStore.set(Int64(stats.highestCribScore), forKey: "sync.highestCribScore")
        kvStore.set(Int64(stats.totalHandPoints), forKey: "sync.totalHandPoints")
        kvStore.set(Int64(stats.totalHandsCounted), forKey: "sync.totalHandsCounted")
        kvStore.set(Int64(stats.skunksGiven), forKey: "sync.skunksGiven")
        kvStore.set(Int64(stats.skunksReceived), forKey: "sync.skunksReceived")
        kvStore.set(Int64(stats.doubleSkunksGiven), forKey: "sync.doubleSkunksGiven")
        kvStore.set(Int64(stats.doubleSkunksReceived), forKey: "sync.doubleSkunksReceived")
        kvStore.set(Int64(stats.totalPeggingPoints), forKey: "sync.totalPeggingPoints")
        kvStore.set(Int64(stats.totalPeggingRounds), forKey: "sync.totalPeggingRounds")
        kvStore.set(stats.winsPerDifficulty, forKey: "sync.winsPerDifficulty")

        // Theme IDs
        let themeIDs = Array(ThemeManager.shared.unlockedThemeIDs)
        kvStore.set(themeIDs, forKey: "sync.unlockedThemeIDs")

        kvStore.synchronize()
    }

    // MARK: - Pull & Merge

    func pullAndMerge() {
        kvStore.synchronize()

        let stats = StatsManager.shared

        // Merge strategy: MAX for cumulative stats
        mergeMax(localKey: "stats.totalGamesPlayed", syncKey: "sync.totalGamesPlayed", current: stats.totalGamesPlayed) { stats.totalGamesPlayed = $0 }
        mergeMax(localKey: "stats.totalWins", syncKey: "sync.totalWins", current: stats.totalWins) { stats.totalWins = $0 }
        mergeMax(localKey: "stats.totalLosses", syncKey: "sync.totalLosses", current: stats.totalLosses) { stats.totalLosses = $0 }
        mergeMax(localKey: "stats.currentWinStreak", syncKey: "sync.currentWinStreak", current: stats.currentWinStreak) { stats.currentWinStreak = $0 }
        mergeMax(localKey: "stats.bestWinStreak", syncKey: "sync.bestWinStreak", current: stats.bestWinStreak) { stats.bestWinStreak = $0 }
        mergeMax(localKey: "stats.highestHandScore", syncKey: "sync.highestHandScore", current: stats.highestHandScore) { stats.highestHandScore = $0 }
        mergeMax(localKey: "stats.highestCribScore", syncKey: "sync.highestCribScore", current: stats.highestCribScore) { stats.highestCribScore = $0 }
        mergeMax(localKey: "stats.totalHandPoints", syncKey: "sync.totalHandPoints", current: stats.totalHandPoints) { stats.totalHandPoints = $0 }
        mergeMax(localKey: "stats.totalHandsCounted", syncKey: "sync.totalHandsCounted", current: stats.totalHandsCounted) { stats.totalHandsCounted = $0 }
        mergeMax(localKey: "stats.skunksGiven", syncKey: "sync.skunksGiven", current: stats.skunksGiven) { stats.skunksGiven = $0 }
        mergeMax(localKey: "stats.skunksReceived", syncKey: "sync.skunksReceived", current: stats.skunksReceived) { stats.skunksReceived = $0 }
        mergeMax(localKey: "stats.doubleSkunksGiven", syncKey: "sync.doubleSkunksGiven", current: stats.doubleSkunksGiven) { stats.doubleSkunksGiven = $0 }
        mergeMax(localKey: "stats.doubleSkunksReceived", syncKey: "sync.doubleSkunksReceived", current: stats.doubleSkunksReceived) { stats.doubleSkunksReceived = $0 }
        mergeMax(localKey: "stats.totalPeggingPoints", syncKey: "sync.totalPeggingPoints", current: stats.totalPeggingPoints) { stats.totalPeggingPoints = $0 }
        mergeMax(localKey: "stats.totalPeggingRounds", syncKey: "sync.totalPeggingRounds", current: stats.totalPeggingRounds) { stats.totalPeggingRounds = $0 }

        // Merge winsPerDifficulty — MAX per key
        if let remoteDict = kvStore.dictionary(forKey: "sync.winsPerDifficulty") as? [String: Int] {
            var merged = stats.winsPerDifficulty
            for (key, remoteVal) in remoteDict {
                merged[key] = max(merged[key, default: 0], remoteVal)
            }
            stats.winsPerDifficulty = merged
        }

        // Merge theme IDs — UNION
        if let remoteThemes = kvStore.array(forKey: "sync.unlockedThemeIDs") as? [String] {
            let themes = ThemeManager.shared
            themes.unlockedThemeIDs = themes.unlockedThemeIDs.union(Set(remoteThemes))
        }
    }

    // MARK: - Private

    private func handleExternalChange(reason: Int?) {
        guard let reason else {
            pullAndMerge()
            return
        }

        switch reason {
        case NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreInitialSyncChange,
             NSUbiquitousKeyValueStoreAccountChange:
            pullAndMerge()
        default:
            break
        }
    }

    private func mergeMax(localKey: String, syncKey: String, current: Int, apply: (Int) -> Void) {
        let remote = Int(kvStore.longLong(forKey: syncKey))
        if remote > current {
            apply(remote)
        }
    }
}
