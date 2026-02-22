import Foundation
import SwiftUI

// MARK: - Suit

enum Suit: String, CaseIterable, Codable, Hashable {
    case hearts = "Hearts"
    case diamonds = "Diamonds"
    case clubs = "Clubs"
    case spades = "Spades"

    var symbol: String {
        switch self {
        case .hearts: "♥"
        case .diamonds: "♦"
        case .clubs: "♣"
        case .spades: "♠"
        }
    }

    var color: Color {
        switch self {
        case .hearts, .diamonds: CribbageTheme.suitRed
        case .clubs, .spades: CribbageTheme.suitBlack
        }
    }
}

// MARK: - Rank

enum Rank: String, CaseIterable, Codable, Hashable {
    case ace = "A"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"

    /// Position in rank order (A=1 .. K=13) — used for runs.
    var order: Int {
        switch self {
        case .ace: 1
        case .two: 2
        case .three: 3
        case .four: 4
        case .five: 5
        case .six: 6
        case .seven: 7
        case .eight: 8
        case .nine: 9
        case .ten: 10
        case .jack: 11
        case .queen: 12
        case .king: 13
        }
    }

    /// Scoring value (A=1, 2-9 face, 10/J/Q/K=10).
    var value: Int {
        switch self {
        case .ace: 1
        case .two: 2
        case .three: 3
        case .four: 4
        case .five: 5
        case .six: 6
        case .seven: 7
        case .eight: 8
        case .nine: 9
        case .ten, .jack, .queen, .king: 10
        }
    }
}

// MARK: - Card

struct Card: Identifiable, Hashable, Codable {
    let suit: Suit
    let rank: Rank

    var id: String { "\(rank.rawValue)\(suit.rawValue)" }
    var value: Int { rank.value }
    var label: String { "\(rank.rawValue)\(suit.symbol)" }
}
