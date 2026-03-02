@testable import CribbageApp
import XCTest

// MARK: - PhraseEventType Tests

final class PhraseEventTypeTests: XCTestCase {

    func testAllEventTypesExist() {
        let allCases = PhraseEventType.allCases
        XCTAssertEqual(allCases.count, 18)
    }

    func testNoDuplicateRawValues() {
        let rawValues = PhraseEventType.allCases.map(\.rawValue)
        XCTAssertEqual(rawValues.count, Set(rawValues).count)
    }
}

// MARK: - Classic Phrase Pack Tests

final class ClassicPhrasePackTests: XCTestCase {

    let pack = ClassicPhrasePack()

    func testEveryEventHasPhrases() {
        for event in PhraseEventType.allCases {
            let phrases = pack.phrases(for: event)
            XCTAssertFalse(phrases.isEmpty, "Classic pack missing phrases for \(event)")
        }
    }

    func testFifteenInterpolatesPoints() {
        let result = pack.randomPhrase(for: .fifteen, points: 2)
        XCTAssertEqual(result, "15 for 2!")
    }

    func testRunInterpolatesPoints() {
        let result = pack.randomPhrase(for: .run, points: 3)
        XCTAssertEqual(result, "Run of 3!")
    }

    func testStaticPhrasesMatchOriginal() {
        XCTAssertEqual(pack.randomPhrase(for: .pair), "Pair!")
        XCTAssertEqual(pack.randomPhrase(for: .threeOfAKind), "Three of a Kind!")
        XCTAssertEqual(pack.randomPhrase(for: .fourOfAKind), "Four of a Kind!")
        XCTAssertEqual(pack.randomPhrase(for: .thirtyOne), "31 for 2!")
        XCTAssertEqual(pack.randomPhrase(for: .go), "Go!")
        XCTAssertEqual(pack.randomPhrase(for: .hisHeels), "His Heels!")
        XCTAssertEqual(pack.randomPhrase(for: .nobs), "His Nobs!")
        XCTAssertEqual(pack.randomPhrase(for: .flush), "Flush!")
        XCTAssertEqual(pack.randomPhrase(for: .win), "You Win!")
        XCTAssertEqual(pack.randomPhrase(for: .lose), "You Lose")
    }

    func testPackID() {
        XCTAssertEqual(pack.id, "classic-phrases")
        XCTAssertEqual(pack.displayName, "Classic")
    }
}

// MARK: - Grandpa Phrase Pack Tests

final class GrandpaPhrasePackTests: XCTestCase {

    let pack = GrandpaPhrasePack()

    func testEveryEventHasPhrases() {
        for event in PhraseEventType.allCases {
            let phrases = pack.phrases(for: event)
            XCTAssertFalse(phrases.isEmpty, "Grandpa pack missing phrases for \(event)")
        }
    }

    func testMultipleVariantsPerEvent() {
        for event in PhraseEventType.allCases {
            let phrases = pack.phrases(for: event)
            XCTAssertGreaterThanOrEqual(phrases.count, 2, "Grandpa pack should have multiple variants for \(event)")
        }
    }

    func testDiffersFromClassic() {
        let classic = ClassicPhrasePack()
        var diffCount = 0
        for event in PhraseEventType.allCases {
            if pack.phrases(for: event) != classic.phrases(for: event) {
                diffCount += 1
            }
        }
        XCTAssertEqual(diffCount, PhraseEventType.allCases.count, "Grandpa should differ from Classic for all events")
    }

    func testPackID() {
        XCTAssertEqual(pack.id, "grandpa-phrases")
        XCTAssertEqual(pack.displayName, "Grandpa")
    }
}

// MARK: - Trash Talk Phrase Pack Tests

final class TrashTalkPhrasePackTests: XCTestCase {

    let pack = TrashTalkPhrasePack()

    func testEveryEventHasPhrases() {
        for event in PhraseEventType.allCases {
            let phrases = pack.phrases(for: event)
            XCTAssertFalse(phrases.isEmpty, "Trash Talk pack missing phrases for \(event)")
        }
    }

    func testMultipleVariantsPerEvent() {
        for event in PhraseEventType.allCases {
            let phrases = pack.phrases(for: event)
            XCTAssertGreaterThanOrEqual(phrases.count, 2, "Trash Talk pack should have multiple variants for \(event)")
        }
    }

    func testPackID() {
        XCTAssertEqual(pack.id, "trash-talk-phrases")
        XCTAssertEqual(pack.displayName, "Trash Talk")
    }
}

// MARK: - PhrasePackCosmeticItem Tests

final class PhrasePackCosmeticItemTests: XCTestCase {

    func testWrapperProperties() {
        let pack = ClassicPhrasePack()
        let item = PhrasePackCosmeticItem(pack)

        XCTAssertEqual(item.id, "classic-phrases")
        XCTAssertEqual(item.slot, .phrasePack)
        XCTAssertEqual(item.displayName, "Classic")
        XCTAssertEqual(item.previewDescription, "Classic phrase pack")
        XCTAssertTrue(item.isFree)
    }

    func testAchievementUnlockCondition() {
        let pack = TrashTalkPhrasePack()
        let item = PhrasePackCosmeticItem(pack, unlockCondition: .achievement("firstwin"))

        XCTAssertEqual(item.unlockCondition, .achievement("firstwin"))
        XCTAssertFalse(item.isFree)
        XCTAssertFalse(item.isPremium)
    }

    func testPackAccessor() {
        let pack = GrandpaPhrasePack()
        let item = PhrasePackCosmeticItem(pack)

        XCTAssertEqual(item.pack.id, "grandpa-phrases")
        XCTAssertFalse(item.pack.phrases(for: .fifteen).isEmpty)
    }
}

// MARK: - Phrase Pack Registry Integration Tests

@MainActor
final class PhrasePackRegistryTests: XCTestCase {

    private func makeRegistry() -> CosmeticRegistry {
        let registry = CosmeticRegistry.makeForTesting()
        registry.register(PhrasePackCosmeticItem(ClassicPhrasePack()))
        registry.register(PhrasePackCosmeticItem(GrandpaPhrasePack()))
        registry.register(PhrasePackCosmeticItem(TrashTalkPhrasePack(), unlockCondition: .achievement("firstwin")))
        return registry
    }

    func testPacksRegisteredInCatalog() {
        let registry = makeRegistry()
        let items = registry.items(for: .phrasePack)
        XCTAssertEqual(items.count, 3)
    }

    func testDefaultIsClassic() {
        let registry = makeRegistry()
        XCTAssertEqual(registry.equippedID(for: .phrasePack), "classic-phrases")
    }

    func testEquipAndRetrieve() {
        let registry = makeRegistry()
        registry.unlock("grandpa-phrases")
        registry.equip("grandpa-phrases", in: .phrasePack)

        XCTAssertEqual(registry.equippedID(for: .phrasePack), "grandpa-phrases")
        let equipped = registry.equipped(for: .phrasePack) as? PhrasePackCosmeticItem
        XCTAssertNotNil(equipped)
        XCTAssertEqual(equipped?.pack.id, "grandpa-phrases")
    }

    func testActivePhrasePackAccessor() {
        let registry = makeRegistry()
        registry.unlock("classic-phrases")
        registry.equip("classic-phrases", in: .phrasePack)

        let activePack = registry.activePhrasePack
        XCTAssertEqual(activePack.id, "classic-phrases")
    }

    func testActivePhrasePackFallsBackToClassic() {
        let registry = CosmeticRegistry.makeForTesting()
        // No packs registered — should fall back to ClassicPhrasePack
        let activePack = registry.activePhrasePack
        XCTAssertEqual(activePack.id, "classic-phrases")
    }

    func testLockedPackCannotBeEquipped() {
        let registry = makeRegistry()
        // trash-talk-phrases requires achievement, not unlocked
        registry.equip("trash-talk-phrases", in: .phrasePack)
        XCTAssertEqual(registry.equippedID(for: .phrasePack), "classic-phrases")
    }
}
