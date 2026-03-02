@testable import CribbageApp
import XCTest

// MARK: - Sound Pack Property Tests

final class SoundPackPropertyTests: XCTestCase {

    func testClassicSoundPackProperties() {
        let pack = ClassicSoundPack()
        XCTAssertEqual(pack.id, "classic-sounds")
        XCTAssertEqual(pack.displayName, "Classic")
    }

    func testQuietEveningSoundPackProperties() {
        let pack = QuietEveningSoundPack()
        XCTAssertEqual(pack.id, "quiet-evening")
        XCTAssertEqual(pack.displayName, "Quiet Evening")
    }

    func testAllPacksHaveUniqueIDs() {
        let packs: [any SoundPack] = [
            ClassicSoundPack(), QuietEveningSoundPack()
        ]
        let ids = packs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }
}

// MARK: - SoundPackCosmeticItem Tests

final class SoundPackCosmeticItemTests: XCTestCase {

    func testWrapperProperties() {
        let pack = ClassicSoundPack()
        let item = SoundPackCosmeticItem(pack)

        XCTAssertEqual(item.id, "classic-sounds")
        XCTAssertEqual(item.slot, .soundPack)
        XCTAssertEqual(item.displayName, "Classic")
        XCTAssertEqual(item.previewDescription, "Classic sound style")
        XCTAssertTrue(item.isFree)
    }

    func testPremiumUnlockCondition() {
        let pack = QuietEveningSoundPack()
        let item = SoundPackCosmeticItem(pack, unlockCondition: .premium)

        XCTAssertEqual(item.unlockCondition, .premium)
        XCTAssertTrue(item.isPremium)
        XCTAssertFalse(item.isFree)
    }

    func testPackAccessor() {
        let pack = QuietEveningSoundPack()
        let item = SoundPackCosmeticItem(pack)

        XCTAssertEqual(item.pack.id, "quiet-evening")
        XCTAssertEqual(item.pack.displayName, "Quiet Evening")
    }

    func testUnlockConditions() {
        let items: [(any SoundPack, UnlockCondition)] = [
            (ClassicSoundPack(), .free),
            (QuietEveningSoundPack(), .premium)
        ]

        let freeCount = items.filter { $0.1 == .free }.count
        let premiumCount = items.filter { $0.1 == .premium }.count
        XCTAssertEqual(freeCount, 1)
        XCTAssertEqual(premiumCount, 1)
    }
}

// MARK: - Sound Pack Registry Integration Tests

@MainActor
final class SoundPackRegistryTests: XCTestCase {

    private func makeRegistry() -> CosmeticRegistry {
        let registry = CosmeticRegistry.makeForTesting()
        registry.register(SoundPackCosmeticItem(ClassicSoundPack()))
        registry.register(SoundPackCosmeticItem(QuietEveningSoundPack(), unlockCondition: .premium))
        return registry
    }

    func testSoundPacksRegisteredInCatalog() {
        let registry = makeRegistry()
        let items = registry.items(for: .soundPack)
        XCTAssertEqual(items.count, 2)
    }

    func testDefaultIsClassic() {
        let registry = makeRegistry()
        XCTAssertEqual(registry.equippedID(for: .soundPack), "classic-sounds")
    }

    func testEquipAndRetrieve() {
        let registry = makeRegistry()
        registry.unlock("quiet-evening")
        registry.equip("quiet-evening", in: .soundPack)

        XCTAssertEqual(registry.equippedID(for: .soundPack), "quiet-evening")
        let equipped = registry.equipped(for: .soundPack) as? SoundPackCosmeticItem
        XCTAssertNotNil(equipped)
        XCTAssertEqual(equipped?.pack.id, "quiet-evening")
    }

    func testActiveSoundPackAccessor() {
        let registry = makeRegistry()
        registry.unlock("classic-sounds")
        registry.equip("classic-sounds", in: .soundPack)

        let active = registry.activeSoundPack
        XCTAssertEqual(active.id, "classic-sounds")
    }

    func testActiveSoundPackFallsBackToClassic() {
        let registry = CosmeticRegistry.makeForTesting()
        // No packs registered — should fall back to ClassicSoundPack
        let active = registry.activeSoundPack
        XCTAssertEqual(active.id, "classic-sounds")
    }

    func testLockedPackCannotBeEquipped() {
        let registry = makeRegistry()
        // quiet-evening is premium, not unlocked
        registry.equip("quiet-evening", in: .soundPack)
        XCTAssertEqual(registry.equippedID(for: .soundPack), "classic-sounds")
    }

    func testEquipQuietEveningAndVerifyAccessor() {
        let registry = makeRegistry()
        registry.unlock("quiet-evening")
        registry.equip("quiet-evening", in: .soundPack)

        let active = registry.activeSoundPack
        XCTAssertEqual(active.id, "quiet-evening")
        XCTAssertEqual(active.displayName, "Quiet Evening")
    }
}
