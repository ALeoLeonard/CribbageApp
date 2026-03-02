import Foundation

// MARK: - Cosmetic Item Protocol

protocol CosmeticItem: Identifiable where ID == String {
    var id: String { get }
    var slot: CosmeticSlot { get }
    var displayName: String { get }
    var previewDescription: String { get }
    var unlockCondition: UnlockCondition { get }
}

extension CosmeticItem {
    var isPremium: Bool { unlockCondition == .premium }
    var isFree: Bool { unlockCondition == .free }
}
