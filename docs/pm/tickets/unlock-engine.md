---
id: ticket-unlock-engine
type: ticket
title: Unlock Condition Engine
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
epic: epic-progression-unlocks
estimate: M
priority: p1-high
---

# Unlock Condition Engine

**As a** player, **I want** to earn cosmetic items by playing the game, **so that** every game feels like progress — even when I lose.

## Acceptance Criteria
- [ ] `UnlockCondition` enum encoding milestone rules:
  - gamesPlayed(Int), winsWithDifficulty(Difficulty, Int), handScore(Int), winStreak(Int)
  - skunkDelivered(Int), mugginsCaught(Int), perfectCount(Int), premium
- [ ] `UnlockManager` observes StatsManager and checks conditions after each game
- [ ] When a condition is met: unlock the associated CosmeticItem in CosmeticRegistry
- [ ] Unlock events fire a notification/callback for UI celebration layer
- [ ] Multiple simultaneous unlocks are queued, not lost
- [ ] Unlocked items persist via CosmeticRegistry (UserDefaults + iCloud sync)
- [ ] Unit tests: condition evaluation against stat snapshots, multi-unlock queuing

## Technical Notes
- UnlockManager.checkUnlocks() called from GameViewModel after game completion
- Each CosmeticItem has an optional UnlockCondition — UnlockManager iterates all locked items and evaluates
- Premium IAP triggers UnlockCondition.premium — instantly unlocks all premium-flagged items
- Keep condition evaluation simple: pure function (StatsManager snapshot) -> [CosmeticItem to unlock]

## Dependencies
- Blocked by: ticket-cosmetic-registry
- Blocks: ticket-unlock-celebration, ticket-collection-screen, ticket-near-miss-prompts
