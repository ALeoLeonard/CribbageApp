---
id: ticket-first-launch-tutorial
type: ticket
title: Interactive First-Launch Tutorial
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-tutorial]
epic: epic-tutorial
estimate: L
priority: p0-critical
---

# Interactive First-Launch Tutorial

**As a** new cribbage player, **I want** a guided walkthrough of my first game, **so that** I understand the game phases without reading a manual.

## Acceptance Criteria
- [ ] Tutorial triggers automatically on first app launch (tracked via @AppStorage)
- [ ] Tutorial overlays tooltips on the real game board (not a separate screen)
- [ ] Covers all 4 phases: discard (explain crib), play (explain pegging), count (explain scoring), and rotation
- [ ] Each tooltip has a "Next" / "Got it" dismiss button
- [ ] Tutorial uses a scripted hand (fixed deal) for consistent teaching experience
- [ ] Tutorial completable in under 3 minutes
- [ ] "Skip tutorial" option available at any point
- [ ] Tutorial re-accessible from Settings > "Replay Tutorial"

## Technical Notes
- Use a `TutorialOverlayView` that wraps `GameBoardView` with positioned tooltips
- Use `GameEngine` with a seeded deck for predictable hands
- Store completion state in @AppStorage("hasCompletedTutorial")
- Consider using `.matchedGeometryEffect` to point tooltips at specific UI elements

## Dependencies
- Blocked by: --
- Blocks: --
