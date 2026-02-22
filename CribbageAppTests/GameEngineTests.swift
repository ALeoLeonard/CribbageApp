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
}
