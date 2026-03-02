import SwiftUI

// MARK: - Card Back Cosmetic Item

struct CardBackCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .cardBack
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let theme: any CardBackTheme

    init(_ theme: any CardBackTheme) {
        self.id = theme.id
        self.displayName = theme.displayName
        self.previewDescription = "\(theme.displayName) card back design"
        self.unlockCondition = theme.isPremium ? .premium : .free
        self.theme = theme
    }
}

// MARK: - Table Cosmetic Item

struct TableCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .table
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let theme: any TableTheme

    init(_ theme: any TableTheme) {
        self.id = theme.id
        self.displayName = theme.displayName
        self.previewDescription = "\(theme.displayName) table surface"
        self.unlockCondition = theme.isPremium ? .premium : .free
        self.theme = theme
    }
}

// MARK: - Board Cosmetic Item

struct BoardCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .board
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let theme: any BoardTheme

    init(_ theme: any BoardTheme) {
        self.id = theme.id
        self.displayName = theme.displayName
        self.previewDescription = "\(theme.displayName) cribbage board"
        self.unlockCondition = theme.isPremium ? .premium : .free
        self.theme = theme
    }
}
