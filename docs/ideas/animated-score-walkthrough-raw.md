---
id: idea-animated-score-walkthrough
type: idea
title: "Animated Score Walkthrough During Hand Counting"
status: raw
author: /idea
created: 2026-02-27
updated: 2026-02-27
refs: []
themes: []
scope: "counting-phase-ux"
---

# Animated Score Walkthrough — Raw Capture

## Thought Stream

- During counting phases, walk the player through each scoring combination visually
- Cards are fanned out — lift the specific cards used in each combination up/out of the fan
- Show scoring sequentially: first combo lifts, score appears, cards settle, next combo lifts
- Like a real dealer explaining "these two make fifteen, those three are a run..."
- Teaches new players which cards contribute to which scores
- Makes the counting phase feel active and engaging instead of a static text list
- Could pair with the existing ScoringCalloutView pop animations
- Each step could have a brief pause so the player can follow along

## Initial Observations

- This directly addresses a common complaint with digital cribbage apps — new players see a score number but don't understand *why*
- The engine already returns individual ScoreEvent items with point breakdowns, but doesn't track which specific cards form each combination
- Would need Scoring.calculateScore to return card indices per event, or a parallel calculation
- Pairs naturally with the muggins feature — understanding combos helps players count accurately
- Similar to how chess apps highlight the pieces involved in a tactic
