---
id: epic-cosmetic-system
type: epic
title: Cosmetic System & Deep Customization
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
---

# Cosmetic System & Deep Customization

**Goal**: Build a protocol-based cosmetic registry that unifies all customizable slots (card fronts, backs, boards, pegs, sounds, haptics, phrases) into one extensible system. Adding new content = adding a struct, not changing infrastructure.

**Success criteria**:
- CosmeticRegistry manages all customizable slots with equip/unlock/persist semantics
- Existing ThemeManager (card backs, tables, boards) migrated into the registry without breaking current users
- At least 2 new content categories shipped (phrase packs, peg themes)
- New content can be added by creating a single struct conforming to a protocol — no infrastructure changes
- Selection UI is generic and works for any slot type
- iCloud sync covers equipped cosmetics

## Tickets
- [ ] ticket-cosmetic-registry: CosmeticSlot enum, CosmeticItem protocol, CosmeticRegistry manager
- [ ] ticket-phrase-packs: PhrasePack protocol + 3 built-in packs (Classic, Grandpa, Trash Talk)
- [ ] ticket-peg-themes: PegTheme protocol + 6 peg styles, extend CribbageBoardView
- [ ] ticket-sound-packs: SoundPack protocol, refactor SoundManager to dispatch, 2 packs
- [ ] ticket-haptic-packs: HapticPack protocol, refactor HapticManager, bundle with sound packs
- [ ] ticket-card-front-themes: CardFrontTheme protocol, parameterized rendering, 3 styles
- [ ] ticket-cosmetic-picker-ui: Generic picker view that works for any CosmeticSlot
- [ ] ticket-persona-system: Persona struct bundling name, avatar, phrase pack, cosmetic loadout
