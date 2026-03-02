import Foundation

// MARK: - Cosmetic Slot

enum CosmeticSlot: String, CaseIterable, Sendable {
    case cardBack
    case cardFront
    case table
    case board
    case peg
    case soundPack
    case hapticPack
    case phrasePack
    case avatar

    /// UserDefaults key for the equipped item in this slot.
    /// Existing slots use legacy keys for backward compatibility.
    var equippedKey: String {
        switch self {
        case .cardBack: return "activeCardBack"
        case .table: return "activeTable"
        case .board: return "activeBoard"
        default: return "equipped.\(rawValue)"
        }
    }

    /// Default item ID when nothing is equipped.
    var defaultItemID: String {
        switch self {
        case .cardBack: return "classic-navy"
        case .cardFront: return "standard"
        case .table: return "green-felt"
        case .board: return "classic-wood"
        case .peg: return "classic-peg"
        case .soundPack: return "classic-sounds"
        case .hapticPack: return "standard-haptics"
        case .phrasePack: return "classic-phrases"
        case .avatar: return "default-avatar"
        }
    }
}

// MARK: - Unlock Condition

enum UnlockCondition: Sendable, Equatable {
    case free
    case premium
    case achievement(String)
    case stat(key: String, threshold: Int)
}
