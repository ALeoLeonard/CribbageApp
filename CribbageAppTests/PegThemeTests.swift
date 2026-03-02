@testable import CribbageApp
import XCTest

// MARK: - Peg Theme Property Tests

final class PegThemePropertyTests: XCTestCase {

    func testClassicPegProperties() {
        let peg = ClassicPeg()
        XCTAssertEqual(peg.id, "classic-peg")
        XCTAssertEqual(peg.displayName, "Classic")
        XCTAssertNotNil(peg.playerColor)
        XCTAssertNotNil(peg.opponentColor)
        XCTAssertNotNil(peg.playerGlowColor)
        XCTAssertNotNil(peg.opponentGlowColor)
    }

    func testBrassPegProperties() {
        let peg = BrassPeg()
        XCTAssertEqual(peg.id, "brass-peg")
        XCTAssertEqual(peg.displayName, "Brass")
    }

    func testIvoryPegProperties() {
        let peg = IvoryPeg()
        XCTAssertEqual(peg.id, "ivory-peg")
        XCTAssertEqual(peg.displayName, "Ivory")
    }

    func testRubyPegProperties() {
        let peg = RubyPeg()
        XCTAssertEqual(peg.id, "ruby-peg")
        XCTAssertEqual(peg.displayName, "Ruby")
    }

    func testJadePegProperties() {
        let peg = JadePeg()
        XCTAssertEqual(peg.id, "jade-peg")
        XCTAssertEqual(peg.displayName, "Jade")
    }

    func testObsidianPegProperties() {
        let peg = ObsidianPeg()
        XCTAssertEqual(peg.id, "obsidian-peg")
        XCTAssertEqual(peg.displayName, "Obsidian")
    }

    func testAllThemesHaveUniqueIDs() {
        let themes: [any PegTheme] = [
            ClassicPeg(), BrassPeg(), IvoryPeg(),
            RubyPeg(), JadePeg(), ObsidianPeg()
        ]
        let ids = themes.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }
}

// MARK: - PegThemeCosmeticItem Tests

final class PegThemeCosmeticItemTests: XCTestCase {

    func testWrapperProperties() {
        let theme = ClassicPeg()
        let item = PegThemeCosmeticItem(theme)

        XCTAssertEqual(item.id, "classic-peg")
        XCTAssertEqual(item.slot, .peg)
        XCTAssertEqual(item.displayName, "Classic")
        XCTAssertEqual(item.previewDescription, "Classic peg style")
        XCTAssertTrue(item.isFree)
    }

    func testPremiumUnlockCondition() {
        let theme = IvoryPeg()
        let item = PegThemeCosmeticItem(theme, unlockCondition: .premium)

        XCTAssertEqual(item.unlockCondition, .premium)
        XCTAssertTrue(item.isPremium)
        XCTAssertFalse(item.isFree)
    }

    func testThemeAccessor() {
        let theme = JadePeg()
        let item = PegThemeCosmeticItem(theme)

        XCTAssertEqual(item.theme.id, "jade-peg")
        XCTAssertEqual(item.theme.displayName, "Jade")
    }

    func testUnlockConditions() {
        let items: [(any PegTheme, UnlockCondition)] = [
            (ClassicPeg(), .free),
            (BrassPeg(), .free),
            (IvoryPeg(), .premium),
            (RubyPeg(), .premium),
            (JadePeg(), .premium),
            (ObsidianPeg(), .premium)
        ]

        let freeCount = items.filter { $0.1 == .free }.count
        let premiumCount = items.filter { $0.1 == .premium }.count
        XCTAssertEqual(freeCount, 2)
        XCTAssertEqual(premiumCount, 4)
    }
}

// MARK: - Peg Theme Registry Integration Tests

@MainActor
final class PegThemeRegistryTests: XCTestCase {

    private func makeRegistry() -> CosmeticRegistry {
        let registry = CosmeticRegistry.makeForTesting()
        registry.register(PegThemeCosmeticItem(ClassicPeg()))
        registry.register(PegThemeCosmeticItem(BrassPeg()))
        registry.register(PegThemeCosmeticItem(IvoryPeg(), unlockCondition: .premium))
        registry.register(PegThemeCosmeticItem(RubyPeg(), unlockCondition: .premium))
        registry.register(PegThemeCosmeticItem(JadePeg(), unlockCondition: .premium))
        registry.register(PegThemeCosmeticItem(ObsidianPeg(), unlockCondition: .premium))
        return registry
    }

    func testPegThemesRegisteredInCatalog() {
        let registry = makeRegistry()
        let items = registry.items(for: .peg)
        XCTAssertEqual(items.count, 6)
    }

    func testDefaultIsClassic() {
        let registry = makeRegistry()
        XCTAssertEqual(registry.equippedID(for: .peg), "classic-peg")
    }

    func testEquipAndRetrieve() {
        let registry = makeRegistry()
        registry.unlock("brass-peg")
        registry.equip("brass-peg", in: .peg)

        XCTAssertEqual(registry.equippedID(for: .peg), "brass-peg")
        let equipped = registry.equipped(for: .peg) as? PegThemeCosmeticItem
        XCTAssertNotNil(equipped)
        XCTAssertEqual(equipped?.theme.id, "brass-peg")
    }

    func testActivePegThemeAccessor() {
        let registry = makeRegistry()
        registry.unlock("classic-peg")
        registry.equip("classic-peg", in: .peg)

        let active = registry.activePegTheme
        XCTAssertEqual(active.id, "classic-peg")
    }

    func testActivePegThemeFallsBackToClassic() {
        let registry = CosmeticRegistry.makeForTesting()
        // No themes registered — should fall back to ClassicPeg
        let active = registry.activePegTheme
        XCTAssertEqual(active.id, "classic-peg")
    }

    func testLockedThemeCannotBeEquipped() {
        let registry = makeRegistry()
        // ivory-peg is premium, not unlocked
        registry.equip("ivory-peg", in: .peg)
        XCTAssertEqual(registry.equippedID(for: .peg), "classic-peg")
    }
}
