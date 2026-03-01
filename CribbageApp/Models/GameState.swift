import Foundation

// MARK: - Skunk Result

enum SkunkResult: String {
    case none
    case skunk       // Loser < 91 points
    case doubleSkunk // Loser < 61 points

    var label: String {
        switch self {
        case .none: return ""
        case .skunk: return "Skunk!"
        case .doubleSkunk: return "Double Skunk!"
        }
    }
}

// MARK: - Card Sort Preference

enum CardSortPreference: String, CaseIterable {
    case dealt = "As Dealt"
    case byRank = "By Rank"
    case bySuit = "By Suit"
}

// MARK: - Game Phase

enum GamePhase: String, Codable {
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

// MARK: - Muggins Result

struct MugginsResult {
    let claimedScore: Int
    let actualScore: Int
    var mugginsPoints: Int { max(0, actualScore - claimedScore) }
    var isPerfect: Bool { claimedScore == actualScore }
    var overClaimed: Bool { claimedScore > actualScore }
}

// MARK: - Streak Milestone

enum StreakMilestone {
    case rolling     // 3 wins
    case hotStreak   // 5 wins
    case legendary   // 10 wins
    case domination  // 20 wins

    var label: String {
        switch self {
        case .rolling: return "On a Roll!"
        case .hotStreak: return "Hot Streak!"
        case .legendary: return "Legendary!"
        case .domination: return "Domination!"
        }
    }

    var confettiCount: Int {
        switch self {
        case .rolling: return 80
        case .hotStreak: return 120
        case .legendary: return 180
        case .domination: return 250
        }
    }
}

// MARK: - Game Stats

struct GameStatsData {
    var handScores: [Int] = []
    var cribScores: [Int] = []
    var highestHandScore: Int = 0
    var totalPointsScored: Int = 0
}
