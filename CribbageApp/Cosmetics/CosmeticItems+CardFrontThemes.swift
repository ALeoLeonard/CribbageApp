import Foundation

// MARK: - Card Front Cosmetic Item

struct CardFrontCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .cardFront
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let theme: any CardFrontTheme

    init(_ theme: any CardFrontTheme) {
        self.id = theme.id
        self.displayName = theme.displayName
        self.previewDescription = "\(theme.displayName) card face style"
        self.unlockCondition = theme.isPremium ? .premium : .free
        self.theme = theme
    }
}
