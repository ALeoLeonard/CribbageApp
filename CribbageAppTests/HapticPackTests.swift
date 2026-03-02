@testable import CribbageApp
import XCTest

// MARK: - Haptic Pack Property Tests

final class HapticPackPropertyTests: XCTestCase {

    func testStandardHapticPackProperties() {
        let pack = StandardHapticPack()
        XCTAssertEqual(pack.id, "standard-haptics")
        XCTAssertEqual(pack.displayName, "Standard")
    }

    func testIntenseHapticPackProperties() {
        let pack = IntenseHapticPack()
        XCTAssertEqual(pack.id, "intense-haptics")
        XCTAssertEqual(pack.displayName, "Intense")
    }

    func testSubtleHapticPackProperties() {
        let pack = SubtleHapticPack()
        XCTAssertEqual(pack.id, "subtle-haptics")
        XCTAssertEqual(pack.displayName, "Subtle")
    }

    func testAllPacksHaveUniqueIDs() {
        let packs: [any HapticPack] = [
            StandardHapticPack(), IntenseHapticPack(), SubtleHapticPack()
        ]
        let ids = packs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }
}

// MARK: - HapticPackCosmeticItem Tests

final class HapticPackCosmeticItemTests: XCTestCase {

    func testWrapperProperties() {
        let pack = StandardHapticPack()
        let item = HapticPackCosmeticItem(pack)

        XCTAssertEqual(item.id, "standard-haptics")
        XCTAssertEqual(item.slot, .hapticPack)
        XCTAssertEqual(item.displayName, "Standard")
        XCTAssertEqual(item.previewDescription, "Standard haptic style")
        XCTAssertTrue(item.isFree)
    }

    func testPremiumUnlockCondition() {
        let pack = IntenseHapticPack()
        let item = HapticPackCosmeticItem(pack, unlockCondition: .premium)

        XCTAssertEqual(item.unlockCondition, .premium)
        XCTAssertTrue(item.isPremium)
        XCTAssertFalse(item.isFree)
    }

    func testPackAccessor() {
        let pack = IntenseHapticPack()
        let item = HapticPackCosmeticItem(pack)

        XCTAssertEqual(item.pack.id, "intense-haptics")
        XCTAssertEqual(item.pack.displayName, "Intense")
    }

    func testUnlockConditions() {
        let items: [(any HapticPack, UnlockCondition)] = [
            (StandardHapticPack(), .free),
            (SubtleHapticPack(), .free),
            (IntenseHapticPack(), .premium)
        ]

        let freeCount = items.filter { $0.1 == .free }.count
        let premiumCount = items.filter { $0.1 == .premium }.count
        XCTAssertEqual(freeCount, 2)
        XCTAssertEqual(premiumCount, 1)
    }
}

// MARK: - Haptic Pack Registry Integration Tests

@MainActor
final class HapticPackRegistryTests: XCTestCase {

    private func makeRegistry() -> CosmeticRegistry {
        let registry = CosmeticRegistry.makeForTesting()
        registry.register(HapticPackCosmeticItem(StandardHapticPack()))
        registry.register(HapticPackCosmeticItem(SubtleHapticPack()))
        registry.register(HapticPackCosmeticItem(IntenseHapticPack(), unlockCondition: .premium))
        return registry
    }

    func testHapticPacksRegisteredInCatalog() {
        let registry = makeRegistry()
        let items = registry.items(for: .hapticPack)
        XCTAssertEqual(items.count, 3)
    }

    func testDefaultIsStandard() {
        let registry = makeRegistry()
        XCTAssertEqual(registry.equippedID(for: .hapticPack), "standard-haptics")
    }

    func testEquipAndRetrieve() {
        let registry = makeRegistry()
        registry.unlock("subtle-haptics")
        registry.equip("subtle-haptics", in: .hapticPack)

        XCTAssertEqual(registry.equippedID(for: .hapticPack), "subtle-haptics")
        let equipped = registry.equipped(for: .hapticPack) as? HapticPackCosmeticItem
        XCTAssertNotNil(equipped)
        XCTAssertEqual(equipped?.pack.id, "subtle-haptics")
    }

    func testActiveHapticPackAccessor() {
        let registry = makeRegistry()
        registry.unlock("standard-haptics")
        registry.equip("standard-haptics", in: .hapticPack)

        let active = registry.activeHapticPack
        XCTAssertEqual(active.id, "standard-haptics")
    }

    func testActiveHapticPackFallsBackToStandard() {
        let registry = CosmeticRegistry.makeForTesting()
        // No packs registered — should fall back to StandardHapticPack
        let active = registry.activeHapticPack
        XCTAssertEqual(active.id, "standard-haptics")
    }

    func testLockedPackCannotBeEquipped() {
        let registry = makeRegistry()
        // intense-haptics is premium, not unlocked
        registry.equip("intense-haptics", in: .hapticPack)
        XCTAssertEqual(registry.equippedID(for: .hapticPack), "standard-haptics")
    }

    func testEquipSubtleAndVerifyAccessor() {
        let registry = makeRegistry()
        registry.unlock("subtle-haptics")
        registry.equip("subtle-haptics", in: .hapticPack)

        let active = registry.activeHapticPack
        XCTAssertEqual(active.id, "subtle-haptics")
        XCTAssertEqual(active.displayName, "Subtle")
    }
}
