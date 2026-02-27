import Foundation

/// Manages multiplayer game state received from the server.
/// GameViewModel delegates to this when in multiplayer mode.
@MainActor
final class MultiplayerViewModel {
    // Current state from server
    private(set) var gameState: ServerGameState?

    // Chat messages
    private(set) var chatMessages: [ChatMessage] = []

    // Callback to notify GameViewModel that state changed
    var onStateChanged: (() -> Void)?

    // Callback to send messages via WebSocket
    var sendMessage: ((WSClientMessage) -> Void)?

    // MARK: - State Accessors (mirror GameViewModel's properties)

    var phase: GamePhase {
        guard let state = gameState else { return .discard }
        return GamePhase(rawValue: state.phase) ?? .discard
    }

    var humanHand: [Card] {
        gameState?.yourHand.map { $0.toCard() } ?? []
    }

    var humanScore: Int { gameState?.yourScore ?? 0 }
    var humanName: String { gameState?.yourName ?? "Player" }
    var humanIsDealer: Bool { gameState?.youAreDealer ?? false }

    var opponentScore: Int { gameState?.opponentScore ?? 0 }
    var opponentName: String { gameState?.opponentName ?? "Opponent" }
    var opponentHandCount: Int { gameState?.opponentHandCount ?? 0 }
    var opponentIsDealer: Bool { !(gameState?.youAreDealer ?? false) }

    var starter: Card? { gameState?.starter?.toCard() }
    var playPile: [Card] { gameState?.playPile.map { $0.toCard() } ?? [] }
    var runningTotal: Int { gameState?.runningTotal ?? 0 }
    var cribCount: Int { gameState?.cribCount ?? 0 }
    var roundNumber: Int { gameState?.roundNumber ?? 1 }
    var winner: String? { gameState?.winner }
    var scoreBreakdown: ScoreBreakdown? { gameState?.scoreBreakdown?.toScoreBreakdown() }
    var lastAction: LastAction? { gameState?.lastAction?.toLastAction() }
    var yourTurn: Bool { gameState?.yourTurn ?? false }
    var humanCanPlay: Bool { gameState?.canPlay ?? false }

    var countPhasePlayerName: String {
        guard let state = gameState else { return "" }
        switch state.phase {
        case "count_non_dealer":
            return state.youAreDealer ? state.opponentName : state.yourName
        case "count_dealer", "count_crib":
            return state.youAreDealer ? state.yourName : state.opponentName
        default:
            return ""
        }
    }

    // MARK: - Update from Server

    func updateState(_ state: ServerGameState) {
        self.gameState = state
        onStateChanged?()
    }

    func addChatMessage(text: String, isFromMe: Bool, sender: String) {
        let msg = ChatMessage(sender: sender, text: text, isFromMe: isFromMe, timestamp: Date())
        chatMessages.append(msg)
        onStateChanged?()
    }

    // MARK: - Actions (send to server)

    func discard(_ indices: Set<Int>) {
        sendMessage?(WSClientMessage(type: "discard", cardIndices: Array(indices).sorted()))
    }

    func playCard(_ index: Int) {
        sendMessage?(WSClientMessage(type: "play_card", cardIndex: index))
    }

    func sayGo() {
        sendMessage?(WSClientMessage(type: "say_go"))
    }

    func acknowledge() {
        sendMessage?(WSClientMessage(type: "acknowledge"))
    }

    func sendChat(_ text: String) {
        sendMessage?(WSClientMessage(type: "chat", message: text))
        addChatMessage(text: text, isFromMe: true, sender: humanName)
    }
}
