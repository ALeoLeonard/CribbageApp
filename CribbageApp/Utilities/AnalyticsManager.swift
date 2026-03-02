import Foundation
import TelemetryDeck

/// Privacy-friendly analytics via TelemetryDeck (no PII collected).
@MainActor @Observable
final class AnalyticsManager {

    static let shared = AnalyticsManager()

    private init() {}

    // MARK: - Setup

    func initialize() {
        #if !DEBUG
        let config = TelemetryDeck.Config(appID: "YOUR_TELEMETRYDECK_APP_ID")
        TelemetryDeck.initialize(config: config)
        #endif
    }

    // MARK: - Game Events

    func trackGameStarted(difficulty: String, isPassAndPlay: Bool) {
        TelemetryDeck.signal(
            "game.started",
            parameters: [
                "difficulty": difficulty,
                "isPassAndPlay": String(isPassAndPlay)
            ]
        )
    }

    func trackGameCompleted(difficulty: String, won: Bool, playerScore: Int, opponentScore: Int) {
        TelemetryDeck.signal(
            "game.completed",
            parameters: [
                "difficulty": difficulty,
                "won": String(won),
                "playerScore": String(playerScore),
                "opponentScore": String(opponentScore)
            ]
        )
    }

    // MARK: - Purchase Events

    func trackPurchaseCompleted(productID: String) {
        TelemetryDeck.signal(
            "purchase.completed",
            parameters: ["productID": productID]
        )
    }

    // MARK: - Theme Events

    func trackThemeChanged(themeID: String, category: String) {
        TelemetryDeck.signal(
            "theme.changed",
            parameters: [
                "themeID": themeID,
                "category": category
            ]
        )
    }

    // MARK: - Tutorial Events

    func trackTutorialCompleted() {
        TelemetryDeck.signal("tutorial.completed")
    }

    // MARK: - Achievement Events

    func trackAchievementUnlocked(achievementID: String) {
        TelemetryDeck.signal(
            "achievement.unlocked",
            parameters: ["achievementID": achievementID]
        )
    }
}
