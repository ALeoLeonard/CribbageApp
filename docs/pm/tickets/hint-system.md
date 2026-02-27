---
id: ticket-hint-system
type: ticket
title: In-Game Hint System
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-tutorial]
epic: epic-tutorial
estimate: M
priority: p1-high
---

# In-Game Hint System

**As a** learning player, **I want** optional hints during my turn, **so that** I can improve my discard and play strategy.

## Acceptance Criteria
- [ ] "Hint" button appears in ActionBarView during discard and play phases
- [ ] Hint is toggleable in Settings (default: on for Easy, off for Medium/Hard)
- [ ] During discard: highlights the optimal 2 cards to discard with brief explanation
- [ ] During play: highlights the optimal card to play with brief explanation
- [ ] Hint uses HardAI's evaluation logic to determine optimal play
- [ ] Hint appears as a subtle overlay/tooltip, not disruptive
- [ ] Hint does not auto-play -- player must still tap to act

## Technical Notes
- Reuse `HardAI.chooseDiscards()` and `HardAI.choosePlay()` to power hints
- Add `hintsEnabled: Bool` to @AppStorage
- Add a `getHint()` method to GameViewModel that returns recommended indices + reason
- Display as a pulsing highlight on recommended cards with a short text label

## Dependencies
- Blocked by: --
- Blocks: --
