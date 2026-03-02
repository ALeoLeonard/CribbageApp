---
id: ticket-peg-themes
type: ticket
title: Peg Theme Customization
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
epic: epic-cosmetic-system
estimate: S
priority: p1-high
---

# Peg Theme Customization

**As a** player, **I want** to choose my peg color and style, **so that** my board feels like my own — like the one at grandpa's house.

## Acceptance Criteria
- [ ] `PegTheme` protocol: id, displayName, playerColor, opponentColor, material (gradient/shadow params)
- [ ] 6 built-in peg styles: Classic (blue/red), Brass, Ivory, Ruby, Jade, Obsidian
- [ ] PegTheme conforms to CosmeticItem, registered in CosmeticRegistry (slot: .peg)
- [ ] CribbageBoardView reads active peg theme for peg rendering colors/gradients
- [ ] 2 pegs free (Classic, Brass), 4 earnable/premium
- [ ] Player and opponent pegs use the same theme (simplifies UI; independent selection is future work)

## Technical Notes
- Extend existing CribbageBoardView peg rendering — currently hardcoded blue/red Circle fills
- PegTheme provides Color + gradient + shadow params; rendering code stays in the view
- Small scope: mostly color/gradient parameter changes on existing drawing code

## Dependencies
- Blocked by: ticket-cosmetic-registry
- Blocks: --
