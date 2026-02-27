---
id: ticket-muggins-rule
type: ticket
title: Optional Muggins Rule
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-game-rules]
epic: epic-game-rules
estimate: M
priority: p1-high
---

# Optional Muggins Rule

**As a** serious cribbage player, **I want** the option to count hands manually with the muggins rule, **so that** the game rewards scoring skill, not just card play.

## Acceptance Criteria
- [ ] "Muggins" toggle in Settings (default: off)
- [ ] When enabled, counting phase shows the hand but NOT the auto-calculated score
- [ ] Player inputs their score claim via a number picker or stepper
- [ ] If player under-counts, opponent (AI) calls "Muggins!" and claims the difference
- [ ] If player over-counts, the correct score is shown and the claim is reduced
- [ ] AI opponent also counts manually (with occasional "mistakes" on Easy/Medium, perfect on Hard)
- [ ] Player can call muggins on AI's under-count
- [ ] Score breakdown shown after muggins resolution

## Technical Notes
- Add `mugginsEnabled: Bool` to @AppStorage settings
- Create a `ManualCountView` that replaces `ScoreBreakdownView` when muggins is on
- AI muggins logic: Easy misses ~30% of points, Medium ~10%, Hard ~0%
- Reuse `Scoring.calculateScore()` as the ground truth for validation

## Dependencies
- Blocked by: --
- Blocks: --
