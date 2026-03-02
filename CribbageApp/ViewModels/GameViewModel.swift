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
    case anticipation
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

    // Hint state
    var hintIndices: Set<Int> = []
    var hintMessage: String?
    private let hintAI = HardAI()

    // Pass-and-play state
    var isPassAndPlay: Bool = false
    var passAndPlayPlayer: Int = 1 // 1 or 2
    var showingHandOver: Bool = false
    var handOverPlayerName: String = "" // Name shown on handover screen

    // Tutorial state
    var tutorialStep: TutorialStep? = nil
    var tutorialActive: Bool = false

    // Scoring callouts
    var scoringCallouts: [ScoringCallout] = []

    // Muggins state
    var mugginsPending: Bool = false
    var mugginsClaimedScore: Int = 0
    var mugginsResult: MugginsResult? = nil

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
    @ObservationIgnored
    @AppStorage("hintsEnabled") var hintsEnabled = true
    @ObservationIgnored
    @AppStorage("player2Name") var player2NameStored = "Player 2"
    @ObservationIgnored
    @AppStorage("tutorialCompleted") var tutorialCompleted = false
    @ObservationIgnored
    @AppStorage("mugginsEnabled") var mugginsEnabled = false

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
        if isPassAndPlay && passAndPlayPlayer == 2 {
            let hand = engine.phase == .play ? engine.computerPlayHand : engine.computer.hand
            return sortedHand(hand)
        }
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
        if isPassAndPlay, let engine {
            if passAndPlayPlayer == 2 {
                return engine.phase == .play ? engine.humanPlayHand.count : engine.human.hand.count
            }
        }
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
        if isPassAndPlay, let engine {
            switch engine.phase {
            case .play:
                return passAndPlayPlayer == 1 ? engine.currentTurn == "human" : engine.currentTurn == "computer"
            case .discard:
                return true
            case .countNonDealer, .countDealer, .countCrib:
                return true
            case .gameOver:
                return false
            }
        }
        return engine?.yourTurn ?? false
    }
    var humanCanPlay: Bool {
        if let mp = multiplayerVM { return mp.humanCanPlay }
        if isPassAndPlay && passAndPlayPlayer == 2 {
            return engine?.player2CanPlay ?? false
        }
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
        isPassAndPlay = false
        selectedIndices = []
        isProcessing = true
        statusMessage = nil
        starterCeremonyPhase = .idle
        startDealCeremony()
    }

    func newPassAndPlayGame() {
        let name1 = playerName.trimmingCharacters(in: .whitespaces)
        let name2 = player2NameStored.trimmingCharacters(in: .whitespaces)
        engine = GameEngine(
            player1Name: name1.isEmpty ? "Player 1" : name1,
            player2Name: name2.isEmpty ? "Player 2" : name2,
            autoDeal: false
        )
        isPassAndPlay = true
        passAndPlayPlayer = 1
        showingHandOver = false
        handOverPlayerName = ""
        selectedIndices = []
        isProcessing = true
        statusMessage = nil
        starterCeremonyPhase = .idle
        startDealCeremony()
    }

    func handOverReady() {
        guard let engine else { return }
        // Determine which player should be active based on engine state
        if engine.phase == .discard && engine.waitingForPlayer2Discard {
            passAndPlayPlayer = 2
        } else if engine.phase == .play {
            passAndPlayPlayer = engine.currentTurn == "human" ? 1 : 2
        }
        showingHandOver = false
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

    /// Map display indices (into the sorted hand) back to engine indices (into the unsorted hand).
    private func mapDisplayToEngineIndices(_ displayIndices: Set<Int>, hand: [Card]) -> [Int] {
        let sorted = sortedHand(hand)
        return displayIndices.compactMap { displayIdx -> Int? in
            guard displayIdx < sorted.count else { return nil }
            let card = sorted[displayIdx]
            return hand.firstIndex(where: { $0.id == card.id })
        }
    }

    func discard() {
        clearHint()
        if let mp = multiplayerVM {
            guard selectedIndices.count == 2 else { return }
            mp.discard(selectedIndices)
            selectedIndices = []
            HapticManager.mediumImpact()
            sound.playCardPlace()
            return
        }
        guard let engine, selectedIndices.count == 2, !isProcessing else { return }
        HapticManager.mediumImpact()
        sound.playCardPlace()

        if isPassAndPlay {
            if passAndPlayPlayer == 1 {
                let engineIndices = mapDisplayToEngineIndices(selectedIndices, hand: engine.human.hand)
                guard engineIndices.count == 2 else { return }
                selectedIndices = []
                engine.discard(cardIndices: engineIndices.sorted())
                // Show handover for player 2
                handOverPlayerName = engine.computer.name
                showingHandOver = true
            } else {
                let engineIndices = mapDisplayToEngineIndices(selectedIndices, hand: engine.computer.hand)
                guard engineIndices.count == 2 else { return }
                selectedIndices = []
                engine.discardPlayer2(cardIndices: engineIndices.sorted())
                checkGameOver()
                if engine.phase == .gameOver { return }
                // Starter ceremony, then handover for first player
                isProcessing = true
                startStarterCeremony {
                    self.isProcessing = false
                    self.passAndPlayPlayer = engine.currentTurn == "human" ? 1 : 2
                    self.handOverPlayerName = self.passAndPlayPlayer == 1 ? engine.human.name : engine.computer.name
                    self.showingHandOver = true
                }
            }
            return
        }

        // Single-player flow
        isProcessing = true
        let engineIndices = mapDisplayToEngineIndices(selectedIndices, hand: engine.human.hand)
        guard engineIndices.count == 2 else {
            isProcessing = false
            return
        }
        selectedIndices = []

        engine.discard(cardIndices: engineIndices.sorted())
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

    /// Map a single display index to an engine index for the active player's hand.
    private func mapPlayIndex(_ displayIndex: Int) -> Int? {
        guard let engine else { return nil }
        let hand: [Card]
        if isPassAndPlay && passAndPlayPlayer == 2 {
            hand = engine.computerPlayHand
        } else {
            hand = engine.humanPlayHand
        }
        let sorted = sortedHand(hand)
        guard displayIndex < sorted.count else { return nil }
        let card = sorted[displayIndex]
        return hand.firstIndex(where: { $0.id == card.id })
    }

    func playCard(_ index: Int) {
        clearHint()
        if let mp = multiplayerVM {
            mp.playCard(index)
            HapticManager.mediumImpact()
            sound.playCardSlide()
            return
        }
        guard let engine, !isProcessing else { return }

        if isPassAndPlay {
            guard let engineIndex = mapPlayIndex(index) else { return }
            HapticManager.mediumImpact()
            sound.playCardSlide()
            sound.playCardPlace()

            if passAndPlayPlayer == 1 {
                engine.playCard(cardIndex: engineIndex)
            } else {
                engine.player2PlayCard(cardIndex: engineIndex)
            }

            let log = engine.actionLog
            // Celebrate scoring with enhanced effects
            if let firstAction = log.first, !firstAction.scoreEvents.isEmpty {
                celebrateScoring(firstAction.scoreEvents)
            }
            celebrateFifteenOrThirtyOne(engine.runningTotal)

            checkGameOver()
            if engine.phase == .gameOver { return }
            if engine.phase != .play { return }

            // Check if turn changed — need handover
            let expectedTurn = passAndPlayPlayer == 1 ? "human" : "computer"
            if engine.currentTurn != expectedTurn {
                let nextPlayer = engine.currentTurn == "human" ? 1 : 2
                handOverPlayerName = nextPlayer == 1 ? engine.human.name : engine.computer.name
                showingHandOver = true
            }
            return
        }

        // Single-player flow
        guard let engineIndex = mapPlayIndex(index) else { return }
        isProcessing = true
        HapticManager.mediumImpact()
        sound.playCardSlide()

        Task {
            try? await Task.sleep(for: .milliseconds(150))
            sound.playCardPlace()
            HapticManager.lightImpact()

            engine.playCard(cardIndex: engineIndex)
            let log = engine.actionLog

            // Enhanced scoring celebration for human play
            if let firstAction = log.first, !firstAction.scoreEvents.isEmpty {
                celebrateScoring(firstAction.scoreEvents)
            }
            celebrateFifteenOrThirtyOne(engine.runningTotal)

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

        if isPassAndPlay {
            sound.playGo()
            if passAndPlayPlayer == 1 {
                engine.sayGo()
            } else {
                engine.player2SayGo()
            }

            checkGameOver()
            if engine.phase == .gameOver { return }
            if engine.phase != .play { return }

            // Check if turn changed
            let expectedTurn = passAndPlayPlayer == 1 ? "human" : "computer"
            if engine.currentTurn != expectedTurn {
                let nextPlayer = engine.currentTurn == "human" ? 1 : 2
                handOverPlayerName = nextPlayer == 1 ? engine.human.name : engine.computer.name
                showingHandOver = true
            }
            return
        }

        // Single-player flow
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

        // If muggins result is showing, dismiss it and continue
        if mugginsResult != nil {
            dismissMugginsResult()
            return
        }

        // If muggins applies to this phase, start the claim flow instead of advancing
        if mugginsAppliesCurrentPhase && !mugginsPending {
            beginMugginsClaim()
            return
        }

        HapticManager.lightImpact()

        // Record hand/crib scores before advancing (skip in pass-and-play)
        if !isPassAndPlay, let breakdown = engine.scoreBreakdown {
            if engine.phase == .countCrib {
                stats.recordCribScore(breakdown.total)
            } else {
                stats.recordHandScore(breakdown.total)
            }
        }
        if let breakdown = engine.scoreBreakdown, breakdown.total > 0 {
            sound.playScore()
        }

        let wasCountCrib = engine.phase == .countCrib
        engine.acknowledge()
        checkGameOver()

        // If we just finished counting crib, a new round was dealt —
        // trigger deal ceremony for the new round
        if wasCountCrib && engine.phase == .discard {
            isProcessing = true
            starterCeremonyPhase = .idle
            if isPassAndPlay {
                passAndPlayPlayer = 1
            }
            sound.playRoundTransition()
            HapticManager.success()
            startDealCeremony()
        }
    }

    func restartGame() {
        engine?.newGame()
        selectedIndices = []
        isProcessing = true
        statusMessage = nil
        starterCeremonyPhase = .idle
        mugginsPending = false
        mugginsResult = nil
        if isPassAndPlay {
            passAndPlayPlayer = 1
            showingHandOver = false
        }

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

        if isPassAndPlay {
            // In pass-and-play, don't record stats — just play the win sound
            sound.playWin()
            return
        }

        let won = winner == engine.human.name
        stats.recordGameResult(won: won, difficulty: engine.aiDifficulty)
        let loserScore = won ? engine.computer.score : engine.human.score
        stats.recordSkunkResult(won: won, loserScore: loserScore)
        if engine.humanPeggingPoints > 0 {
            stats.recordPeggingPoints(engine.humanPeggingPoints)
        }

        // Game Center score submissions
        GameCenterManager.shared.submitAllStats()

        // Ad cadence tracking
        if AdManager.shared.recordGameCompleted() {
            AdManager.shared.presentInterstitial()
        }

        if won {
            if let milestone = stats.streakMilestone {
                sound.playStreakFanfare(milestone: milestone)
                HapticManager.streakCelebration(milestone: milestone)
            } else {
                sound.playWin()
            }
        } else {
            sound.playLose()
        }
    }

    // MARK: - Hints

    func showHint() {
        guard let engine, !isProcessing else { return }
        clearHint()

        switch phase {
        case .discard:
            let hand: [Card]
            let isDealer: Bool
            if isPassAndPlay && passAndPlayPlayer == 2 {
                hand = engine.computer.hand
                isDealer = engine.computer.isDealer
            } else {
                hand = engine.human.hand
                isDealer = engine.human.isDealer
            }
            let recommended = hintAI.chooseDiscards(hand: hand, isDealer: isDealer)
            let sortedCards = sortedHand(hand)
            var displayIndices: Set<Int> = []
            for engineIdx in recommended {
                let card = hand[engineIdx]
                if let displayIdx = sortedCards.firstIndex(where: { $0.id == card.id }) {
                    displayIndices.insert(displayIdx)
                }
            }
            hintIndices = displayIndices
            hintMessage = "Recommended discard"
            HapticManager.lightImpact()

        case .play:
            let hand: [Card]
            if isPassAndPlay && passAndPlayPlayer == 2 {
                hand = engine.computerPlayHand
            } else {
                hand = engine.humanPlayHand
            }
            guard let engineIdx = hintAI.choosePlay(
                hand: hand,
                playPile: engine.playPile,
                runningTotal: engine.runningTotal
            ) else { return }
            let card = hand[engineIdx]
            let sortedCards = sortedHand(hand)
            if let displayIdx = sortedCards.firstIndex(where: { $0.id == card.id }) {
                hintIndices = [displayIdx]
                hintMessage = "Recommended play"
            }
            HapticManager.lightImpact()

        default:
            break
        }
    }

    func clearHint() {
        hintIndices = []
        hintMessage = nil
    }

    // MARK: - Muggins

    /// Whether muggins applies to the current counting phase (human's hand/crib only).
    var mugginsAppliesCurrentPhase: Bool {
        guard mugginsEnabled, !isPassAndPlay, let engine else { return false }
        switch engine.phase {
        case .countNonDealer:
            return !engine.isHumanDealer // human is non-dealer
        case .countDealer:
            return engine.isHumanDealer
        case .countCrib:
            return engine.isHumanDealer
        default:
            return false
        }
    }

    /// The hand being counted in the current muggins phase (for display before claiming).
    var mugginsHandToCount: [Card]? {
        guard mugginsPending, let engine else { return nil }
        switch engine.phase {
        case .countNonDealer:
            return engine.isHumanDealer ? engine.computer.hand : engine.human.hand
        case .countDealer:
            return engine.isHumanDealer ? engine.human.hand : engine.computer.hand
        case .countCrib:
            return engine.crib
        default:
            return nil
        }
    }

    /// Start muggins claim flow — show the hand and ask player to count.
    func beginMugginsClaim() {
        mugginsPending = true
        mugginsClaimedScore = 0
        mugginsResult = nil
    }

    /// Submit the muggins claim. Calculates real score, awards points, shows result.
    func submitMugginsClaim() {
        guard let engine, mugginsPending else { return }
        guard let starter = engine.starter else { return }

        // Calculate the real score
        let hand: [Card]
        let isCrib: Bool
        switch engine.phase {
        case .countNonDealer:
            hand = engine.isHumanDealer ? engine.computer.hand : engine.human.hand
            isCrib = false
        case .countDealer:
            hand = engine.isHumanDealer ? engine.human.hand : engine.computer.hand
            isCrib = false
        case .countCrib:
            hand = engine.crib
            isCrib = true
        default:
            return
        }

        let nobsEnabled = UserDefaults.standard.object(forKey: "nobsEnabled") as? Bool ?? true
        let (actualScore, _) = Scoring.calculateScore(hand: hand, starter: starter, isCrib: isCrib, nobsEnabled: nobsEnabled)
        let claimed = min(max(mugginsClaimedScore, 0), 29) // cap at max possible hand
        let result = MugginsResult(claimedScore: claimed, actualScore: actualScore)
        mugginsResult = result

        // Sound + haptic feedback
        if result.isPerfect {
            sound.playScoreChime(points: actualScore)
            HapticManager.success()
        } else if result.mugginsPoints > 0 {
            sound.playInvalidAction()
            HapticManager.invalidAction()
        } else {
            // Overclaimed — just award actual
            sound.playScoreChime(points: actualScore)
            HapticManager.lightImpact()
        }

        // Record stats
        if !isPassAndPlay {
            if engine.phase == .countCrib {
                stats.recordCribScore(actualScore)
            } else {
                stats.recordHandScore(actualScore)
            }
        }

        // Award points via engine: claimed to scorer, muggins to opponent
        let wasCountCrib = engine.phase == .countCrib
        engine.acknowledge(mugginsClaimedScore: claimed)

        // Award muggins bonus to opponent
        if result.mugginsPoints > 0 {
            engine.awardBonus(result.mugginsPoints, toHuman: false)
        }

        checkGameOver()

        // If we just finished counting crib, handle new round
        if wasCountCrib && engine.phase == .discard {
            mugginsPending = false
            isProcessing = true
            starterCeremonyPhase = .idle
            sound.playRoundTransition()
            HapticManager.success()
            startDealCeremony()
        }
    }

    /// Dismiss muggins result and continue to next phase.
    func dismissMugginsResult() {
        mugginsPending = false
        mugginsResult = nil
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

    // MARK: - Scoring Celebrations

    /// Fire scoring callouts, sound, and haptics for play-phase score events.
    private func celebrateScoring(_ events: [ScoreEvent]) {
        guard !events.isEmpty else { return }
        let totalPoints = events.reduce(0) { $0 + $1.points }
        guard totalPoints > 0 else { return }

        // Enhanced sound — pitch scales with points
        sound.playScoreChime(points: totalPoints)

        // Escalating haptic
        HapticManager.scoringImpact(points: totalPoints)

        // Add callout text for each event
        for event in events where event.points > 0 {
            let callout = ScoringCallout(text: calloutText(for: event), points: event.points)
            scoringCallouts.append(callout)
        }

        // Auto-clear callouts after delay
        Task {
            try? await Task.sleep(for: .milliseconds(1800))
            scoringCallouts.removeAll()
        }
    }

    private func calloutText(for event: ScoreEvent) -> String {
        let reason = event.reason.lowercased()
        if reason.contains("15") { return "15 for \(event.points)!" }
        if reason.contains("pair") { return "Pair!" }
        if reason.contains("three of") || reason.contains("royal pair") { return "Three of a Kind!" }
        if reason.contains("four of") || reason.contains("double royal") { return "Four of a Kind!" }
        if reason.contains("run") { return "Run of \(event.reason.filter(\.isNumber))!" }
        if reason.contains("31") { return "31 for 2!" }
        if reason.contains("go") || reason.contains("last card") { return "Go!" }
        if reason.contains("his heels") { return "His Heels!" }
        if reason.contains("nobs") || reason.contains("his nobs") { return "His Nobs!" }
        if reason.contains("flush") { return "Flush!" }
        return "+\(event.points)"
    }

    /// Invalid play attempt — card can't be played (exceeds 31 or not your turn)
    func invalidPlayAttempt() {
        HapticManager.invalidAction()
        sound.playInvalidAction()
    }

    /// Fire 15/31 special celebration.
    private func celebrateFifteenOrThirtyOne(_ total: Int) {
        if total == 15 || total == 31 {
            sound.playFifteenOrThirtyOne()
            HapticManager.fifteenThirtyOne()
        }
    }

    // MARK: - Tutorial

    func startTutorialIfNeeded() {
        guard !tutorialCompleted, !isPassAndPlay else { return }
        tutorialActive = true
        tutorialStep = .welcome
    }

    func advanceTutorial() {
        guard tutorialActive, let current = tutorialStep else { return }
        let allSteps = TutorialStep.allCases
        if let idx = allSteps.firstIndex(of: current), idx + 1 < allSteps.count {
            let next = allSteps[idx + 1]
            tutorialStep = next
            if next == .complete {
                tutorialCompleted = true
            }
        } else {
            endTutorial()
        }
    }

    func skipTutorial() {
        tutorialCompleted = true
        endTutorial()
    }

    private func endTutorial() {
        tutorialActive = false
        tutorialStep = nil
    }

    /// Called when game phase changes to potentially show the next tutorial step.
    func tutorialCheckPhase() {
        guard tutorialActive, let step = tutorialStep else { return }
        // Auto-advance tutorial based on phase transitions
        switch phase {
        case .play:
            if step == .selectDiscard {
                tutorialStep = .starterCard
            }
        case .countNonDealer:
            if step == .sayGo || step == .playPhase {
                tutorialStep = .counting
            }
        default:
            break
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
            startTutorialIfNeeded()
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

            // Anticipation phase — rising tone before reveal
            starterCeremonyPhase = .anticipation
            sound.playAnticipation()
            try? await Task.sleep(for: .milliseconds(600))

            // Reveal
            starterCeremonyPhase = .revealing
            sound.playCardFlip()
            HapticManager.lightImpact()

            try? await Task.sleep(for: .milliseconds(600))
            starterCeremonyPhase = .done

            // His Heels celebration if Jack starter
            let hisHeelsEnabled = UserDefaults.standard.object(forKey: "hisHeelsEnabled") as? Bool ?? true
            if hisHeelsEnabled, let starter = engine?.starter, starter.rank == .jack {
                sound.playHisHeelsCelebration()
                HapticManager.success()
            }

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

                // Enhanced scoring celebrations for computer plays
                if !action.scoreEvents.isEmpty {
                    try? await Task.sleep(for: .milliseconds(200))
                    celebrateScoring(action.scoreEvents)
                }
            }
            try? await Task.sleep(for: .milliseconds(500))
            statusMessage = nil
            isProcessing = false
        }
    }
}
