import UIKit

// MARK: - Haptic Pack Protocol

/// Defines all game haptic feedback methods. Each pack provides a different tactile style.
@MainActor
protocol HapticPack {
    nonisolated var id: String { get }
    nonisolated var displayName: String { get }

    func lightImpact()
    func mediumImpact()
    func heavyImpact()
    func success()
    func error()
    func selection()
    func scoringImpact(points: Int)
    func fifteenThirtyOne()
    func streakCelebration(milestone: StreakMilestone)
    func invalidAction()
}
