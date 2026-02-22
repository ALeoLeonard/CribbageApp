import Foundation

// MARK: - Game Phase

enum GamePhase: String {
    case discard
    case play
    case countNonDealer = "count_non_dealer"
    case countDealer = "count_dealer"
    case countCrib = "count_crib"
    case gameOver = "game_over"
}

// MARK: - Score Event

struct ScoreEvent: Identifiable {
    let id = UUID()
    var player: String
    let points: Int
    let reason: String
}

// MARK: - Last Action

struct LastAction: Identifiable {
    let id = UUID()
    let actor: String
    let action: String // "play", "go", "discard", "score"
    let card: Card?
    let scoreEvents: [ScoreEvent]
    let message: String

    init(
        actor: String,
        action: String,
        card: Card? = nil,
        scoreEvents: [ScoreEvent] = [],
        message: String = ""
    ) {
        self.actor = actor
        self.action = action
        self.card = card
        self.scoreEvents = scoreEvents
        self.message = message
    }
}

// MARK: - Score Breakdown

struct ScoreBreakdown {
    let hand: [Card]
    let starter: Card
    let items: [ScoreEvent]
    let total: Int
}

// MARK: - Player State

struct PlayerState {
    var name: String
    var hand: [Card] = []
    var score: Int = 0
    var isDealer: Bool = false
}

// MARK: - Game Stats

struct GameStatsData {
    var handScores: [Int] = []
    var cribScores: [Int] = []
    var highestHandScore: Int = 0
    var totalPointsScored: Int = 0
}
