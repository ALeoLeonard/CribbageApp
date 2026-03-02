---
id: ticket-cosmetic-registry
type: ticket
title: Cosmetic Slot Registry
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
epic: epic-cosmetic-system
estimate: L
priority: p0-critical
---

# Cosmetic Slot Registry

**As a** developer, **I want** a unified registry for all customizable content slots, **so that** adding new cosmetic items requires only a conforming struct — no infrastructure changes.

## Acceptance Criteria
- [ ] `CosmeticSlot` enum defines all customizable categories: cardBack, cardFront, table, board, peg, soundPack, hapticPack, phrasePack, avatar
- [ ] `CosmeticItem` protocol: id, slot, displayName, previewDescription, isPremium, unlockCondition
- [ ] `CosmeticRegistry` manager: items(for:), equipped(for:), equip(_:), unlock(_:), isUnlocked(_:)
- [ ] Persistence: equipped selections and unlocked item IDs saved to UserDefaults, synced via iCloud KVS
- [ ] Existing ThemeManager card backs, tables, and boards migrated into registry as CosmeticItems
- [ ] Existing user theme selections carry over (UserDefaults key compatibility)
- [ ] Registry is @Observable for SwiftUI reactivity
- [ ] Unit tests: equip/unlock/persist round-trip, migration from old ThemeManager keys

## Technical Notes
- CosmeticRegistry wraps (not replaces) existing theme protocols — CardBackTheme, TableTheme, BoardTheme continue to work
- Each slot has a typed accessor (e.g., `activeCardBack: CardBackTheme`) for type-safe usage in views
- Generic `items<T: CosmeticItem>(for slot:) -> [T]` for the picker UI
- UnlockCondition is optional on CosmeticItem — nil means always available or premium-gated

## Dependencies
- Blocked by: --
- Blocks: ticket-phrase-packs, ticket-peg-themes, ticket-sound-packs, ticket-card-front-themes, ticket-cosmetic-picker-ui, ticket-persona-system, ticket-unlock-engine
