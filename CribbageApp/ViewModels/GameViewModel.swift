import Foundation
import SwiftUI

// MARK: - Ceremony Phases

enum DealPhase: Equatable {
    case idle
    case shuffling
    case dealing(Int) // card index being dealt
    case ready
}

enum StarterCeremonyPhase: Equatable {
    case idle
    case cutting
    case revealing
    case done
}

// MARK: - Pacing Config

struct PacingConfig {
    let thinkMin: Int       // ms before first action
    let thinkMax: Int
    let betweenMin: Int     // ms between sequential actions
    let betweenMax: Int
    let dealCardDelay: Int  // ms between dealing each card

    static func config(for difficulty: AIDifficulty) -> PacingConfig {
        switch difficulty {
        case .easy:
            return PacingConfig(thinkMin: 800, thinkMax: 1400, betweenMin: 500, betweenMax: 800, dealCardDelay: 180)
        case .medium:
            return PacingConfig(thinkMin: 1000, thinkMax: 1800, betweenMin: 600, betweenMax: 1000, dealCardDelay: 150)
        case .hard:
            return PacingConfig(thinkMin: 1500, thinkMax: 2500, betweenMin: 800, betweenMax: 1400, dealCardDelay: 120)
        }
    }
}

// MARK: - ViewModel

/// Wraps GameEngine and adds ceremonies, pacing, and animation delays.
@MainActor @Observable
final class GameViewModel {
    var engine: GameEngine?
    var selectedIndices: Set<Int> = []
    var isProcessing = false
    var statusMessage: String?

    // Ceremony state
    var dealPhase: DealPhase = .idle
    var starterCeremonyPhase: StarterCeremonyPhase = .idle
    var dealtCardCount: Int = 0  // How many cards visibly dealt so far

    // Persisted settings
    @ObservationIgnored
    @AppStorage("playerName") var playerName = "Player"
    @ObservationIgnored
    @AppStorage("difficulty") var difficultyRaw = AIDifficulty.easy.rawValue
    @ObservationIgnored
    @AppStorage("cardSort") var cardSortRaw = CardSortPreference.dealt.rawValue

    private let stats = StatsManager.shared
    private let sound = SoundManager.shared

    // Multiplayer
    var multiplayerVM: MultiplayerViewModel?
    var isMultiplayer: Bool { multiplayerVM != nil }
    var chatMessages: [ChatMessage] { multiplayerVM?.chatMessages ?? [] }

    var difficulty: AIDifficulty {
        get { AIDifficulty(rawValue: difficultyRaw) ?? .easy }
        set { difficultyRaw = newValue.rawValue }
    }

    var cardSort: CardSortPreference {
        get { CardSortPreference(rawValue: cardSortRaw) ?? .dealt }
        set { cardSortRaw = newValue.rawValue }
    }

    private var pacing: PacingConfig {
        PacingConfig.config(for: difficulty)
    }

    // MARK: - Game State Accessors

    var phase: GamePhase {
        if let mp = multiplayerVM { return mp.phase }
        return engine?.phase ?? .discard
    }
    var humanHand: [Card] {
        if let mp = multiplayerVM { return mp.humanHand }
        guard let engine else { return [] }
        let hand = engine.phase == .play ? engine.humanPlayHand : engine.human.hand
        return sortedHand(hand)
    }

    var skunkResult: SkunkResult {
        return engine?.skunkResult ?? .none
    }
    var humanScore: Int {
        if let mp = multiplayerVM { return mp.humanScore }
        return engine?.human.score ?? 0
    }
    var humanName: String {
        if let mp = multiplayerVM { return mp.humanName }
        return engine?.human.name ?? playerName
    }
    var humanIsDealer: Bool {
        if let mp = multiplayerVM { return mp.humanIsDealer }
        return engine?.human.isDealer ?? false
    }

    var opponentScore: Int {
        if let mp = multiplayerVM { return mp.opponentScore }
        return engine?.computer.score ?? 0
    }
    var opponentName: String {
        if let mp = multiplayerVM { return mp.opponentName }
        return engine?.computer.name ?? "Computer"
    }
    var opponentHandCount: Int {
        if let mp = multiplayerVM { return mp.opponentHandCount }
        return engine?.opponentHandCount ?? 0
    }
    var opponentIsDealer: Bool {
        if let mp = multiplayerVM { return mp.opponentIsDealer }
        return engine?.computer.isDealer ?? false
    }

    var starter: Card? {
        if let mp = multiplayerVM { return mp.starter }
        return engine?.starter
    }
    var playPile: [Card] {
        if let mp = multiplayerVM { return mp.playPile }
        return engine?.playPile ?? []
    }
    var runningTotal: Int {
        if let mp = multiplayerVM { return mp.runningTotal }
        return engine?.runningTotal ?? 0
    }
    var cribCount: Int {
        if let mp = multiplayerVM { return mp.cribCount }
        return engine?.crib.count ?? 0
    }
    var roundNumber: Int {
        if let mp = multiplayerVM { return mp.roundNumber }
        return engine?.roundNumber ?? 1
    }
    var winner: String? {
        if let mp = multiplayerVM { return mp.winner }
        return engine?.winner
    }
    var scoreBreakdown: ScoreBreakdown? {
        if let mp = multiplayerVM { return mp.scoreBreakdown }
        return engine?.scoreBreakdown
    }
    var lastAction: LastAction? {
        if let mp = multiplayerVM { return mp.lastAction }
        return engine?.lastAction
    }
    var actionLog: [LastAction] {
        // Multiplayer doesn't have a local action log
        return engine?.actionLog ?? []
    }

    var yourTurn: Bool {
        if let mp = multiplayerVM { return mp.yourTurn }
        return engine?.yourTurn ?? false
    }
    var humanCanPlay: Bool {
        if let mp = multiplayerVM { return mp.humanCanPlay }
        return engine?.humanCanPlay ?? false
    }

    var countPhasePlayerName: String {
        if let mp = multiplayerVM { return mp.countPhasePlayerName }
        guard let engine else { return "" }
        switch engine.phase {
        case .countNonDealer:
            return engine.nonDealer.name
        case .countDealer, .countCrib:
            return engine.dealer.name
        default:
            return ""
        }
    }

    /// Whether we're in a deal ceremony (shuffling or dealing cards)
    var isDealCeremony: Bool {
        dealPhase != .idle && dealPhase != .ready
    }

    // MARK: - Actions

    func newGame() {
        let name = playerName.trimmingCharacters(in: .whitespaces)
        engine = GameEngine(
            playerName: name.isEmpty ? "Player" : name,
            aiDifficulty: difficulty,
            autoDeal: false
        )
        selectedIndices = []
        isProcessing = true
        statusMessage = nil
        starterCeremonyPhase = .idle
        startDealCeremony()
    }

    func toggleSelect(_ index: Int) {
        guard phase == .discard, dealPhase == .ready else { return }
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else if selectedIndices.count < 2 {
            selectedIndices.insert(index)
        }
        HapticManager.selection()
        sound.playCardFlip()
    }

    func discard() {
        if let mp = multiplayerVM {
            guard selectedIndices.count == 2 else { return }
            mp.discard(selectedIndices)
            selectedIndices = []
            HapticManager.mediumImpact()
            sound.playCardPlace()
            return
        }
        guard let engine, selectedIndices.count == 2, !isProcessing else { return }
        isProcessing = true
        HapticManager.mediumImpact()
        sound.playCardPlace()
        let indices = Array(selectedIndices).sorted()
        selectedIndices = []

        engine.discard(cardIndices: indices)
        let log = engine.actionLog

        checkGameOver()

        if engine.phase == .gameOver {
            isProcessing = false
            return
        }

        // Start starter cut ceremony
        startStarterCeremony {
            // After ceremony, check for computer plays
            let computerPlays = log.filter { $0.actor == engine.computer.name && $0.action == "play" }
            if computerPlays.isEmpty {
                self.isProcessing = false
                return
            }
            self.animateActionLog(log)
        }
    }

    func playCard(_ index: Int) {
        if let mp = multiplayerVM {
            mp.playCard(index)
            HapticManager.mediumImpact()
            sound.playCardSlide()
            return
        }
        guard let engine, !isProcessing else { return }
        isProcessing = true
        HapticManager.mediumImpact()

        // Anticipation: play slide sound slightly before card appears
        sound.playCardSlide()

        Task {
            try? await Task.sleep(for: .milliseconds(150))
            sound.playCardPlace()
            HapticManager.lightImpact()

            engine.playCard(cardIndex: index)
            let log = engine.actionLog

            // Check for scoring in the play
            if log.contains(where: { !$0.scoreEvents.isEmpty }) {
                sound.playScore()
            }

            checkGameOver()

            let computerPlays = log.filter { $0.actor == engine.computer.name && $0.action == "play" }
            if computerPlays.isEmpty {
                isProcessing = false
                return
            }

            animateActionLog(Array(log.dropFirst()))
        }
    }

    func sayGo() {
        if let mp = multiplayerVM {
            mp.sayGo()
            sound.playGo()
            return
        }
        guard let engine, !isProcessing else { return }
        isProcessing = true
        sound.playGo()

        engine.sayGo()
        let log = engine.actionLog

        checkGameOver()

        if log.count <= 1 {
            isProcessing = false
            return
        }

        animateActionLog(Array(log.dropFirst()))
    }

    func acknowledge() {
        if let mp = multiplayerVM {
            mp.acknowledge()
            HapticManager.lightImpact()
            return
        }
        guard let engine, !isProcessing else { return }
        HapticManager.lightImpact()

        // Record hand/crib scores before advancing
        if let breakdown = engine.scoreBreakdown {
            if engine.phase == .countCrib {
                stats.recordCribScore(breakdown.total)
            } else {
                stats.recordHandScore(breakdown.total)
            }
            if breakdown.total > 0 {
                sound.playScore()
            }
        }

        let wasCountCrib = engine.phase == .countCrib
        engine.acknowledge()
        checkGameOver()

        // If we just finished counting crib, a new round was dealt —
        // trigger deal ceremony for the new round
        if wasCountCrib && engine.phase == .discard {
            isProcessing = true
            starterCeremonyPhase = .idle
            startDealCeremony()
        }
    }

    func restartGame() {
        engine?.newGame()
        selectedIndices = []
        isProcessing = true
        statusMessage = nil
        starterCeremonyPhase = .idle

        // Engine.newGame() calls dealRound() internally, so cards are already dealt.
        // We still run the visual ceremony.
        startDealCeremonyVisualOnly()
    }

    func sendChat(_ text: String) {
        multiplayerVM?.sendChat(text)
    }

    // MARK: - Game Over

    private func checkGameOver() {
        guard let engine, engine.phase == .gameOver, let winner = engine.winner else { return }
        let won = winner == engine.human.name
        stats.recordGameResult(won: won, difficulty: engine.aiDifficulty)
        let loserScore = won ? engine.computer.score : engine.human.score
        stats.recordSkunkResult(won: won, loserScore: loserScore)
        if engine.humanPeggingPoints > 0 {
            stats.recordPeggingPoints(engine.humanPeggingPoints)
        }
        if won {
            sound.playWin()
        } else {
            sound.playLose()
        }
    }

    // MARK: - Card Sorting

    private func sortedHand(_ hand: [Card]) -> [Card] {
        switch cardSort {
        case .dealt:
            return hand
        case .byRank:
            return hand.sorted { $0.rank.order < $1.rank.order }
        case .bySuit:
            return hand.sorted {
                if $0.suit.rawValue == $1.suit.rawValue {
                    return $0.rank.order < $1.rank.order
                }
                return $0.suit.rawValue < $1.suit.rawValue
            }
        }
    }

    // MARK: - Deal Ceremony

    /// Full ceremony: deal cards in engine, then animate
    private func startDealCeremony() {
        guard let engine else { return }
        dealPhase = .shuffling
        dealtCardCount = 0

        Task {
            // Shuffle phase
            sound.playShuffleRiffle()
            try? await Task.sleep(for: .milliseconds(1200))

            // Actually deal in the engine
            engine.dealRound()

            // Now animate dealing cards one at a time
            let totalCards = engine.human.hand.count
            for i in 0..<totalCards {
                dealPhase = .dealing(i)
                dealtCardCount = i + 1
                sound.playCardSlide()
                HapticManager.lightImpact()
                try? await Task.sleep(for: .milliseconds(pacing.dealCardDelay))
            }

            dealPhase = .ready
            isProcessing = false
        }
    }

    /// Visual-only ceremony (engine already dealt cards)
    private func startDealCeremonyVisualOnly() {
        dealPhase = .shuffling
        dealtCardCount = 0

        Task {
            sound.playShuffleRiffle()
            try? await Task.sleep(for: .milliseconds(1200))

            let totalCards = engine?.human.hand.count ?? 6
            for i in 0..<totalCards {
                dealPhase = .dealing(i)
                dealtCardCount = i + 1
                sound.playCardSlide()
                HapticManager.lightImpact()
                try? await Task.sleep(for: .milliseconds(pacing.dealCardDelay))
            }

            dealPhase = .ready
            isProcessing = false
        }
    }

    // MARK: - Starter Cut Ceremony

    private func startStarterCeremony(completion: @escaping () -> Void) {
        starterCeremonyPhase = .cutting

        Task {
            // Pause, then tap
            try? await Task.sleep(for: .milliseconds(300))
            sound.playDeckTap()
            HapticManager.mediumImpact()

            // Cut animation
            try? await Task.sleep(for: .milliseconds(500))
            starterCeremonyPhase = .revealing

            // Flip sound
            sound.playCardFlip()
            HapticManager.lightImpact()

            try? await Task.sleep(for: .milliseconds(600))
            starterCeremonyPhase = .done

            try? await Task.sleep(for: .milliseconds(200))
            completion()
        }
    }

    // MARK: - Animation

    private func animateActionLog(_ actions: [LastAction]) {
        guard !actions.isEmpty else {
            isProcessing = false
            return
        }

        Task {
            for (i, action) in actions.enumerated() {
                let delay: Int
                if i == 0 {
                    delay = Int.random(in: pacing.thinkMin...pacing.thinkMax)
                } else {
                    delay = Int.random(in: pacing.betweenMin...pacing.betweenMax)
                }
                try? await Task.sleep(for: .milliseconds(delay))

                // Anticipation sound before card appears
                if action.action == "play" {
                    sound.playCardSlide()
                    try? await Task.sleep(for: .milliseconds(150))
                }

                statusMessage = action.message
                HapticManager.lightImpact()
                sound.playCardPlace()

                // Score sound if there were scoring events
                if !action.scoreEvents.isEmpty {
                    try? await Task.sleep(for: .milliseconds(200))
                    sound.playScore()
                }
            }
            try? await Task.sleep(for: .milliseconds(500))
            statusMessage = nil
            isProcessing = false
        }
    }
}
