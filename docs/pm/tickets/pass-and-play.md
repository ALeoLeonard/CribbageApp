---
id: ticket-pass-and-play
type: ticket
title: Pass-and-Play Local Multiplayer
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-game-rules]
epic: epic-game-rules
estimate: L
priority: p1-high
---

# Pass-and-Play Local Multiplayer

**As a** player sitting with a friend, **I want** to play cribbage on one device by passing it back and forth, **so that** we can play together without needing two phones.

## Acceptance Criteria
- [ ] "Pass & Play" option on main menu alongside "vs Computer"
- [ ] Both players enter their names before the game starts
- [ ] A "hand-over" screen appears between turns: "{Player Name}'s Turn -- Tap to reveal your hand"
- [ ] Current player's hand is hidden until they tap to reveal
- [ ] All game phases work with two human players (no AI involvement)
- [ ] Score counting can be auto or manual (respects muggins setting)
- [ ] Game Over screen shows both player names and final scores
- [ ] Works on both iPhone and iPad

## Technical Notes
- Extend `GameEngine` with a `isPassAndPlay: Bool` mode where both players are human
- Reuse existing `GameViewModel` flow but skip AI action delays
- Create `HandOverView` overlay that blocks view of cards between turns
- The hand-over screen must completely hide the previous player's hand
- iPad landscape is the ideal pass-and-play form factor

## Dependencies
- Blocked by: --
- Blocks: --
