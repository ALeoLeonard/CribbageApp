import Foundation

/// Placeholder ad manager — tracks game count for future interstitial cadence.
/// Drop in AdMob SDK calls in `presentInterstitial()` without changing the interface.
@MainActor @Observable
final class AdManager {

    static let shared = AdManager()

    var shouldShowAds: Bool {
        !StoreManager.shared.isPremium
    }

    private let gamesPerInterstitial = 3
    private var gamesSinceLastAd: Int = 0

    private init() {}

    /// Record a completed game. Returns `true` if an interstitial should be shown.
    @discardableResult
    func recordGameCompleted() -> Bool {
        guard shouldShowAds else { return false }
        gamesSinceLastAd += 1
        return gamesSinceLastAd >= gamesPerInterstitial
    }

    /// Present an interstitial ad (placeholder — resets counter).
    func presentInterstitial() {
        guard shouldShowAds else { return }
        // Future: call AdMob interstitial present here
        gamesSinceLastAd = 0
    }
}
