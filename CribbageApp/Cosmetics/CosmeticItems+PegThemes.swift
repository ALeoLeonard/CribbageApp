import Foundation

// MARK: - Peg Theme Cosmetic Item

struct PegThemeCosmeticItem: CosmeticItem {
    let id: String
    let slot: CosmeticSlot = .peg
    let displayName: String
    let previewDescription: String
    let unlockCondition: UnlockCondition
    let theme: any PegTheme

    init(_ theme: any PegTheme, unlockCondition: UnlockCondition = .free) {
        self.id = theme.id
        self.displayName = theme.displayName
        self.previewDescription = "\(theme.displayName) peg style"
        self.unlockCondition = unlockCondition
        self.theme = theme
    }
}
