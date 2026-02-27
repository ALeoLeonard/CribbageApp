import UIKit

@MainActor
enum HapticManager {

    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    static func lightImpact() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumImpact() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavyImpact() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Escalating haptic based on point value — bigger scores feel bigger
    static func scoringImpact(points: Int) {
        guard isEnabled else { return }
        switch points {
        case 1:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case 2:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case 3...5:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        default:
            // Big scores: double tap
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }

    /// 15 or 31 — crisp double-tap
    static func fifteenThirtyOne() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
        }
    }

    /// Invalid action shake
    static func invalidAction() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
