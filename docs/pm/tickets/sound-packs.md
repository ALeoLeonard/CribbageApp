---
id: ticket-sound-packs
type: ticket
title: Sound Pack System
status: draft
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion]
epic: epic-cosmetic-system
estimate: M
priority: p2-medium
---

# Sound Pack System

**As a** player, **I want** different sound themes, **so that** the game's audio matches my mood — crisp and classic, or warm and jazzy.

## Acceptance Criteria
- [ ] `SoundPack` protocol mirroring current SoundManager methods (playCardSlide, playScore, playShuffle, etc.)
- [ ] SoundManager refactored to delegate to equipped SoundPack instead of hardcoded synthesis
- [ ] 2 built-in packs:
  - **Classic** (default): Current synthesized sounds extracted into a pack
  - **Quiet Evening**: Softer card whispers, gentle bell tones, minimal fanfare
- [ ] SoundPack conforms to CosmeticItem, registered in CosmeticRegistry (slot: .soundPack)
- [ ] Classic is free; Quiet Evening is earnable or premium
- [ ] All packs use AVAudioEngine synthesis (no bundled audio files) to keep app size small

## Technical Notes
- Extract current SoundManager method bodies into a ClassicSoundPack struct
- SoundManager.shared becomes a thin dispatcher: `activePack.playCardSlide()`
- Future packs could use bundled audio files — protocol is agnostic to implementation
- Consider bundling HapticPack selection with SoundPack as a "Feel Pack" to reduce UI complexity

## Dependencies
- Blocked by: ticket-cosmetic-registry
- Blocks: ticket-haptic-packs
