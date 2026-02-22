import Testing
@testable import CribbageApp

@Suite("AI")
struct AITests {
    @Test func easyAIReturnsValidDiscardIndices() {
        let ai = EasyAI()
        let hand = Deck.shuffled().prefix(6).map { $0 }
        let indices = ai.chooseDiscards(hand: hand, isDealer: false)
        #expect(indices.count == 2)
        #expect(Set(indices).count == 2)
        for i in indices {
            #expect(i >= 0 && i < hand.count)
        }
    }

    @Test func mediumAIReturnsValidDiscardIndices() {
        let ai = MediumAI()
        let hand = Deck.shuffled().prefix(6).map { $0 }
        let indices = ai.chooseDiscards(hand: hand, isDealer: true)
        #expect(indices.count == 2)
        #expect(Set(indices).count == 2)
        for i in indices {
            #expect(i >= 0 && i < hand.count)
        }
    }

    @Test func hardAIReturnsValidDiscardIndices() {
        let ai = HardAI()
        let hand = Deck.shuffled().prefix(6).map { $0 }
        let indices = ai.chooseDiscards(hand: hand, isDealer: false)
        #expect(indices.count == 2)
        #expect(Set(indices).count == 2)
        for i in indices {
            #expect(i >= 0 && i < hand.count)
        }
    }

    @Test func aiNeverPlaysIllegalCard() {
        let ai = MediumAI()
        // Hand with high-value cards, running total near 31
        let hand = [
            Card(suit: .hearts, rank: .king),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .clubs, rank: .ace),
        ]
        let runningTotal = 25
        // Only ace (value 1) should be playable (25+1=26 ≤ 31)
        let idx = ai.choosePlay(hand: hand, playPile: [], runningTotal: runningTotal)
        if let idx {
            #expect(hand[idx].value + runningTotal <= 31)
        }
    }

    @Test func aiReturnsNilWhenNoPlayPossible() {
        let ai = EasyAI()
        let hand = [Card(suit: .hearts, rank: .king)] // value 10
        let idx = ai.choosePlay(hand: hand, playPile: [], runningTotal: 25)
        // 25 + 10 = 35 > 31, so should return nil
        #expect(idx == nil)
    }

    @Test func hardAIChoosesPlayValidly() {
        let ai = HardAI()
        let hand = [
            Card(suit: .hearts, rank: .five),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .clubs, rank: .three),
        ]
        let pile = [Card(suit: .spades, rank: .seven)]
        let runningTotal = 7
        let idx = ai.choosePlay(hand: hand, playPile: pile, runningTotal: runningTotal)
        if let idx {
            #expect(hand[idx].value + runningTotal <= 31)
        }
    }
}
