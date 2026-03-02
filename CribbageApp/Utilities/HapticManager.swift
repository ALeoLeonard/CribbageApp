import UIKit

@MainActor
enum HapticManager {

    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    static var activeHapticPack: any HapticPack {
        CosmeticRegistry.shared.activeHapticPack
    }

    static func lightImpact() {
        guard isEnabled else { return }
        activeHapticPack.lightImpact()
    }

    static func mediumImpact() {
        guard isEnabled else { return }
        activeHapticPack.mediumImpact()
    }

    static func heavyImpact() {
        guard isEnabled else { return }
        activeHapticPack.heavyImpact()
    }

    static func success() {
        guard isEnabled else { return }
        activeHapticPack.success()
    }

    static func error() {
        guard isEnabled else { return }
        activeHapticPack.error()
    }

    static func selection() {
        guard isEnabled else { return }
        activeHapticPack.selection()
    }

    /// Escalating haptic based on point value — bigger scores feel bigger
    static func scoringImpact(points: Int) {
        guard isEnabled else { return }
        activeHapticPack.scoringImpact(points: points)
    }

    /// 15 or 31 — crisp double-tap
    static func fifteenThirtyOne() {
        guard isEnabled else { return }
        activeHapticPack.fifteenThirtyOne()
    }

    /// Streak celebration — escalating haptic for win streak milestones
    static func streakCelebration(milestone: StreakMilestone) {
        guard isEnabled else { return }
        activeHapticPack.streakCelebration(milestone: milestone)
    }

    /// Invalid action shake
    static func invalidAction() {
        guard isEnabled else { return }
        activeHapticPack.invalidAction()
    }
}
