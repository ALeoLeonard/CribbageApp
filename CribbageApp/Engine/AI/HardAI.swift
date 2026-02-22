import Foundation

/// Full evaluation over all possible starters; strategic pegging with offense/defense.
struct HardAI: CribbageAI {

    // MARK: - Crib Estimation

    /// Rough estimate of how valuable two discards are in a crib.
    private func estimateCribValue(_ discarded: [Card]) -> Double {
        guard discarded.count == 2 else { return 0 }
        let d0 = discarded[0], d1 = discarded[1]
        var value = 0.0

        // 5s are extremely valuable in crib
        for c in discarded {
            if c.value == 5 { value += 2.5 }
        }

        // Cards that sum to 15
        if d0.value + d1.value == 15 { value += 2.0 }

        // Pairs
        if d0.rank == d1.rank { value += 2.0 }

        // Adjacent ranks have run potential
        let diff = abs(d0.rank.order - d1.rank.order)
        if diff == 1 { value += 1.0 }
        else if diff == 2 { value += 0.5 }

        // Same suit has flush potential
        if d0.suit == d1.suit { value += 0.5 }

        return value
    }

    // MARK: - Discard

    func chooseDiscards(hand: [Card], isDealer: Bool) -> [Int] {
        let allCards = Deck.createDeck()
        let handSet = Set(hand)

        var bestAvg = -Double.infinity
        var bestIndices = [0, 1]

        for i in 0..<hand.count {
            for j in (i + 1)..<hand.count {
                let kept = hand.enumerated()
                    .filter { $0.offset != i && $0.offset != j }
                    .map(\.element)
                let discarded = [hand[i], hand[j]]

                // Evaluate over all 46 possible starters
                var totalScore = 0
                var count = 0
                for card in allCards where !handSet.contains(card) {
                    totalScore += Scoring.calculateScore(hand: kept, starter: card).total
                    count += 1
                }

                var avg = count > 0 ? Double(totalScore) / Double(count) : 0

                // Adjust for crib value
                let cribEst = estimateCribValue(discarded)
                avg += isDealer ? cribEst : -cribEst

                if avg > bestAvg {
                    bestAvg = avg
                    bestIndices = [i, j]
                }
            }
        }

        return bestIndices.sorted()
    }

    // MARK: - Play

    func pickPlay(hand: [Card], playable: [Int], playPile: [Card], runningTotal: Int) -> Int {
        // Score each candidate play: (index, offensivePoints, defensivePenalty)
        var scored: [(index: Int, pts: Int, penalty: Double)] = []

        for i in playable {
            let card = hand[i]
            let newTotal = runningTotal + card.value
            let simPile = playPile + [card]
            let events = Scoring.calculatePlayScore(playPile: simPile, runningTotal: newTotal)
            let pts = events.reduce(0) { $0 + $1.points }

            var penalty = 0.0
            // Leaving total at 5 or 21 lets opponent hit 15 or 31 easily
            if newTotal == 5 || newTotal == 21 { penalty += 2.0 }
            // Exposing rank for a pair opportunity
            if let lastPlayed = playPile.last, lastPlayed.rank == card.rank {
                // Making a pair — good offensively, risk of triple
            } else if newTotal < 31 {
                penalty += 0.3
            }

            scored.append((i, pts, penalty))
        }

        // Pick highest (pts - penalty), break ties randomly
        scored.shuffle()
        scored.sort { ($0.pts.double - $0.penalty) > ($1.pts.double - $1.penalty) }
        return scored[0].index
    }
}

private extension Int {
    var double: Double { Double(self) }
}
