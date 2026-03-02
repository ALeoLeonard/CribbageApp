---
id: idea-tactile-immersion
type: idea
title: "Tactile Immersion & Deep Customization System"
status: raw
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: []
themes: []
scope: "general"
---

# Tactile Immersion & Deep Customization — Raw Capture

## Thought Stream

1. Make the game tactile and immersive — sound design, animation, vibrations, streaks, unlocks all working together
2. Inspired by Hearthstone (card weight, board interactions, premium feel) and Duolingo (streak psychology, dopamine loops, personality)
3. People should be able to customize based on phrases their family/friends say — nostalgic, personal
4. Example: "That's better than a kick in the head!" after scoring a good hand — the kind of thing your uncle says at the cabin
5. This is a moat — cribbage is deeply nostalgic, learned from grandparents, played at kitchen tables. No competitor exploits this emotional resonance
6. Deep customization: characters, card fronts, card backs, boards, pegs, UI elements
7. Character system = cribbage persona: your name, your catchphrases, your lucky peg color, your worn-in board. "Build your cribbage identity"
8. Card fronts: different art styles (vintage, minimalist, watercolor, etc.)
9. Card backs: patterns, materials, personal designs
10. Boards: different wood grains, materials, wear patterns
11. Pegs: colors, shapes, materials (brass, ivory, glass)
12. Custom phrases/callouts: replace generic scoring text with personal expressions. Per-event customization (pair, fifteen, run, big hand, skunk, win)
13. Unlock psychology: games played, win streaks, perfect hands, muggins catches, progression milestones
14. Duolingo-style streaks + XP + gems equivalent — play 100 games → unlock mahogany board
15. **Architecture is the priority** — build systems and protocols now so content is just data, not refactors
16. Process and systems are key — don't want large refactors later when adding content
17. Protocol-based cosmetic system: `Personality` protocol, `CosmeticItem` registry, `UnlockCondition` engine
18. Everything customizable should flow through a system that already exists — adding a new board or phrase is just adding data, not code
19. Sound design as a customizable layer — different card-play sounds, shuffle sounds, scoring fanfares per theme
20. Haptic patterns as part of the identity — different vibration signatures for different events
21. Streak celebrations should escalate — Duolingo's streak freeze anxiety, but positive (cribbage players are older, don't punish)
22. Shareability — people screenshot and share when their uncle's catchphrase pops up. Social proof, organic growth
23. The emotional connection IS the retention mechanism, not just gamification

## Initial Observations

- The existing theme system (CardBackTheme, TableTheme, BoardTheme protocols in ThemeManager) is a good foundation but needs to expand to cover card fronts, pegs, sound packs, phrase packs, and character identity
- Current SoundManager uses AVAudioEngine synthesis — could be extended with sound pack concept where each theme has its own audio character
- The haptic system exists but isn't themed — vibration patterns could be part of a "feel pack"
- ScoreEvent now has `cards: [Card]` — the callout/phrase system could hook into the same event pipeline
- StatsManager already tracks games/wins/streaks — this is the foundation for the unlock condition engine
- The key architectural bet: make customization a SYSTEM (registry + conditions + slots) not a FEATURE (hardcoded options). Content scales linearly, code stays fixed.
- Risk: over-engineering before validating which customizations players actually want. Build the system, ship 2-3 content packs, measure, expand.
