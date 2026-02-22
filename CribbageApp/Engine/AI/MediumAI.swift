import Foundation

/// Samples starters to maximize hand score; smarter pegging.
struct MediumAI: CribbageAI {
    private let sampleSize = 8

    func chooseDiscards(hand: [Card], isDealer: Bool) -> [Int] {
        let allCards = Deck.createDeck()
        let handSet = Set(hand)
        let remaining = allCards.filter { !handSet.contains($0) }
        let sample = Array(remaining.shuffled().prefix(sampleSize))

        var bestAvg = -1.0
        var bestIndices = [0, 1]

        // Try all C(6,2) = 15 discard combos
        for i in 0..<hand.count {
            for j in (i + 1)..<hand.count {
                let kept = hand.enumerated()
                    .filter { $0.offset != i && $0.offset != j }
                    .map(\.element)
                let total = sample.reduce(0) { acc, starter in
                    acc + Scoring.calculateScore(hand: kept, starter: starter).total
                }
                let avg = Double(total) / Double(sample.count)
                if avg > bestAvg {
                    bestAvg = avg
                    bestIndices = [i, j]
                }
            }
        }

        return bestIndices.sorted()
    }

    func pickPlay(hand: [Card], playable: [Int], playPile: [Card], runningTotal: Int) -> Int {
        // Prefer hitting 31
        for i in playable {
            if runningTotal + hand[i].value == 31 { return i }
        }
        // Prefer hitting 15
        for i in playable {
            if runningTotal + hand[i].value == 15 { return i }
        }
        // Try to pair the last card played
        if let lastRank = playPile.last?.rank {
            for i in playable {
                if hand[i].rank == lastRank { return i }
            }
        }
        // Avoid leaving total at 5 or 21
        let safe = playable.filter { runningTotal + hand[$0].value != 5 && runningTotal + hand[$0].value != 21 }
        if !safe.isEmpty { return safe.randomElement()! }
        return playable.randomElement()!
    }
}
