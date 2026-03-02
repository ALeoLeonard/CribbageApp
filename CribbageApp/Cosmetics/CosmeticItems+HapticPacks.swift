import Foundation

// MARK: - Haptic Pack Cosmetic Item

struct HapticPackCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .hapticPack
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let pack: any HapticPack

    init(_ pack: any HapticPack, unlockCondition: UnlockCondition = .free) {
        self.id = pack.id
        self.displayName = pack.displayName
        self.previewDescription = "\(pack.displayName) haptic style"
        self.unlockCondition = unlockCondition
        self.pack = pack
    }
}
