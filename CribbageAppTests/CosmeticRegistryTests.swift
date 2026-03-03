@testable import CribbageApp
import XCTest

// MARK: - CosmeticSlot Tests

final class CosmeticSlotTests: XCTestCase {

    func testBackwardCompatibleEquippedKeys() {
        XCTAssertEqual(CosmeticSlot.cardBack.equippedKey, "activeCardBack")
        XCTAssertEqual(CosmeticSlot.table.equippedKey, "activeTable")
        XCTAssertEqual(CosmeticSlot.board.equippedKey, "activeBoard")
    }

    func testNewSlotEquippedKeys() {
        XCTAssertEqual(CosmeticSlot.peg.equippedKey, "equipped.peg")
        XCTAssertEqual(CosmeticSlot.soundPack.equippedKey, "equipped.soundPack")
        XCTAssertEqual(CosmeticSlot.avatar.equippedKey, "equipped.avatar")
    }

    func testDefaultItemIDs() {
        XCTAssertEqual(CosmeticSlot.cardBack.defaultItemID, "classic-navy")
        XCTAssertEqual(CosmeticSlot.table.defaultItemID, "green-felt")
        XCTAssertEqual(CosmeticSlot.board.defaultItemID, "classic-wood")
    }

    func testDisplayNames() {
        XCTAssertEqual(CosmeticSlot.cardBack.displayName, "Card Backs")
        XCTAssertEqual(CosmeticSlot.cardFront.displayName, "Card Fronts")
        XCTAssertEqual(CosmeticSlot.table.displayName, "Tables")
        XCTAssertEqual(CosmeticSlot.board.displayName, "Boards")
        XCTAssertEqual(CosmeticSlot.peg.displayName, "Peg Colors")
        XCTAssertEqual(CosmeticSlot.soundPack.displayName, "Sound Packs")
        XCTAssertEqual(CosmeticSlot.hapticPack.displayName, "Haptic Packs")
        XCTAssertEqual(CosmeticSlot.phrasePack.displayName, "Phrase Packs")
        XCTAssertEqual(CosmeticSlot.avatar.displayName, "Avatars")
    }

    func testAllSlotsHaveNonEmptyDisplayName() {
        for slot in CosmeticSlot.allCases {
            XCTAssertFalse(slot.displayName.isEmpty, "\(slot.rawValue) should have a non-empty displayName")
        }
    }
}

// MARK: - CosmeticItem Tests

final class CosmeticItemTests: XCTestCase {

    func testCardBackWrapperProperties() {
        let theme = ClassicNavyBack()
        let item = CardBackCosmeticItem(theme)

        XCTAssertEqual(item.id, "classic-navy")
        XCTAssertEqual(item.slot, .cardBack)
        XCTAssertEqual(item.displayName, "Classic Navy")
        XCTAssertTrue(item.isFree)
        XCTAssertFalse(item.isPremium)
    }

    func testPremiumDetection() {
        let freeItem = CardBackCosmeticItem(ClassicNavyBack())
        let premiumItem = CardBackCosmeticItem(CelticKnotBack())

        XCTAssertTrue(freeItem.isFree)
        XCTAssertFalse(freeItem.isPremium)
        XCTAssertFalse(premiumItem.isFree)
        XCTAssertTrue(premiumItem.isPremium)
    }

    func testTableWrapperProperties() {
        let theme = GreenFeltTable()
        let item = TableCosmeticItem(theme)

        XCTAssertEqual(item.id, "green-felt")
        XCTAssertEqual(item.slot, .table)
        XCTAssertEqual(item.displayName, "Green Felt")
    }

    func testBoardWrapperProperties() {
        let theme = MarbleBoard()
        let item = BoardCosmeticItem(theme)

        XCTAssertEqual(item.id, "marble")
        XCTAssertEqual(item.slot, .board)
        XCTAssertTrue(item.isPremium)
    }
}

// MARK: - CosmeticRegistry Tests

@MainActor
final class CosmeticRegistryTests: XCTestCase {

    private func makeRegistry() -> CosmeticRegistry {
        let registry = CosmeticRegistry.makeForTesting()
        return registry
    }

    func testCatalogPopulated() {
        let registry = makeRegistry()
        // Register built-in themes
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(CardBackCosmeticItem(RoyalRedBack()))
        registry.register(TableCosmeticItem(GreenFeltTable()))
        registry.register(BoardCosmeticItem(ClassicWoodBoard()))

        XCTAssertEqual(registry.items(for: .cardBack).count, 2)
        XCTAssertEqual(registry.items(for: .table).count, 1)
        XCTAssertEqual(registry.items(for: .board).count, 1)
    }

    func testDefaultEquippedID() {
        let registry = makeRegistry()
        XCTAssertEqual(registry.equippedID(for: .cardBack), "classic-navy")
        XCTAssertEqual(registry.equippedID(for: .table), "green-felt")
        XCTAssertEqual(registry.equippedID(for: .board), "classic-wood")
    }

    func testEquipAndRetrieve() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(CardBackCosmeticItem(RoyalRedBack()))
        registry.unlock("royal-red")

        registry.equip("royal-red", in: .cardBack)
        XCTAssertEqual(registry.equippedID(for: .cardBack), "royal-red")
    }

    func testEquipGuardsUnlock() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(CelticKnotBack()))
        // celtic-knot is premium and not unlocked
        registry.equip("celtic-knot", in: .cardBack)
        // Should not have changed from default
        XCTAssertEqual(registry.equippedID(for: .cardBack), "classic-navy")
    }

    func testUnlockAndCheck() {
        let registry = makeRegistry()
        XCTAssertFalse(registry.isUnlocked("celtic-knot"))
        registry.unlock("celtic-knot")
        XCTAssertTrue(registry.isUnlocked("celtic-knot"))
    }

    func testUnlockAllPremiumItems() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(CardBackCosmeticItem(CelticKnotBack()))
        registry.register(TableCosmeticItem(RedVelvetTable()))

        registry.unlockAllPremiumItems()

        XCTAssertTrue(registry.isUnlocked("celtic-knot"))
        XCTAssertTrue(registry.isUnlocked("red-velvet"))
    }

    func testLockPremiumRevertsEquipped() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(CardBackCosmeticItem(CelticKnotBack()))

        registry.unlockAllPremiumItems()
        registry.equip("celtic-knot", in: .cardBack)
        XCTAssertEqual(registry.equippedID(for: .cardBack), "celtic-knot")

        registry.lockPremiumItems()
        // Should revert to default since celtic-knot is now locked
        XCTAssertEqual(registry.equippedID(for: .cardBack), "classic-navy")
    }

    func testTypedThemeAccessors() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(TableCosmeticItem(GreenFeltTable()))
        registry.register(BoardCosmeticItem(ClassicWoodBoard()))
        registry.unlock("classic-navy")
        registry.unlock("green-felt")
        registry.unlock("classic-wood")

        XCTAssertEqual(registry.cardBacks.count, 1)
        XCTAssertEqual(registry.tables.count, 1)
        XCTAssertEqual(registry.boards.count, 1)
        XCTAssertEqual(registry.activeCardBack.id, "classic-navy")
        XCTAssertEqual(registry.activeTable.id, "green-felt")
        XCTAssertEqual(registry.activeBoard.id, "classic-wood")
    }

    func testLegacySelectAliases() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(CardBackCosmeticItem(RoyalRedBack()))
        registry.unlock("royal-red")

        registry.selectCardBack("royal-red")
        XCTAssertEqual(registry.activeCardBackID, "royal-red")
    }

    func testLegacyUnlockAliases() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(CelticKnotBack()))

        registry.unlockAllPremiumThemes()
        XCTAssertTrue(registry.unlockedThemeIDs.contains("celtic-knot"))
        XCTAssertTrue(registry.premiumThemeIDs.contains("celtic-knot"))

        registry.lockPremiumThemes()
        XCTAssertFalse(registry.unlockedThemeIDs.contains("celtic-knot"))
    }

    func testPremiumItemIDs() {
        let registry = makeRegistry()
        registry.register(CardBackCosmeticItem(ClassicNavyBack()))
        registry.register(CardBackCosmeticItem(CelticKnotBack()))
        registry.register(CardBackCosmeticItem(ArtDecoBack()))
        registry.register(TableCosmeticItem(GreenFeltTable()))
        registry.register(TableCosmeticItem(RedVelvetTable()))

        let premiumIDs = registry.premiumItemIDs
        XCTAssertTrue(premiumIDs.contains("celtic-knot"))
        XCTAssertTrue(premiumIDs.contains("art-deco"))
        XCTAssertTrue(premiumIDs.contains("red-velvet"))
        XCTAssertFalse(premiumIDs.contains("classic-navy"))
        XCTAssertFalse(premiumIDs.contains("green-felt"))
    }

    func testEmptySlotReturnsEmpty() {
        let registry = makeRegistry()
        XCTAssertTrue(registry.items(for: .peg).isEmpty)
        XCTAssertTrue(registry.items(for: .soundPack).isEmpty)
        XCTAssertNil(registry.equipped(for: .peg))
    }
}
