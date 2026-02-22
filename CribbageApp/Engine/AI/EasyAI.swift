import Foundation

/// Random discards, random play.
struct EasyAI: CribbageAI {
    func chooseDiscards(hand: [Card], isDealer: Bool) -> [Int] {
        let indices = Array(hand.indices)
        let sampled = indices.shuffled().prefix(2)
        return sampled.sorted()
    }

    func pickPlay(hand: [Card], playable: [Int], playPile: [Card], runningTotal: Int) -> Int {
        playable.randomElement()!
    }
}
