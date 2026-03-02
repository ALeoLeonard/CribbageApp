import AVFoundation
import SwiftUI

/// Synthesizes physical card-game sound effects using noise-based AVAudioEngine synthesis.
/// Card sounds use filtered white noise for a physical feel; musical sounds use sine tones.
/// Delegates sound design to the active SoundPack; owns the AVAudioEngine infrastructure.
@MainActor
final class SoundManager: SoundSynth {

    static let shared = SoundManager()

    @AppStorage("soundEnabled") var soundEnabled = true

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var eq: AVAudioUnitEQ?

    private let sampleRate: Double = 44100

    private init() {
        setupEngine()
    }

    // MARK: - Active Sound Pack

    var activeSoundPack: any SoundPack {
        CosmeticRegistry.shared.activeSoundPack
    }

    // MARK: - Setup

    private func setupEngine() {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let eq = AVAudioUnitEQ(numberOfBands: 1)

        engine.attach(player)
        engine.attach(eq)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            return
        }

        self.engine = engine
        self.playerNode = player
        self.eq = eq
    }

    private func ensureRunning() {
        guard let engine, !engine.isRunning else { return }
        try? engine.start()
    }

    // MARK: - Physical Card Sounds

    /// Soft whoosh — card sliding on felt
    func playCardSlide() {
        guard soundEnabled else { return }
        activeSoundPack.playCardSlide(using: self)
    }

    /// Thud + slap — card hitting table
    func playCardPlace() {
        guard soundEnabled else { return }
        activeSoundPack.playCardPlace(using: self)
    }

    /// Crisp snap — card turning over
    func playCardFlip() {
        guard soundEnabled else { return }
        activeSoundPack.playCardFlip(using: self)
    }

    /// Rapid flutter — riffle shuffle (sequence of micro-clicks)
    func playShuffleRiffle() {
        guard soundEnabled else { return }
        activeSoundPack.playShuffleRiffle(using: self)
    }

    /// Knock — tapping deck to cut
    func playDeckTap() {
        guard soundEnabled else { return }
        activeSoundPack.playDeckTap(using: self)
    }

    /// Short card tap for "Go"
    func playGo() {
        guard soundEnabled else { return }
        activeSoundPack.playGo(using: self)
    }

    /// Deal sound
    func playDeal() {
        guard soundEnabled else { return }
        activeSoundPack.playDeal(using: self)
    }

    // MARK: - Musical Sounds

    /// Rising two-note chime (generic)
    func playScore() {
        guard soundEnabled else { return }
        activeSoundPack.playScore(using: self)
    }

    /// Point-scaled score chime — higher points = higher pitch, more notes
    func playScoreChime(points: Int) {
        guard soundEnabled else { return }
        activeSoundPack.playScoreChime(points: points, using: self)
    }

    /// Special 15/31 hit — satisfying "ding"
    func playFifteenOrThirtyOne() {
        guard soundEnabled else { return }
        activeSoundPack.playFifteenOrThirtyOne(using: self)
    }

    /// Round transition fanfare — brief ascending arpeggio
    func playRoundTransition() {
        guard soundEnabled else { return }
        activeSoundPack.playRoundTransition(using: self)
    }

    /// Rising sweep — tension before starter reveal
    func playAnticipation() {
        guard soundEnabled else { return }
        activeSoundPack.playAnticipation(using: self)
    }

    /// Triumphant arpeggio for Jack starter (His Heels)
    func playHisHeelsCelebration() {
        guard soundEnabled else { return }
        activeSoundPack.playHisHeelsCelebration(using: self)
    }

    /// Error / invalid play
    func playInvalidAction() {
        guard soundEnabled else { return }
        activeSoundPack.playInvalidAction(using: self)
    }

    /// Ascending fanfare
    func playWin() {
        guard soundEnabled else { return }
        activeSoundPack.playWin(using: self)
    }

    /// Descending tone
    func playLose() {
        guard soundEnabled else { return }
        activeSoundPack.playLose(using: self)
    }

    /// Escalating streak fanfare
    func playStreakFanfare(milestone: StreakMilestone) {
        guard soundEnabled else { return }
        activeSoundPack.playStreakFanfare(milestone: milestone, using: self)
    }

    // MARK: - SoundSynth Primitives

    func playNoise(
        duration: Double,
        volume: Float,
        attackMs: Double,
        decayMs: Double,
        filterType: AVAudioUnitEQFilterType,
        filterFreq: Float
    ) {
        guard let playerNode, let engine, let eq else { return }
        ensureRunning()
        guard engine.isRunning else { return }

        // Configure EQ band
        let band = eq.bands[0]
        band.filterType = filterType
        band.frequency = filterFreq
        band.bandwidth = 1.0
        band.gain = 0
        band.bypass = false

        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard frameCount > 0,
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { return }

        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        let attackSamples = Int(sampleRate * attackMs / 1000.0)
        let decaySamples = Int(sampleRate * decayMs / 1000.0)
        let totalSamples = Int(frameCount)

        for i in 0..<totalSamples {
            // White noise
            let noise = Float.random(in: -1.0...1.0)

            // Envelope: linear attack, exponential decay
            let envelope: Float
            if i < attackSamples {
                envelope = Float(i) / max(Float(attackSamples), 1)
            } else {
                let decayPos = Float(i - attackSamples) / max(Float(decaySamples), 1)
                envelope = exp(-3.0 * decayPos)
            }

            data[i] = noise * volume * envelope
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    func playTone(frequency: Double, duration: Double, volume: Float, decay: Double) {
        guard let playerNode, let engine, let eq else { return }
        ensureRunning()
        guard engine.isRunning else { return }

        // Bypass EQ for pure tones
        eq.bands[0].bypass = true

        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!,
            frameCapacity: frameCount
        ) else { return }

        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = Float(exp(-t / decay))
            let sample = Float(sin(2.0 * .pi * frequency * t)) * volume * envelope
            data[i] = sample
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
}
