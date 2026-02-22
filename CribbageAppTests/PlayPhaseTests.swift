import Testing
@testable import CribbageApp

@Suite("Play Phase")
struct PlayPhaseTests {
    @Test func canPlayWithLowCard() {
        let hand = [Card(suit: .hearts, rank: .ace)]
        #expect(PlayPhaseHelper.canPlay(hand: hand, runningTotal: 30))
    }

    @Test func cannotPlayOverThirtyOne() {
        let hand = [Card(suit: .hearts, rank: .two)]
        #expect(!PlayPhaseHelper.canPlay(hand: hand, runningTotal: 30))
    }

    @Test func canPlayWithExactThirtyOne() {
        let hand = [Card(suit: .hearts, rank: .ace)]
        // 30 + 1 = 31 — exactly 31 is allowed
        #expect(PlayPhaseHelper.canPlay(hand: hand, runningTotal: 30))
    }

    @Test func cannotPlayEmptyHand() {
        let hand: [Card] = []
        #expect(!PlayPhaseHelper.canPlay(hand: hand, runningTotal: 0))
    }

    @Test func canPlayMultipleCards() {
        let hand = [
            Card(suit: .hearts, rank: .king),  // value 10
            Card(suit: .diamonds, rank: .ace),  // value 1
        ]
        // At 25: king can't play (35>31), but ace can (26≤31)
        #expect(PlayPhaseHelper.canPlay(hand: hand, runningTotal: 25))
    }

    @Test func cannotPlayAnyCardAtHighTotal() {
        let hand = [
            Card(suit: .hearts, rank: .king),   // 10
            Card(suit: .diamonds, rank: .queen), // 10
        ]
        // At 22: neither can play (32>31)
        #expect(!PlayPhaseHelper.canPlay(hand: hand, runningTotal: 22))
    }
}
