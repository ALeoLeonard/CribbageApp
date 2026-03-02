import UIKit

// MARK: - Standard Haptic Pack

struct StandardHapticPack: HapticPack {
    nonisolated let id = "standard-haptics"
    nonisolated let displayName = "Standard"

    func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func heavyImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func scoringImpact(points: Int) {
        switch points {
        case 1:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case 2:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case 3...5:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        default:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }

    func fifteenThirtyOne() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
        }
    }

    func streakCelebration(milestone: StreakMilestone) {
        switch milestone {
        case .rolling:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .hotStreak, .legendary, .domination:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }

    func invalidAction() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

// MARK: - Intense Haptic Pack

struct IntenseHapticPack: HapticPack {
    nonisolated let id = "intense-haptics"
    nonisolated let displayName = "Intense"

    func lightImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func mediumImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func heavyImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1.0)
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    func selection() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func scoringImpact(points: Int) {
        switch points {
        case 1...2:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case 3...5:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        default:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }

    func fifteenThirtyOne() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.6)
        }
    }

    func streakCelebration(milestone: StreakMilestone) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    func invalidAction() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - Subtle Haptic Pack

struct SubtleHapticPack: HapticPack {
    nonisolated let id = "subtle-haptics"
    nonisolated let displayName = "Subtle"

    func lightImpact() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    func mediumImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func heavyImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func success() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func scoringImpact(points: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func fifteenThirtyOne() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func streakCelebration(milestone: StreakMilestone) {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func invalidAction() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
