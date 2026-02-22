import Foundation

/// Core game engine — manages a single cribbage game as a state machine.
/// Ported from backend/game/game_engine.py.
@Observable
final class GameEngine {
    // MARK: - State

    var phase: GamePhase = .discard
    var roundNumber: Int = 1

    var human: PlayerState
    var computer: PlayerState

    private let ai: CribbageAI
    let aiDifficulty: AIDifficulty

    var deck: [Card] = []
    var starter: Card?
    var crib: [Card] = []

    // Play phase state
    var playPile: [Card] = []
    var runningTotal: Int = 0
    var humanPlayHand: [Card] = []
    var computerPlayHand: [Card] = []
    var currentTurn: String = "" // "human" or "computer"
    var lastGoBy: String?

    var lastAction: LastAction?
    var actionLog: [LastAction] = []
    var scoreBreakdown: ScoreBreakdown?
    var winner: String?

    // Stats tracking
    var handScores: [Int] = []
    var cribScores: [Int] = []
    var highestHandScore: Int = 0

    // MARK: - Computed

    var dealer: PlayerState {
        human.isDealer ? human : computer
    }

    var nonDealer: PlayerState {
        human.isDealer ? computer : human
    }

    var isHumanDealer: Bool { human.isDealer }

    /// Whether it's the human's turn to act.
    var yourTurn: Bool {
        switch phase {
        case .play:
            return currentTurn == "human"
        case .discard:
            return true
        case .countNonDealer, .countDealer, .countCrib:
            return true // human taps to acknowledge
        case .gameOver:
            return false
        }
    }

    /// Whether the human can play any card.
    var humanCanPlay: Bool {
        PlayPhaseHelper.canPlay(hand: humanPlayHand, runningTotal: runningTotal)
    }

    /// Number of cards the opponent holds (visible to UI).
    var opponentHandCount: Int {
        phase == .play ? computerPlayHand.count : computer.hand.count
    }

    // MARK: - Init

    init(playerName: String, aiDifficulty: AIDifficulty) {
        self.human = PlayerState(name: playerName)
        self.computer = PlayerState(name: "Computer", isDealer: true)
        self.ai = createAI(aiDifficulty)
        self.aiDifficulty = aiDifficulty
        dealRound()
    }

    // MARK: - Logging

    private func logAction(_ action: LastAction) {
        lastAction = action
        actionLog.append(action)
    }

    // MARK: - Deal

    private func dealRound() {
        deck = Deck.shuffled()
        human.hand = Deck.deal(6, from: &deck)
        computer.hand = Deck.deal(6, from: &deck)
        crib = []
        starter = nil
        playPile = []
        runningTotal = 0
        lastGoBy = nil
        scoreBreakdown = nil
        phase = .discard

        // Computer discards immediately
        let aiDiscardIndices = ai.chooseDiscards(hand: computer.hand, isDealer: computer.isDealer)
        let discarded = aiDiscardIndices.sorted(by: >).map { computer.hand.remove(at: $0) }
        crib.append(contentsOf: discarded)
    }

    // MARK: - Score / Winner

    private func addScore(_ player: inout PlayerState, _ points: Int) {
        player.score += points
    }

    private func checkWinner() -> Bool {
        if human.score >= Constants.winningScore {
            winner = human.name
            phase = .gameOver
            return true
        }
        if computer.score >= Constants.winningScore {
            winner = computer.name
            phase = .gameOver
            return true
        }
        return false
    }

    // MARK: - Discard

    /// Human discards 2 cards to crib.
    func discard(cardIndices: [Int]) {
        actionLog = []
        guard phase == .discard else { return }
        guard cardIndices.count == 2,
              Set(cardIndices).count == 2,
              cardIndices.allSatisfy({ $0 >= 0 && $0 < human.hand.count })
        else { return }

        // Remove cards (highest index first to avoid shifting)
        let discarded = cardIndices.sorted(by: >).map { human.hand.remove(at: $0) }
        crib.append(contentsOf: discarded)

        // Cut the starter
        starter = Deck.deal(1, from: &deck).first

        // Check for His Heels (Jack starter = 2 pts to dealer)
        if let starter, starter.rank == .jack {
            if human.isDealer {
                addScore(&human, 2)
            } else {
                addScore(&computer, 2)
            }
            logAction(LastAction(
                actor: dealer.name,
                action: "score",
                scoreEvents: [ScoreEvent(player: dealer.name, points: 2, reason: "His Heels (Jack starter)")],
                message: "\(dealer.name) scores 2 for His Heels!"
            ))
            if checkWinner() { return }
        }

        // Set up play phase
        humanPlayHand = human.hand
        computerPlayHand = computer.hand
        playPile = []
        runningTotal = 0
        currentTurn = human.isDealer ? "computer" : "human"
        phase = .play

        // If computer goes first, auto-play
        if currentTurn == "computer" {
            computerPlayTurn()
        }
    }

    // MARK: - Play Card

    /// Human plays a card during pegging.
    func playCard(cardIndex: Int) {
        actionLog = []
        guard phase == .play,
              currentTurn == "human",
              cardIndex >= 0, cardIndex < humanPlayHand.count
        else { return }

        let card = humanPlayHand[cardIndex]
        guard card.value + runningTotal <= 31 else { return }

        humanPlayHand.remove(at: cardIndex)
        playPile.append(card)
        runningTotal += card.value

        // Score
        var events = Scoring.calculatePlayScore(playPile: playPile, runningTotal: runningTotal)
        let totalPts = events.reduce(0) { $0 + $1.points }
        if totalPts > 0 {
            addScore(&human, totalPts)
            for i in events.indices { events[i].player = human.name }
        }

        logAction(LastAction(
            actor: human.name,
            action: "play",
            card: card,
            scoreEvents: events,
            message: "\(human.name) plays \(card.label)"
        ))

        if runningTotal == 31 {
            playPile = []
            runningTotal = 0
            lastGoBy = nil
        }

        if checkWinner() { return }

        // Check if play phase is over
        if humanPlayHand.isEmpty && computerPlayHand.isEmpty {
            endPlayPhase()
            return
        }

        // Switch turn
        currentTurn = "computer"
        lastGoBy = nil

        // Computer takes its turn(s)
        computerPlayTurn()
    }

    // MARK: - Say Go

    /// Human says Go (can't play any card <= 31).
    func sayGo() {
        actionLog = []
        guard phase == .play, currentTurn == "human" else { return }
        guard !PlayPhaseHelper.canPlay(hand: humanPlayHand, runningTotal: runningTotal) else { return }

        logAction(LastAction(
            actor: human.name,
            action: "go",
            message: "\(human.name) says Go!"
        ))

        handleGo(whoSaidGo: "human")
    }

    // MARK: - Go Logic

    private func handleGo(whoSaidGo: String) {
        if let lastGo = lastGoBy, lastGo != whoSaidGo {
            // Both said go — last card point, reset
            if whoSaidGo == "computer" {
                addScore(&human, 1)
                logAction(LastAction(
                    actor: human.name,
                    action: "score",
                    scoreEvents: [ScoreEvent(player: human.name, points: 1, reason: "Go (last card)")],
                    message: "\(human.name) scores 1 for Go"
                ))
            } else {
                addScore(&computer, 1)
                logAction(LastAction(
                    actor: computer.name,
                    action: "score",
                    scoreEvents: [ScoreEvent(player: computer.name, points: 1, reason: "Go (last card)")],
                    message: "\(computer.name) scores 1 for Go"
                ))
            }
            playPile = []
            runningTotal = 0
            lastGoBy = nil
            if checkWinner() { return }

            // Check if play phase is over
            if humanPlayHand.isEmpty && computerPlayHand.isEmpty {
                endPlayPhase()
                return
            }

            // The person who said the first Go gets to lead
            if whoSaidGo == "human" {
                currentTurn = "human"
            } else {
                currentTurn = "computer"
                computerPlayTurn()
            }
        } else {
            lastGoBy = whoSaidGo
            // Other player continues
            if whoSaidGo == "human" {
                currentTurn = "computer"
                computerPlayTurn()
            } else {
                currentTurn = "human"
            }
        }
    }

    // MARK: - Computer Play

    private func computerPlayTurn() {
        while currentTurn == "computer" && phase == .play {
            if computerPlayHand.isEmpty {
                if humanPlayHand.isEmpty {
                    endPlayPhase()
                    return
                }
                currentTurn = "human"
                return
            }

            guard let idx = ai.choosePlay(
                hand: computerPlayHand,
                playPile: playPile,
                runningTotal: runningTotal
            ) else {
                // Computer says Go
                logAction(LastAction(
                    actor: computer.name,
                    action: "go",
                    message: "Computer says Go!"
                ))
                handleGo(whoSaidGo: "computer")
                return
            }

            let card = computerPlayHand.remove(at: idx)
            playPile.append(card)
            runningTotal += card.value

            var events = Scoring.calculatePlayScore(playPile: playPile, runningTotal: runningTotal)
            let totalPts = events.reduce(0) { $0 + $1.points }
            if totalPts > 0 {
                addScore(&computer, totalPts)
                for i in events.indices { events[i].player = computer.name }
            }

            logAction(LastAction(
                actor: computer.name,
                action: "play",
                card: card,
                scoreEvents: events,
                message: "Computer plays \(card.label)"
            ))

            if runningTotal == 31 {
                playPile = []
                runningTotal = 0
                lastGoBy = nil
            }

            if checkWinner() { return }

            // Check if play phase done
            if humanPlayHand.isEmpty && computerPlayHand.isEmpty {
                endPlayPhase()
                return
            }

            // If human has cards and can play, give them the turn
            if !humanPlayHand.isEmpty && PlayPhaseHelper.canPlay(hand: humanPlayHand, runningTotal: runningTotal) {
                currentTurn = "human"
                return
            }

            // If human has cards but can't play, handle their Go automatically
            if !humanPlayHand.isEmpty && !PlayPhaseHelper.canPlay(hand: humanPlayHand, runningTotal: runningTotal) {
                logAction(LastAction(
                    actor: human.name,
                    action: "go",
                    message: "\(human.name) says Go!"
                ))
                handleGo(whoSaidGo: "human")
                continue
            }

            // Human has no cards, computer continues
        }
    }

    // MARK: - End Play Phase

    private func endPlayPhase() {
        // Last card point (if total != 31, because 31 already scored)
        if runningTotal > 0 && runningTotal != 31 {
            if !playPile.isEmpty {
                let lastPlayerName = lastAction?.actor ?? nonDealer.name
                if lastPlayerName == human.name {
                    addScore(&human, 1)
                } else {
                    addScore(&computer, 1)
                }
                if checkWinner() { return }
            }
        }

        playPile = []
        runningTotal = 0
        phase = .countNonDealer
    }

    // MARK: - Acknowledge (Counting Phases)

    /// Advance through counting phases.
    func acknowledge() {
        actionLog = []

        switch phase {
        case .countNonDealer:
            guard let starter else { return }
            let hand = isHumanDealer ? computer.hand : human.hand
            let (score, events) = Scoring.calculateScore(hand: hand, starter: starter)
            var taggedEvents = events
            let playerName = nonDealer.name
            for i in taggedEvents.indices { taggedEvents[i].player = playerName }

            if isHumanDealer {
                addScore(&computer, score)
            } else {
                addScore(&human, score)
                handScores.append(score)
                highestHandScore = max(highestHandScore, score)
            }

            scoreBreakdown = ScoreBreakdown(hand: hand, starter: starter, items: taggedEvents, total: score)
            logAction(LastAction(
                actor: playerName, action: "score",
                scoreEvents: taggedEvents,
                message: "\(playerName) scores \(score) in hand"
            ))
            if checkWinner() { return }
            phase = .countDealer

        case .countDealer:
            guard let starter else { return }
            let hand = isHumanDealer ? human.hand : computer.hand
            let (score, events) = Scoring.calculateScore(hand: hand, starter: starter)
            var taggedEvents = events
            let playerName = dealer.name
            for i in taggedEvents.indices { taggedEvents[i].player = playerName }

            if isHumanDealer {
                addScore(&human, score)
                handScores.append(score)
                highestHandScore = max(highestHandScore, score)
            } else {
                addScore(&computer, score)
            }

            scoreBreakdown = ScoreBreakdown(hand: hand, starter: starter, items: taggedEvents, total: score)
            logAction(LastAction(
                actor: playerName, action: "score",
                scoreEvents: taggedEvents,
                message: "\(playerName) scores \(score) in hand"
            ))
            if checkWinner() { return }
            phase = .countCrib

        case .countCrib:
            guard let starter else { return }
            let (score, events) = Scoring.calculateScore(hand: crib, starter: starter, isCrib: true)
            var taggedEvents = events
            let playerName = dealer.name
            for i in taggedEvents.indices { taggedEvents[i].player = playerName }

            if isHumanDealer {
                addScore(&human, score)
                cribScores.append(score)
            } else {
                addScore(&computer, score)
            }

            scoreBreakdown = ScoreBreakdown(hand: crib, starter: starter, items: taggedEvents, total: score)
            logAction(LastAction(
                actor: playerName, action: "score",
                scoreEvents: taggedEvents,
                message: "\(playerName) scores \(score) in crib"
            ))
            if checkWinner() { return }

            // Swap dealer, start new round
            human.isDealer.toggle()
            computer.isDealer.toggle()
            roundNumber += 1
            dealRound()

        default:
            break
        }
    }

    // MARK: - New Game

    /// Reset for a brand new game.
    func newGame() {
        human.score = 0
        computer.score = 0
        human.isDealer = false
        computer.isDealer = true
        roundNumber = 1
        winner = nil
        handScores = []
        cribScores = []
        highestHandScore = 0
        actionLog = []
        lastAction = nil
        scoreBreakdown = nil
        dealRound()
    }
}
