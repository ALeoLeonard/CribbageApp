import Foundation

enum Deck {
    /// Create a standard 52-card deck.
    static func createDeck() -> [Card] {
        Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in
                Card(suit: suit, rank: rank)
            }
        }
    }

    /// Return a shuffled copy of the deck.
    static func shuffled() -> [Card] {
        createDeck().shuffled()
    }

    /// Deal `n` cards from the front of `deck`, mutating it in place.
    @discardableResult
    static func deal(_ n: Int, from deck: inout [Card]) -> [Card] {
        let count = min(n, deck.count)
        let dealt = Array(deck.prefix(count))
        deck.removeFirst(count)
        return dealt
    }
}
