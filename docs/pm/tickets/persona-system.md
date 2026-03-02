---
id: ticket-persona-system
type: ticket
title: Player Persona System
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
epic: epic-cosmetic-system
estimate: M
priority: p2-medium
---

# Player Persona System

**As a** player, **I want** a cribbage identity that bundles my name, avatar, and cosmetic choices, **so that** the game feels like mine and I'm invested in my character.

## Acceptance Criteria
- [ ] `Persona` struct: displayName, avatarID (SF Symbol or unlockable illustration), equipped phrasePack, cosmetic loadout summary
- [ ] Persona displayed on: game board score bar, pass-and-play hand-over screen, Game Center profile
- [ ] Avatar selection UI with 8-10 SF Symbol options (free) + 4-6 illustrated avatars (earnable/premium)
- [ ] Persona persists via UserDefaults, syncs via iCloud KVS
- [ ] AI opponents have their own personas: Easy AI = friendly avatar + polite phrases, Hard AI = serious avatar + competitive phrases
- [ ] Persona shown on share cards when sharing game results

## Technical Notes
- Extends current `playerName` AppStorage into a richer Persona model
- AI personas are static/hardcoded — no customization needed for opponents initially
- Avatar rendering: SF Symbol in a styled circle badge, or Image for illustrated avatars
- Loadout summary is derived from CosmeticRegistry equipped items — not duplicated

## Dependencies
- Blocked by: ticket-cosmetic-registry, ticket-phrase-packs
- Blocks: --
