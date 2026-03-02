import AVFoundation

// MARK: - Sound Synth Protocol

/// Abstraction over audio synthesis primitives.
/// SoundManager conforms to this; packs call these to produce audio.
@MainActor
protocol SoundSynth: AnyObject {
    func playTone(frequency: Double, duration: Double, volume: Float, decay: Double)
    func playNoise(duration: Double, volume: Float, attackMs: Double, decayMs: Double,
                   filterType: AVAudioUnitEQFilterType, filterFreq: Float)
}

// MARK: - Sound Pack Protocol

/// Defines all game sound effects. Each method receives a SoundSynth to produce audio.
@MainActor
protocol SoundPack {
    nonisolated var id: String { get }
    nonisolated var displayName: String { get }

    // Physical card sounds
    func playCardSlide(using synth: any SoundSynth)
    func playCardPlace(using synth: any SoundSynth)
    func playCardFlip(using synth: any SoundSynth)
    func playShuffleRiffle(using synth: any SoundSynth)
    func playDeckTap(using synth: any SoundSynth)
    func playGo(using synth: any SoundSynth)
    func playDeal(using synth: any SoundSynth)

    // Musical sounds
    func playScore(using synth: any SoundSynth)
    func playScoreChime(points: Int, using synth: any SoundSynth)
    func playFifteenOrThirtyOne(using synth: any SoundSynth)
    func playRoundTransition(using synth: any SoundSynth)
    func playAnticipation(using synth: any SoundSynth)
    func playHisHeelsCelebration(using synth: any SoundSynth)
    func playInvalidAction(using synth: any SoundSynth)
    func playWin(using synth: any SoundSynth)
    func playLose(using synth: any SoundSynth)
    func playStreakFanfare(milestone: StreakMilestone, using synth: any SoundSynth)
}

// MARK: - Default Implementations

extension SoundPack {
    func playDeal(using synth: any SoundSynth) {
        playCardSlide(using: synth)
    }

    func playScore(using synth: any SoundSynth) {
        playScoreChime(points: 2, using: synth)
    }
}
