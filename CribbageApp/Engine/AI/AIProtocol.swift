import Foundation

/// Protocol for all AI difficulty levels.
protocol CribbageAI {
    /// Choose 2 card indices to discard from a 6-card hand.
    func chooseDiscards(hand: [Card], isDealer: Bool) -> [Int]

    /// Choose a card index to play, or nil if no valid play (Go).
    func choosePlay(hand: [Card], playPile: [Card], runningTotal: Int) -> Int?
}

extension CribbageAI {
    /// Default implementation: find playable indices, then delegate to `pickPlay`.
    func choosePlay(hand: [Card], playPile: [Card], runningTotal: Int) -> Int? {
        let playable = hand.indices.filter { hand[$0].value + runningTotal <= 31 }
        guard !playable.isEmpty else { return nil }
        return pickPlay(hand: hand, playable: playable, playPile: playPile, runningTotal: runningTotal)
    }

    func pickPlay(hand: [Card], playable: [Int], playPile: [Card], runningTotal: Int) -> Int {
        playable.randomElement()!
    }
}

/// Factory to create the appropriate AI for a difficulty level.
func createAI(_ difficulty: AIDifficulty) -> CribbageAI {
    switch difficulty {
    case .easy: EasyAI()
    case .medium: MediumAI()
    case .hard: HardAI()
    }
}
