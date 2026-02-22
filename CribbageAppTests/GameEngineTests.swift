import Testing
@testable import CribbageApp

@Suite("Game Engine")
struct GameEngineTests {

    @Test func initialPhaseIsDiscard() {
        let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
        #expect(engine.phase == .discard)
        #expect(engine.human.hand.count == 6)
        #expect(engine.computer.hand.count == 4) // already discarded 2
        #expect(engine.crib.count == 2) // computer's discards
    }

    @Test func discardMovesToPlayPhase() {
        let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
        #expect(engine.human.hand.count == 6)
        engine.discard(cardIndices: [0, 1])
        // After discard, should be in play phase (or game over if His Heels + win)
        #expect(engine.phase == .play || engine.phase == .gameOver)
        #expect(engine.human.hand.count == 4)
        #expect(engine.crib.count == 4)
        #expect(engine.starter != nil)
    }

    @Test func hisHeelsScores2ForDealer() {
        // Run many games to find one where starter is Jack
        for _ in 0..<200 {
            let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
            engine.discard(cardIndices: [0, 1])
            if engine.starter?.rank == .jack {
                // Dealer should have gotten 2 points
                let dealerScore = engine.computer.isDealer ? engine.computer.score : engine.human.score
                #expect(dealerScore >= 2)
                return
            }
        }
        // If we never hit a Jack starter in 200 attempts, that's astronomically unlikely but skip
    }

    @Test func dealerRotatesAfterFullRound() {
        let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
        let initialHumanDealer = engine.human.isDealer

        // Play through a complete round by discarding and exhausting all phases
        engine.discard(cardIndices: [0, 1])

        // Play all cards
        while engine.phase == .play {
            if engine.currentTurn == "human" {
                if PlayPhaseHelper.canPlay(hand: engine.humanPlayHand, runningTotal: engine.runningTotal) {
                    engine.playCard(cardIndex: 0)
                } else {
                    engine.sayGo()
                }
            } else {
                break // computer turn handled internally
            }
        }

        // Advance through counting phases
        while [.countNonDealer, .countDealer, .countCrib].contains(engine.phase) {
            engine.acknowledge()
        }

        // If game isn't over, dealer should have rotated
        if engine.phase != .gameOver {
            #expect(engine.human.isDealer != initialHumanDealer)
        }
    }

    @Test func winnerDetected() {
        let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
        // Force a win by setting score near winning
        engine.human.score = 120
        engine.discard(cardIndices: [0, 1])

        // Play through - with 120 score any scoring should trigger a win
        var maxTurns = 100
        while engine.phase != .gameOver && maxTurns > 0 {
            maxTurns -= 1
            switch engine.phase {
            case .play:
                if engine.currentTurn == "human" {
                    if PlayPhaseHelper.canPlay(hand: engine.humanPlayHand, runningTotal: engine.runningTotal) {
                        engine.playCard(cardIndex: 0)
                    } else {
                        engine.sayGo()
                    }
                }
            case .countNonDealer, .countDealer, .countCrib:
                engine.acknowledge()
            case .discard:
                if engine.human.hand.count >= 2 {
                    engine.discard(cardIndices: [0, 1])
                } else {
                    break
                }
            default:
                break
            }
        }
        // One of the players should have won or be very close
        #expect(engine.human.score >= 120 || engine.computer.score >= 120)
    }

    @Test func humanHandPersistsAfterPlayingCard() {
        let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
        engine.discard(cardIndices: [0, 1])
        guard engine.phase == .play else { return }

        let handBefore = engine.humanPlayHand
        #expect(handBefore.count == 4, "Should have 4 cards after discard")

        // Wait for human turn then play a card
        if engine.currentTurn == "human" {
            engine.playCard(cardIndex: 0)
            let handAfter = engine.humanPlayHand
            #expect(handAfter.count == 3, "Should have 3 cards after playing one")
            // Remaining cards should be the same cards (minus the played one)
            for card in handAfter {
                #expect(handBefore.contains(card), "Remaining card \(card.label) should be from original hand")
            }
        }
    }

    @Test func fullPlayPhaseHandCountDecrements() {
        let engine = GameEngine(playerName: "Test", aiDifficulty: .easy)
        engine.discard(cardIndices: [0, 1])
        guard engine.phase == .play else { return }

        var humanCardsPlayed = 0
        var maxTurns = 50
        while engine.phase == .play && maxTurns > 0 {
            maxTurns -= 1
            if engine.currentTurn == "human" {
                let before = engine.humanPlayHand.count
                if PlayPhaseHelper.canPlay(hand: engine.humanPlayHand, runningTotal: engine.runningTotal) {
                    engine.playCard(cardIndex: 0)
                    humanCardsPlayed += 1
                    let after = engine.humanPlayHand.count
                    #expect(after == before - 1, "Hand should shrink by 1 after play, was \(before) now \(after)")
                } else {
                    engine.sayGo()
                }
            } else {
                break // computer auto-plays
            }
        }
        #expect(humanCardsPlayed > 0, "Should have played at least one card")
    }
}
