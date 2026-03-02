import Foundation

// MARK: - Sound Pack Cosmetic Item

struct SoundPackCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .soundPack
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let pack: any SoundPack

    init(_ pack: any SoundPack, unlockCondition: UnlockCondition = .free) {
        self.id = pack.id
        self.displayName = pack.displayName
        self.previewDescription = "\(pack.displayName) sound style"
        self.unlockCondition = unlockCondition
        self.pack = pack
    }
}
