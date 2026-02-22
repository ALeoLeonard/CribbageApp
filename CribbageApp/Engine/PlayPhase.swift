import Foundation

enum PlayPhaseHelper {
    /// Check if any card in hand can be played without exceeding 31.
    static func canPlay(hand: [Card], runningTotal: Int) -> Bool {
        hand.contains { $0.value + runningTotal <= 31 }
    }
}
