---
id: ticket-skunk-tracking
type: ticket
title: Skunk & Double-Skunk Tracking
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-game-rules]
epic: epic-game-rules
estimate: S
priority: p1-high
---

# Skunk & Double-Skunk Tracking

**As a** cribbage player, **I want** skunks and double-skunks tracked and displayed, **so that** I can see dominant victories in my stats.

## Acceptance Criteria
- [ ] Skunk detected when winner reaches 121 and loser has < 91 points
- [ ] Double-skunk detected when winner reaches 121 and loser has < 61 points
- [ ] Game Over screen shows "Skunk!" or "Double Skunk!" badge when applicable
- [ ] StatsManager tracks total skunks given and received per difficulty
- [ ] Stats view displays skunk counts
- [ ] Cribbage board visual shows the skunk line at position 91 and 61

## Technical Notes
- Add `skunksGiven`, `skunksReceived`, `doubleSkunksGiven`, `doubleSkunksReceived` to StatsManager
- Add skunk detection in GameEngine.checkForWinner() or GameOverView
- Draw subtle markers on CribbageBoardView at positions 61 and 91

## Dependencies
- Blocked by: --
- Blocks: ticket-achievements (some achievements reference skunks)
