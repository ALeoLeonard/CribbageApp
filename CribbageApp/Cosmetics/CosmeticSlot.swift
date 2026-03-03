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

    /// Human-readable section title for the picker UI.
    var displayName: String {
        switch self {
        case .cardBack: return "Card Backs"
        case .cardFront: return "Card Fronts"
        case .table: return "Tables"
        case .board: return "Boards"
        case .peg: return "Peg Colors"
        case .soundPack: return "Sound Packs"
        case .hapticPack: return "Haptic Packs"
        case .phrasePack: return "Phrase Packs"
        case .avatar: return "Avatars"
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
