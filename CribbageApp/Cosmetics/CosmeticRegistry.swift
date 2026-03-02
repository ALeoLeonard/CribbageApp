import SwiftUI

// MARK: - Cosmetic Registry

@MainActor @Observable
final class CosmeticRegistry {
    static let shared = CosmeticRegistry()

    // MARK: - Generalized State

    /// All registered cosmetic items, grouped by slot.
    private(set) var catalog: [CosmeticSlot: [any CosmeticItem]] = [:]

    /// Whether this instance is a lightweight test double (skips UserDefaults + analytics).
    private let isTestInstance: Bool

    /// IDs the player has unlocked (free items + purchased/earned).
    var unlockedItemIDs: Set<String> {
        didSet {
            guard !isTestInstance else { return }
            UserDefaults.standard.set(Array(unlockedItemIDs), forKey: "unlockedThemes")
        }
    }

    /// Currently equipped item ID per slot.
    private var equippedIDs: [CosmeticSlot: String] = [:]

    // MARK: - Generalized API

    /// All items registered for a given slot.
    func items(for slot: CosmeticSlot) -> [any CosmeticItem] {
        catalog[slot] ?? []
    }

    /// The equipped item ID for a slot, falling back to the slot's default.
    func equippedID(for slot: CosmeticSlot) -> String {
        equippedIDs[slot] ?? slot.defaultItemID
    }

    /// The equipped item for a slot, or nil if not found in catalog.
    func equipped(for slot: CosmeticSlot) -> (any CosmeticItem)? {
        let id = equippedID(for: slot)
        return items(for: slot).first { $0.id == id }
    }

    /// Equip an item in its slot. Guards unlock state, persists, and tracks analytics.
    func equip(_ itemID: String, in slot: CosmeticSlot) {
        guard isUnlocked(itemID) else { return }
        equippedIDs[slot] = itemID
        guard !isTestInstance else { return }
        UserDefaults.standard.set(itemID, forKey: slot.equippedKey)
        AnalyticsManager.shared.trackThemeChanged(themeID: itemID, category: slot.rawValue)
    }

    /// Whether an item ID is unlocked.
    func isUnlocked(_ itemID: String) -> Bool {
        unlockedItemIDs.contains(itemID)
    }

    /// Unlock a specific item by ID.
    func unlock(_ itemID: String) {
        unlockedItemIDs.insert(itemID)
    }

    /// IDs of all premium items across all slots.
    var premiumItemIDs: Set<String> {
        var ids = Set<String>()
        for items in catalog.values {
            for item in items where item.isPremium {
                ids.insert(item.id)
            }
        }
        return ids
    }

    /// Unlock all premium items.
    func unlockAllPremiumItems() {
        unlockedItemIDs = unlockedItemIDs.union(premiumItemIDs)
    }

    /// Lock all premium items, reverting equipped slots to defaults if needed.
    func lockPremiumItems() {
        unlockedItemIDs = unlockedItemIDs.subtracting(premiumItemIDs)
        for slot in CosmeticSlot.allCases {
            let currentID = equippedID(for: slot)
            if !isUnlocked(currentID) {
                equippedIDs[slot] = slot.defaultItemID
                if !isTestInstance {
                    UserDefaults.standard.set(slot.defaultItemID, forKey: slot.equippedKey)
                }
            }
        }
    }

    // MARK: - Legacy ThemeManager API

    var activeCardBackID: String {
        get { equippedID(for: .cardBack) }
        set { equip(newValue, in: .cardBack) }
    }

    var activeTableID: String {
        get { equippedID(for: .table) }
        set { equip(newValue, in: .table) }
    }

    var activeBoardID: String {
        get { equippedID(for: .board) }
        set { equip(newValue, in: .board) }
    }

    var cardBacks: [any CardBackTheme] {
        items(for: .cardBack).compactMap { ($0 as? CardBackCosmeticItem)?.theme }
    }

    var tables: [any TableTheme] {
        items(for: .table).compactMap { ($0 as? TableCosmeticItem)?.theme }
    }

    var boards: [any BoardTheme] {
        items(for: .board).compactMap { ($0 as? BoardCosmeticItem)?.theme }
    }

    var activeCardBack: any CardBackTheme {
        cardBacks.first { $0.id == activeCardBackID } ?? cardBacks[0]
    }

    var activeTable: any TableTheme {
        tables.first { $0.id == activeTableID } ?? tables[0]
    }

    var activeBoard: any BoardTheme {
        boards.first { $0.id == activeBoardID } ?? boards[0]
    }

    var activePhrasePack: any PhrasePack {
        (equipped(for: .phrasePack) as? PhrasePackCosmeticItem)?.pack
            ?? ClassicPhrasePack()
    }

    var activePegTheme: any PegTheme {
        (equipped(for: .peg) as? PegThemeCosmeticItem)?.theme
            ?? ClassicPeg()
    }

    var activeSoundPack: any SoundPack {
        (equipped(for: .soundPack) as? SoundPackCosmeticItem)?.pack
            ?? ClassicSoundPack()
    }

    func selectCardBack(_ id: String) {
        equip(id, in: .cardBack)
    }

    func selectTable(_ id: String) {
        equip(id, in: .table)
    }

    func selectBoard(_ id: String) {
        equip(id, in: .board)
    }

    func unlockAllPremiumThemes() {
        unlockAllPremiumItems()
    }

    func lockPremiumThemes() {
        lockPremiumItems()
    }

    /// Alias for backward compatibility with CloudSyncManager.
    var unlockedThemeIDs: Set<String> {
        get { unlockedItemIDs }
        set { unlockedItemIDs = newValue }
    }

    /// Alias for backward compatibility.
    var premiumThemeIDs: Set<String> {
        premiumItemIDs
    }

    // MARK: - Registration

    /// Register a cosmetic item into the catalog.
    func register(_ item: any CosmeticItem) {
        catalog[item.slot, default: []].append(item)
    }

    /// Populate catalog with the 13 built-in theme items.
    private func registerBuiltInItems() {
        // Card backs
        let cardBackThemes: [any CardBackTheme] = [
            ClassicNavyBack(), RoyalRedBack(), EmeraldBack(), CelticKnotBack(), ArtDecoBack()
        ]
        for theme in cardBackThemes {
            register(CardBackCosmeticItem(theme))
        }

        // Tables
        let tableThemes: [any TableTheme] = [
            GreenFeltTable(), BlueFeltTable(), RedVelvetTable(), MahoganyTable()
        ]
        for theme in tableThemes {
            register(TableCosmeticItem(theme))
        }

        // Boards
        let boardThemes: [any BoardTheme] = [
            ClassicWoodBoard(), DarkWalnutBoard(), MarbleBoard(), GoldInlayBoard()
        ]
        for theme in boardThemes {
            register(BoardCosmeticItem(theme))
        }

        // Phrase packs
        let phrasePacks: [(any PhrasePack, UnlockCondition)] = [
            (ClassicPhrasePack(), .free),
            (GrandpaPhrasePack(), .free),
            (TrashTalkPhrasePack(), .achievement("firstwin"))
        ]
        for (pack, condition) in phrasePacks {
            register(PhrasePackCosmeticItem(pack, unlockCondition: condition))
        }

        // Peg themes
        let pegThemes: [(any PegTheme, UnlockCondition)] = [
            (ClassicPeg(), .free),
            (BrassPeg(), .free),
            (IvoryPeg(), .premium),
            (RubyPeg(), .premium),
            (JadePeg(), .premium),
            (ObsidianPeg(), .premium)
        ]
        for (theme, condition) in pegThemes {
            register(PegThemeCosmeticItem(theme, unlockCondition: condition))
        }

        // Sound packs
        let soundPacks: [(any SoundPack, UnlockCondition)] = [
            (ClassicSoundPack(), .free),
            (QuietEveningSoundPack(), .premium)
        ]
        for (pack, condition) in soundPacks {
            register(SoundPackCosmeticItem(pack, unlockCondition: condition))
        }
    }

    // MARK: - Init

    private init() {
        self.isTestInstance = false
        // Free theme IDs (same set as original ThemeManager)
        let freeIDs: Set<String> = [
            "classic-navy", "royal-red", "emerald",
            "green-felt", "blue-felt",
            "classic-wood", "dark-walnut",
            "classic-phrases", "grandpa-phrases",
            "classic-peg", "brass-peg",
            "classic-sounds"
        ]

        let saved = Set(UserDefaults.standard.stringArray(forKey: "unlockedThemes") ?? [])
        self.unlockedItemIDs = freeIDs.union(saved)

        // Load equipped IDs from UserDefaults per slot
        for slot in CosmeticSlot.allCases {
            if let savedID = UserDefaults.standard.string(forKey: slot.equippedKey) {
                equippedIDs[slot] = savedID
            }
        }

        registerBuiltInItems()
    }

    // MARK: - Testing Support

    /// Creates an empty registry for unit testing (no UserDefaults, no built-in items).
    static func makeForTesting() -> CosmeticRegistry {
        let registry = CosmeticRegistry(forTesting: true)
        return registry
    }

    private init(forTesting: Bool) {
        self.isTestInstance = true
        self.unlockedItemIDs = []
    }
}
