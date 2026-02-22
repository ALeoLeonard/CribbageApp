import Foundation

enum Scoring {

    // MARK: - Helpers

    /// Generate all subsets of cards (power set).
    static func getAllSubsets(_ cards: [Card]) -> [[Card]] {
        guard let first = cards.first else { return [[]] }
        let rest = getAllSubsets(Array(cards.dropFirst()))
        return rest + rest.map { $0 + [first] }
    }

    /// Find runs of 3+ consecutive ranks.
    /// Returns (runLength, multiplicity) pairs — multiplicity accounts for duplicate ranks.
    static func calculateRuns(_ combined: [Card]) -> [(length: Int, multiplicity: Int)] {
        var frequency: [Int: Int] = [:]
        for card in combined {
            frequency[card.rank.order, default: 0] += 1
        }

        let uniqueValues = frequency.keys.sorted()
        var runsFound: [(Int, Int)] = []

        for length in [5, 4, 3] {
            guard uniqueValues.count >= length else { continue }
            for startIndex in 0...(uniqueValues.count - length) {
                let slice = Array(uniqueValues[startIndex..<(startIndex + length)])
                let consecutive = zip(slice, slice.dropFirst()).allSatisfy { $1 == $0 + 1 }
                if consecutive {
                    var multiplicity = 1
                    for val in slice {
                        multiplicity *= frequency[val] ?? 0
                    }
                    if multiplicity > 0 {
                        runsFound.append((length, multiplicity))
                    }
                    // Zero out used values so they aren't counted again
                    for val in slice {
                        frequency[val] = 0
                    }
                }
            }
        }

        return runsFound
    }

    // MARK: - Hand Scoring

    /// Calculate the cribbage hand score.
    /// When `isCrib` is true, only a 5-card flush counts.
    static func calculateScore(
        hand: [Card],
        starter: Card,
        isCrib: Bool = false
    ) -> (total: Int, events: [ScoreEvent]) {
        var total = 0
        var events: [ScoreEvent] = []
        let combined = hand + [starter]

        // --- 15s ---
        var fifteensCount = 0
        for combo in getAllSubsets(combined) {
            if (2...5).contains(combo.count) {
                if combo.reduce(0, { $0 + $1.value }) == 15 {
                    fifteensCount += 1
                }
            }
        }
        if fifteensCount > 0 {
            let pts = fifteensCount * 2
            total += pts
            events.append(ScoreEvent(
                player: "", points: pts,
                reason: "\(fifteensCount) fifteen(s) for \(pts)"
            ))
        }

        // --- Pairs / Triples / Quads ---
        var rankCounts: [Rank: Int] = [:]
        for c in combined {
            rankCounts[c.rank, default: 0] += 1
        }
        for (rank, count) in rankCounts {
            switch count {
            case 2:
                total += 2
                events.append(ScoreEvent(
                    player: "", points: 2,
                    reason: "Pair of \(rank.rawValue)s for 2"
                ))
            case 3:
                total += 6
                events.append(ScoreEvent(
                    player: "", points: 6,
                    reason: "Three \(rank.rawValue)s for 6"
                ))
            case 4:
                total += 12
                events.append(ScoreEvent(
                    player: "", points: 12,
                    reason: "Four \(rank.rawValue)s for 12"
                ))
            default:
                break
            }
        }

        // --- Runs ---
        let runs = calculateRuns(combined)
        for (runLength, multiplier) in runs {
            let pts = runLength * multiplier
            total += pts
            if multiplier > 1 {
                events.append(ScoreEvent(
                    player: "", points: pts,
                    reason: "\(multiplier)x run of \(runLength) for \(pts)"
                ))
            } else {
                events.append(ScoreEvent(
                    player: "", points: pts,
                    reason: "Run of \(runLength) for \(pts)"
                ))
            }
        }

        // --- Flush ---
        if hand.count >= 4 {
            let firstSuit = hand[0].suit
            if hand.allSatisfy({ $0.suit == firstSuit }) {
                if starter.suit == firstSuit {
                    total += 5
                    events.append(ScoreEvent(player: "", points: 5, reason: "Flush for 5"))
                } else if !isCrib {
                    total += 4
                    events.append(ScoreEvent(player: "", points: 4, reason: "Flush for 4"))
                }
            }
        }

        // --- Nobs: Jack in hand matching starter suit ---
        for c in hand {
            if c.rank == .jack && c.suit == starter.suit {
                total += 1
                events.append(ScoreEvent(player: "", points: 1, reason: "Nobs for 1"))
                break
            }
        }

        return (total, events)
    }

    // MARK: - Play-Phase Scoring

    /// Score the play pile after a card is added. Checks 15, 31, pairs, runs.
    static func calculatePlayScore(
        playPile: [Card],
        runningTotal: Int
    ) -> [ScoreEvent] {
        var events: [ScoreEvent] = []

        // 15 or 31
        if runningTotal == 15 {
            events.append(ScoreEvent(player: "", points: 2, reason: "Fifteen for 2"))
        } else if runningTotal == 31 {
            events.append(ScoreEvent(player: "", points: 2, reason: "Thirty-one for 2"))
        }

        // Pairs: check last 2, 3, 4 cards for matching ranks
        if playPile.count >= 2 {
            let lastRank = playPile.last!.rank
            var pairCount = 0
            for i in stride(from: playPile.count - 2, through: 0, by: -1) {
                if playPile[i].rank == lastRank {
                    pairCount += 1
                } else {
                    break
                }
            }
            switch pairCount {
            case 1:
                events.append(ScoreEvent(player: "", points: 2, reason: "Pair for 2"))
            case 2:
                events.append(ScoreEvent(player: "", points: 6, reason: "Three of a kind for 6"))
            case 3...:
                events.append(ScoreEvent(player: "", points: 12, reason: "Four of a kind for 12"))
            default:
                break
            }
        }

        // Runs: check if last N cards form a run (N = pile.count down to 3)
        if playPile.count >= 3 {
            var bestRun = 0
            for n in stride(from: playPile.count, through: 3, by: -1) {
                let lastN = Array(playPile.suffix(n))
                let orders = lastN.map { $0.rank.order }.sorted()
                let isRun = zip(orders, orders.dropFirst()).allSatisfy { $1 == $0 + 1 }
                if isRun {
                    bestRun = n
                    break
                }
            }
            if bestRun >= 3 {
                events.append(ScoreEvent(
                    player: "", points: bestRun,
                    reason: "Run of \(bestRun) for \(bestRun)"
                ))
            }
        }

        return events
    }
}
