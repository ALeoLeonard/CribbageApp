@testable import CribbageApp
import XCTest

// MARK: - Card Front Theme Property Tests

final class CardFrontThemePropertyTests: XCTestCase {

    func testStandardCardFrontProperties() {
        let theme = StandardCardFront()
        XCTAssertEqual(theme.id, "standard")
        XCTAssertEqual(theme.displayName, "Standard")
        XCTAssertFalse(theme.isPremium)
    }

    func testModernCardFrontProperties() {
        let theme = ModernCardFront()
        XCTAssertEqual(theme.id, "modern-card")
        XCTAssertEqual(theme.displayName, "Modern")
        XCTAssertFalse(theme.isPremium)
    }

    func testVintageCardFrontProperties() {
        let theme = VintageCardFront()
        XCTAssertEqual(theme.id, "vintage-card")
        XCTAssertEqual(theme.displayName, "Vintage")
        XCTAssertTrue(theme.isPremium)
    }

    func testAllThemesHaveUniqueIDs() {
        let themes: [any CardFrontTheme] = [
            StandardCardFront(), ModernCardFront(), VintageCardFront()
        ]
        let ids = themes.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testStandardSuitColorsRedForHearts() {
        let theme = StandardCardFront()
        let heartsColor = theme.suitColor(for: .hearts)
        let diamondsColor = theme.suitColor(for: .diamonds)
        // Both red suits should return the same color
        XCTAssertEqual(heartsColor, diamondsColor)
    }

    func testStandardSuitColorsBlackForSpades() {
        let theme = StandardCardFront()
        let clubsColor = theme.suitColor(for: .clubs)
        let spadesColor = theme.suitColor(for: .spades)
        // Both black suits should return the same color
        XCTAssertEqual(clubsColor, spadesColor)
    }

    func testStandardSuitColorsRedDiffersFromBlack() {
        let theme = StandardCardFront()
        let red = theme.suitColor(for: .hearts)
        let black = theme.suitColor(for: .spades)
        XCTAssertNotEqual(red, black)
    }
}

// MARK: - CardFrontCosmeticItem Tests

final class CardFrontCosmeticItemTests: XCTestCase {

    func testWrapperProperties() {
        let theme = StandardCardFront()
        let item = CardFrontCosmeticItem(theme)

        XCTAssertEqual(item.id, "standard")
        XCTAssertEqual(item.slot, .cardFront)
        XCTAssertEqual(item.displayName, "Standard")
        XCTAssertEqual(item.previewDescription, "Standard card face style")
        XCTAssertTrue(item.isFree)
    }

    func testPremiumUnlockCondition() {
        let theme = VintageCardFront()
        let item = CardFrontCosmeticItem(theme)

        XCTAssertEqual(item.unlockCondition, .premium)
        XCTAssertTrue(item.isPremium)
        XCTAssertFalse(item.isFree)
    }

    func testFreeUnlockConditions() {
        let standard = CardFrontCosmeticItem(StandardCardFront())
        let modern = CardFrontCosmeticItem(ModernCardFront())

        XCTAssertEqual(standard.unlockCondition, .free)
        XCTAssertEqual(modern.unlockCondition, .free)
    }

    func testThemeAccessor() {
        let theme = ModernCardFront()
        let item = CardFrontCosmeticItem(theme)

        XCTAssertEqual(item.theme.id, "modern-card")
        XCTAssertEqual(item.theme.displayName, "Modern")
    }
}

// MARK: - Card Front Registry Integration Tests

@MainActor
final class CardFrontRegistryTests: XCTestCase {

    private func makeRegistry() -> CosmeticRegistry {
        let registry = CosmeticRegistry.makeForTesting()
        registry.register(CardFrontCosmeticItem(StandardCardFront()))
        registry.register(CardFrontCosmeticItem(ModernCardFront()))
        registry.register(CardFrontCosmeticItem(VintageCardFront()))
        return registry
    }

    func testCardFrontsRegisteredInCatalog() {
        let registry = makeRegistry()
        let items = registry.items(for: .cardFront)
        XCTAssertEqual(items.count, 3)
    }

    func testDefaultIsStandard() {
        let registry = makeRegistry()
        XCTAssertEqual(registry.equippedID(for: .cardFront), "standard")
    }

    func testEquipAndRetrieve() {
        let registry = makeRegistry()
        registry.unlock("modern-card")
        registry.equip("modern-card", in: .cardFront)

        XCTAssertEqual(registry.equippedID(for: .cardFront), "modern-card")
        let equipped = registry.equipped(for: .cardFront) as? CardFrontCosmeticItem
        XCTAssertNotNil(equipped)
        XCTAssertEqual(equipped?.theme.id, "modern-card")
    }

    func testActiveCardFrontAccessor() {
        let registry = makeRegistry()
        registry.unlock("standard")
        registry.equip("standard", in: .cardFront)

        let active = registry.activeCardFront
        XCTAssertEqual(active.id, "standard")
    }

    func testActiveCardFrontFallsBackToStandard() {
        let registry = CosmeticRegistry.makeForTesting()
        // No themes registered — should fall back to StandardCardFront
        let active = registry.activeCardFront
        XCTAssertEqual(active.id, "standard")
    }

    func testLockedThemeCannotBeEquipped() {
        let registry = makeRegistry()
        // vintage-card is premium, not unlocked
        registry.equip("vintage-card", in: .cardFront)
        XCTAssertEqual(registry.equippedID(for: .cardFront), "standard")
    }

    func testEquipModernAndVerifyAccessor() {
        let registry = makeRegistry()
        registry.unlock("modern-card")
        registry.equip("modern-card", in: .cardFront)

        let active = registry.activeCardFront
        XCTAssertEqual(active.id, "modern-card")
        XCTAssertEqual(active.displayName, "Modern")
    }
}
