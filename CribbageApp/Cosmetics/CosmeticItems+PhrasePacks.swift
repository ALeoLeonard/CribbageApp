import Foundation

// MARK: - Phrase Pack Cosmetic Item

struct PhrasePackCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .phrasePack
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let pack: any PhrasePack

    init(_ pack: any PhrasePack, unlockCondition: UnlockCondition = .free) {
        self.id = pack.id
        self.displayName = pack.displayName
        self.previewDescription = "\(pack.displayName) phrase pack"
        self.unlockCondition = unlockCondition
        self.pack = pack
    }
}
