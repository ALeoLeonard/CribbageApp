---
id: ticket-phrase-packs
type: ticket
title: Phrase Pack System
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
epic: epic-cosmetic-system
estimate: M
priority: p1-high
---

# Phrase Pack System

**As a** player, **I want** custom scoring callout phrases, **so that** the game feels personal and nostalgic — like playing with my family.

## Acceptance Criteria
- [ ] `PhrasePack` protocol with methods returning strings for each scoring event type
- [ ] Event types covered: fifteen, pair, threeOfAKind, fourOfAKind, run, flush, nobs, bigHand (20+), perfect29, go, thirtyOne, lastCard, skunk, doubleSkunk, win, lose, closeGame
- [ ] Each event method returns an array of 3-5 variants; system picks randomly
- [ ] 3 built-in packs:
  - **Classic** (default): Current generic text ("Pair for 2", "Fifteen for 2")
  - **Grandpa**: "Fifteen-two, fifteen-four!", "That's better than a kick in the head!", "You got skunked, kiddo!"
  - **Trash Talk**: "Is that all you've got?", "Read 'em and weep!", "Better luck next century!"
- [ ] PhrasePack conforms to CosmeticItem and registers in CosmeticRegistry (slot: .phrasePack)
- [ ] ScoringCalloutView reads active phrase pack for callout text
- [ ] Grandpa pack is free; Trash Talk is earnable via unlock condition
- [ ] AI opponents can optionally use phrase packs (Easy=polite, Hard=competitive)

## Technical Notes
- Hook into existing ScoringCallout pipeline — replace hardcoded reason strings with phrase pack lookups
- GameViewModel maps ScoreEvent.reason to PhrasePack event type
- Consider: phrase packs could also supply emoji or color accent per event type (future extension)

## Dependencies
- Blocked by: ticket-cosmetic-registry
- Blocks: ticket-persona-system
