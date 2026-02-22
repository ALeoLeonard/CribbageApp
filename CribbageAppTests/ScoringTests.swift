import Testing
@testable import CribbageApp

// MARK: - Helpers

private func card(_ rank: Rank, _ suit: Suit = .hearts) -> Card {
    Card(suit: suit, rank: rank)
}

// MARK: - Fifteens

@Suite("Fifteens")
struct FifteensTests {
    @Test func simpleFifteen() {
        let hand = [card(.five), card(.ten), card(.two), card(.three)]
        let starter = card(.ace, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let fifteenPts = events.filter { $0.reason.lowercased().contains("fifteen") }.reduce(0) { $0 + $1.points }
        #expect(fifteenPts >= 4) // 5+10=15, 2+3+10=15
    }

    @Test func noFifteens() {
        let hand = [card(.ace), card(.ace, .diamonds), card(.two), card(.three)]
        let starter = card(.ace, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let fifteenPts = events.filter { $0.reason.lowercased().contains("fifteen") }.reduce(0) { $0 + $1.points }
        #expect(fifteenPts == 0)
    }
}

// MARK: - Pairs

@Suite("Pairs")
struct PairsTests {
    @Test func pair() {
        let hand = [card(.eight), card(.eight, .diamonds), card(.ace), card(.two)]
        let starter = card(.king, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let pairPts = events.filter {
            $0.reason.lowercased().contains("pair") || $0.reason.lowercased().contains("two")
        }.reduce(0) { $0 + $1.points }
        #expect(pairPts >= 2)
    }

    @Test func threeOfAKind() {
        let hand = [card(.seven), card(.seven, .diamonds), card(.seven, .clubs), card(.ace)]
        let starter = card(.king, .spades)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let threePts = events.filter { $0.reason.lowercased().contains("three") }.reduce(0) { $0 + $1.points }
        #expect(threePts >= 6)
    }

    @Test func fourOfAKind() {
        let hand = [card(.nine), card(.nine, .diamonds), card(.nine, .clubs), card(.nine, .spades)]
        let starter = card(.ace)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let fourPts = events.filter { $0.reason.lowercased().contains("four") }.reduce(0) { $0 + $1.points }
        #expect(fourPts >= 12)
    }
}

// MARK: - Runs

@Suite("Runs")
struct RunsTests {
    @Test func runOfThree() {
        let hand = [card(.three), card(.four), card(.five), card(.king)]
        let starter = card(.ace, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let runPts = events.filter { $0.reason.lowercased().contains("run") }.reduce(0) { $0 + $1.points }
        #expect(runPts >= 3)
    }

    @Test func runOfFive() {
        let hand = [card(.ace), card(.two), card(.three), card(.four)]
        let starter = card(.five, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let runPts = events.filter { $0.reason.lowercased().contains("run") }.reduce(0) { $0 + $1.points }
        #expect(runPts == 5)
    }

    @Test func doubleRun() {
        let hand = [card(.three), card(.three, .diamonds), card(.four), card(.five)]
        let starter = card(.king, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let runPts = events.filter { $0.reason.lowercased().contains("run") }.reduce(0) { $0 + $1.points }
        #expect(runPts == 6) // 2x run of 3
    }
}

// MARK: - Flush

@Suite("Flush")
struct FlushTests {
    @Test func fourCardFlush() {
        let hand = [card(.two, .hearts), card(.four, .hearts), card(.eight, .hearts), card(.king, .hearts)]
        let starter = card(.ace, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let flushPts = events.filter { $0.reason.lowercased().contains("flush") }.reduce(0) { $0 + $1.points }
        #expect(flushPts == 4)
    }

    @Test func fiveCardFlush() {
        let hand = [card(.two, .hearts), card(.four, .hearts), card(.eight, .hearts), card(.king, .hearts)]
        let starter = card(.ace, .hearts)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let flushPts = events.filter { $0.reason.lowercased().contains("flush") }.reduce(0) { $0 + $1.points }
        #expect(flushPts == 5)
    }

    @Test func noFlush() {
        let hand = [card(.two, .hearts), card(.four, .diamonds), card(.eight, .hearts), card(.king, .hearts)]
        let starter = card(.ace, .hearts)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let flushPts = events.filter { $0.reason.lowercased().contains("flush") }.reduce(0) { $0 + $1.points }
        #expect(flushPts == 0)
    }
}

// MARK: - Nobs

@Suite("Nobs")
struct NobsTests {
    @Test func nobs() {
        let hand = [card(.jack, .hearts), card(.two), card(.three), card(.four)]
        let starter = card(.king, .hearts)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let nobsPts = events.filter { $0.reason.lowercased().contains("nobs") }.reduce(0) { $0 + $1.points }
        #expect(nobsPts == 1)
    }

    @Test func noNobsDifferentSuit() {
        let hand = [card(.jack, .clubs), card(.two), card(.three), card(.four)]
        let starter = card(.king, .hearts)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter)
        let nobsPts = events.filter { $0.reason.lowercased().contains("nobs") }.reduce(0) { $0 + $1.points }
        #expect(nobsPts == 0)
    }
}

// MARK: - Perfect & Zero Hands

@Suite("Special Hands")
struct SpecialHandsTests {
    @Test func perfectHand29() {
        let hand = [
            card(.five, .hearts),
            card(.five, .diamonds),
            card(.five, .clubs),
            card(.jack, .spades),
        ]
        let starter = card(.five, .spades)
        let (score, _) = Scoring.calculateScore(hand: hand, starter: starter)
        #expect(score == 29)
    }

    @Test func zeroHand() {
        let hand = [card(.two), card(.four, .diamonds), card(.six, .clubs), card(.eight, .spades)]
        let starter = card(.ten)
        let (score, _) = Scoring.calculateScore(hand: hand, starter: starter)
        #expect(score == 0)
    }
}

// MARK: - Crib Flush

@Suite("Crib Flush")
struct CribFlushTests {
    @Test func fourCardFlushInvalidInCrib() {
        let hand = [card(.two, .hearts), card(.four, .hearts), card(.eight, .hearts), card(.king, .hearts)]
        let starter = card(.ace, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter, isCrib: true)
        let flushPts = events.filter { $0.reason.lowercased().contains("flush") }.reduce(0) { $0 + $1.points }
        #expect(flushPts == 0)
    }

    @Test func fiveCardFlushValidInCrib() {
        let hand = [card(.two, .hearts), card(.four, .hearts), card(.eight, .hearts), card(.king, .hearts)]
        let starter = card(.ace, .hearts)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter, isCrib: true)
        let flushPts = events.filter { $0.reason.lowercased().contains("flush") }.reduce(0) { $0 + $1.points }
        #expect(flushPts == 5)
    }

    @Test func fourCardFlushValidInHand() {
        let hand = [card(.two, .hearts), card(.four, .hearts), card(.eight, .hearts), card(.king, .hearts)]
        let starter = card(.ace, .clubs)
        let (_, events) = Scoring.calculateScore(hand: hand, starter: starter, isCrib: false)
        let flushPts = events.filter { $0.reason.lowercased().contains("flush") }.reduce(0) { $0 + $1.points }
        #expect(flushPts == 4)
    }
}

// MARK: - Play Scoring

@Suite("Play Scoring")
struct PlayScoringTests {
    @Test func fifteenDuringPlay() {
        let pile = [card(.seven), card(.eight)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 15)
        #expect(events.contains { $0.points == 2 && $0.reason.lowercased().contains("fifteen") })
    }

    @Test func thirtyOneDuringPlay() {
        let pile = [card(.ten), card(.ten, .diamonds), card(.jack)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 31)
        #expect(events.contains { $0.points == 2 && $0.reason.lowercased().contains("thirty-one") })
    }

    @Test func pairDuringPlay() {
        let pile = [card(.six), card(.six, .diamonds)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 12)
        #expect(events.contains { $0.points == 2 && $0.reason.lowercased().contains("pair") })
    }

    @Test func threeOfAKindDuringPlay() {
        let pile = [card(.four), card(.four, .diamonds), card(.four, .clubs)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 12)
        #expect(events.contains { $0.points == 6 && $0.reason.lowercased().contains("three") })
    }

    @Test func runDuringPlay() {
        let pile = [card(.three), card(.four), card(.five)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 12)
        #expect(events.contains { $0.points == 3 && $0.reason.lowercased().contains("run") })
    }

    @Test func runNotConsecutiveOrder() {
        let pile = [card(.five), card(.three), card(.four)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 12)
        #expect(events.contains { $0.points == 3 && $0.reason.lowercased().contains("run") })
    }

    @Test func noScoring() {
        let pile = [card(.ace), card(.three)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 4)
        #expect(events.isEmpty)
    }

    @Test func fourOfAKindDuringPlay() {
        let pile = [card(.seven), card(.seven, .diamonds), card(.seven, .clubs), card(.seven, .spades)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 28)
        #expect(events.contains { $0.points == 12 })
    }

    @Test func runOfFourDuringPlay() {
        let pile = [card(.three), card(.five), card(.four), card(.six)]
        let events = Scoring.calculatePlayScore(playPile: pile, runningTotal: 18)
        #expect(events.contains { $0.points == 4 && $0.reason.lowercased().contains("run") })
    }
}
