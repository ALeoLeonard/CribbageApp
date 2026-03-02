---
id: epic-progression-unlocks
type: epic
title: Progression & Unlock Engine
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
---

# Progression & Unlock Engine

**Goal**: Create a condition-based unlock system that watches player stats and awards cosmetic items as milestones are hit. Every game — win or lose — moves the player toward something.

**Success criteria**:
- UnlockManager observes StatsManager and fires unlock events when conditions are met
- 20-30 cosmetic items earnable through gameplay at launch
- Celebratory unlock animation + toast notification when items are awarded
- Collection screen showing all items with locked silhouettes and progress indicators
- Premium IAP accelerates unlocks but doesn't gate all content (free players can earn items too)
- Near-miss notifications ("2 more wins to unlock Mahogany Board!")

## Tickets
- [ ] ticket-unlock-engine: UnlockCondition enum, UnlockManager that observes StatsManager
- [ ] ticket-unlock-celebration: Unlock animation, toast notification, queue for simultaneous unlocks
- [ ] ticket-collection-screen: Grid view of all cosmetic items with locked/unlocked/equipped state
- [ ] ticket-unlock-content-design: Define 20-30 items with conditions (which items, which thresholds)
- [ ] ticket-near-miss-prompts: Post-game "X more to unlock Y" nudges
