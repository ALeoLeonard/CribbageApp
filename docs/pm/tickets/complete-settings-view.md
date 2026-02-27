---
id: ticket-complete-settings-view
type: ticket
title: Wire Up Full Settings View
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-app-polish]
epic: epic-app-polish
estimate: M
priority: p1-high
---

# Wire Up Full Settings View

**As a** player, **I want** a complete settings screen, **so that** I can configure sound, haptics, rules, and preferences.

## Acceptance Criteria
- [ ] Sound toggle (wired to SoundManager.soundEnabled)
- [ ] Haptics toggle (wired to HapticManager)
- [ ] Card sort preference (by rank / by suit)
- [ ] Muggins rule toggle
- [ ] "Replay Tutorial" button
- [ ] "About" section with app version and credits
- [ ] "Rate App" link to App Store
- [ ] "Privacy Policy" link
- [ ] "Restore Purchases" button (wired when monetization exists)
- [ ] All toggles persist via @AppStorage

## Technical Notes
- Existing SettingsView.swift has basic structure -- expand it
- Group into sections: Gameplay, Audio & Feedback, Rules, Support
- Use native SwiftUI Toggle and Form components

## Dependencies
- Blocked by: --
- Blocks: ticket-wire-theme-picker, ticket-customizable-rules
