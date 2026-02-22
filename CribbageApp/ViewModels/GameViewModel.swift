import Foundation
import SwiftUI

/// Wraps GameEngine and adds animation delays for computer actions.
@MainActor @Observable
final class GameViewModel {
    var engine: GameEngine?
    var selectedIndices: Set<Int> = []
    var isProcessing = false
    var statusMessage: String?

    // Persisted settings
    @ObservationIgnored
    @AppStorage("playerName") var playerName = "Player"
    @ObservationIgnored
    @AppStorage("difficulty") var difficultyRaw = AIDifficulty.easy.rawValue

    var difficulty: AIDifficulty {
        get { AIDifficulty(rawValue: difficultyRaw) ?? .easy }
        set { difficultyRaw = newValue.rawValue }
    }

    // MARK: - Game State Accessors

    var phase: GamePhase { engine?.phase ?? .discard }
    var humanHand: [Card] {
        guard let engine else { return [] }
        return engine.phase == .play ? engine.humanPlayHand : engine.human.hand
    }
    var humanScore: Int { engine?.human.score ?? 0 }
    var humanName: String { engine?.human.name ?? playerName }
    var humanIsDealer: Bool { engine?.human.isDealer ?? false }

    var opponentScore: Int { engine?.computer.score ?? 0 }
    var opponentName: String { engine?.computer.name ?? "Computer" }
    var opponentHandCount: Int { engine?.opponentHandCount ?? 0 }
    var opponentIsDealer: Bool { engine?.computer.isDealer ?? false }

    var starter: Card? { engine?.starter }
    var playPile: [Card] { engine?.playPile ?? [] }
    var runningTotal: Int { engine?.runningTotal ?? 0 }
    var cribCount: Int { engine?.crib.count ?? 0 }
    var roundNumber: Int { engine?.roundNumber ?? 1 }
    var winner: String? { engine?.winner }
    var scoreBreakdown: ScoreBreakdown? { engine?.scoreBreakdown }
    var lastAction: LastAction? { engine?.lastAction }
    var actionLog: [LastAction] { engine?.actionLog ?? [] }

    var yourTurn: Bool { engine?.yourTurn ?? false }
    var humanCanPlay: Bool { engine?.humanCanPlay ?? false }

    // MARK: - Actions

    func newGame() {
        let name = playerName.trimmingCharacters(in: .whitespaces)
        engine = GameEngine(playerName: name.isEmpty ? "Player" : name, aiDifficulty: difficulty)
        selectedIndices = []
        isProcessing = false
        statusMessage = nil
    }

    func toggleSelect(_ index: Int) {
        guard phase == .discard else { return }
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else if selectedIndices.count < 2 {
            selectedIndices.insert(index)
        }
    }

    func discard() {
        guard let engine, selectedIndices.count == 2, !isProcessing else { return }
        isProcessing = true
        let indices = Array(selectedIndices).sorted()
        selectedIndices = []

        engine.discard(cardIndices: indices)
        let log = engine.actionLog

        if log.isEmpty || engine.phase == .gameOver {
            isProcessing = false
            return
        }

        let computerPlays = log.filter { $0.actor == engine.computer.name && $0.action == "play" }
        if computerPlays.isEmpty {
            isProcessing = false
            return
        }

        animateActionLog(log)
    }

    func playCard(_ index: Int) {
        guard let engine, !isProcessing else { return }
        isProcessing = true

        engine.playCard(cardIndex: index)
        let log = engine.actionLog

        let computerPlays = log.filter { $0.actor == engine.computer.name && $0.action == "play" }
        if computerPlays.isEmpty {
            isProcessing = false
            return
        }

        animateActionLog(Array(log.dropFirst()))
    }

    func sayGo() {
        guard let engine, !isProcessing else { return }
        isProcessing = true

        engine.sayGo()
        let log = engine.actionLog

        if log.count <= 1 {
            isProcessing = false
            return
        }

        animateActionLog(Array(log.dropFirst()))
    }

    func acknowledge() {
        guard let engine, !isProcessing else { return }
        engine.acknowledge()
    }

    func restartGame() {
        engine?.newGame()
        selectedIndices = []
        isProcessing = false
        statusMessage = nil
    }

    // MARK: - Animation

    private func animateActionLog(_ actions: [LastAction]) {
        guard !actions.isEmpty else {
            isProcessing = false
            return
        }

        Task {
            for action in actions {
                try? await Task.sleep(for: .milliseconds(Int.random(in: 800...1200)))
                statusMessage = action.message
            }
            try? await Task.sleep(for: .milliseconds(300))
            statusMessage = nil
            isProcessing = false
        }
    }
}
