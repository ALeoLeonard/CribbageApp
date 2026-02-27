import Foundation

// MARK: - WebSocket Message Envelopes

struct WSMessage: Codable {
    let type: String
}

struct WSGameStateMessage: Codable {
    let type: String
    let state: ServerGameState
}

struct WSErrorMessage: Codable {
    let type: String
    let message: String
}

struct WSWaitingMessage: Codable {
    let type: String
    let message: String
}

struct WSPrivateCreatedMessage: Codable {
    let type: String
    let code: String
}

struct WSChatMessage: Codable {
    let type: String
    let message: String
}

// MARK: - Server Game State

struct ServerGameState: Codable {
    let gameId: String
    let phase: String
    let yourHand: [ServerCard]
    let opponentHandCount: Int
    let yourScore: Int
    let opponentScore: Int
    let yourName: String
    let opponentName: String
    let youAreDealer: Bool
    let starter: ServerCard?
    let playPile: [ServerCard]
    let runningTotal: Int
    let cribCount: Int
    let roundNumber: Int
    let yourTurn: Bool
    let canPlay: Bool
    let lastAction: ServerLastAction?
    let scoreBreakdown: ServerScoreBreakdown?
    let winner: String?

    enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
        case phase
        case yourHand = "your_hand"
        case opponentHandCount = "opponent_hand_count"
        case yourScore = "your_score"
        case opponentScore = "opponent_score"
        case yourName = "your_name"
        case opponentName = "opponent_name"
        case youAreDealer = "you_are_dealer"
        case starter
        case playPile = "play_pile"
        case runningTotal = "running_total"
        case cribCount = "crib_count"
        case roundNumber = "round_number"
        case yourTurn = "your_turn"
        case canPlay = "can_play"
        case lastAction = "last_action"
        case scoreBreakdown = "score_breakdown"
        case winner
    }
}

struct ServerCard: Codable {
    let rank: String
    let suit: String

    func toCard() -> Card {
        let cardSuit: Suit = switch suit.lowercased() {
        case "hearts", "\u{2665}": .hearts
        case "diamonds", "\u{2666}": .diamonds
        case "clubs", "\u{2663}": .clubs
        default: .spades
        }
        let cardRank: Rank = switch rank.uppercased() {
        case "A": .ace
        case "2": .two
        case "3": .three
        case "4": .four
        case "5": .five
        case "6": .six
        case "7": .seven
        case "8": .eight
        case "9": .nine
        case "10": .ten
        case "J": .jack
        case "Q": .queen
        case "K": .king
        default: .ace
        }
        return Card(suit: cardSuit, rank: cardRank)
    }
}

struct ServerLastAction: Codable {
    let actor: String
    let action: String
    let card: ServerCard?
    let message: String
    let scoreEvents: [ServerScoreEvent]

    enum CodingKeys: String, CodingKey {
        case actor, action, card, message
        case scoreEvents = "score_events"
    }

    func toLastAction() -> LastAction {
        LastAction(
            actor: actor,
            action: action,
            card: card?.toCard(),
            scoreEvents: scoreEvents.map { $0.toScoreEvent() },
            message: message
        )
    }
}

struct ServerScoreEvent: Codable {
    let player: String
    let points: Int
    let reason: String

    func toScoreEvent() -> ScoreEvent {
        ScoreEvent(player: player, points: points, reason: reason)
    }
}

struct ServerScoreBreakdown: Codable {
    let hand: [ServerCard]
    let starter: ServerCard
    let items: [ServerScoreEvent]
    let total: Int

    func toScoreBreakdown() -> ScoreBreakdown {
        ScoreBreakdown(
            hand: hand.map { $0.toCard() },
            starter: starter.toCard(),
            items: items.map { $0.toScoreEvent() },
            total: total
        )
    }
}

// MARK: - Client -> Server Messages

struct WSClientMessage: Encodable {
    let type: String
    var name: String?
    var code: String?
    var cardIndices: [Int]?
    var cardIndex: Int?
    var message: String?
    var token: String?

    enum CodingKeys: String, CodingKey {
        case type, name, code, message, token
        case cardIndices = "card_indices"
        case cardIndex = "card_index"
    }
}
