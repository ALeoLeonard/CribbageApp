import AVFoundation
import SwiftUI

/// Synthesizes physical card-game sound effects using noise-based AVAudioEngine synthesis.
/// Card sounds use filtered white noise for a physical feel; musical sounds use sine tones.
@MainActor
final class SoundManager {

    static let shared = SoundManager()

    @AppStorage("soundEnabled") var soundEnabled = true

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var eq: AVAudioUnitEQ?

    private let sampleRate: Double = 44100

    private init() {
        setupEngine()
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
        playNoise(
            duration: 0.08,
            volume: 0.25,
            attackMs: 10,
            decayMs: 70,
            filterType: .lowPass,
            filterFreq: 2000
        )
    }

    /// Thud + slap — card hitting table
    func playCardPlace() {
        playNoise(
            duration: 0.05,
            volume: 0.4,
            attackMs: 2,
            decayMs: 48,
            filterType: .bandPass,
            filterFreq: 800
        )
    }

    /// Crisp snap — card turning over
    func playCardFlip() {
        playNoise(
            duration: 0.03,
            volume: 0.2,
            attackMs: 1,
            decayMs: 29,
            filterType: .highPass,
            filterFreq: 3000
        )
    }

    /// Rapid flutter — riffle shuffle (sequence of micro-clicks)
    func playShuffleRiffle() {
        Task {
            let clickCount = Int.random(in: 8...12)
            for i in 0..<clickCount {
                let vol: Float = 0.12 + Float.random(in: -0.03...0.03)
                let freq: Float = 1500 + Float.random(in: -200...200)
                playNoise(
                    duration: 0.025,
                    volume: vol,
                    attackMs: 1,
                    decayMs: 24,
                    filterType: .bandPass,
                    filterFreq: freq
                )
                // Randomized gap between clicks (30–50ms)
                let gap = Int.random(in: 30...50)
                // Speed up slightly toward end
                let factor = max(0.6, 1.0 - Double(i) * 0.04)
                try? await Task.sleep(for: .milliseconds(Int(Double(gap) * factor)))
            }
        }
    }

    /// Knock — tapping deck to cut
    func playDeckTap() {
        playNoise(
            duration: 0.04,
            volume: 0.35,
            attackMs: 3,
            decayMs: 37,
            filterType: .lowPass,
            filterFreq: 600
        )
    }

    /// Short card tap (reuse cardPlace at lower vol) for "Go"
    func playGo() {
        playNoise(
            duration: 0.05,
            volume: 0.2,
            attackMs: 2,
            decayMs: 48,
            filterType: .bandPass,
            filterFreq: 800
        )
    }

    /// Deal sound — alias for card slide
    func playDeal() {
        playCardSlide()
    }

    // MARK: - Musical Sounds (kept as sine tones)

    /// Rising two-note chime
    func playScore() {
        playTone(frequency: 880, duration: 0.1, volume: 0.25, decay: 0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.playTone(frequency: 1100, duration: 0.15, volume: 0.3, decay: 0.6)
        }
    }

    /// Ascending three-note fanfare
    func playWin() {
        let notes: [(Double, Double)] = [(660, 0.15), (880, 0.15), (1100, 0.25)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                self.playTone(frequency: note.0, duration: note.1, volume: 0.35, decay: 0.5)
            }
        }
    }

    /// Descending two-note
    func playLose() {
        playTone(frequency: 440, duration: 0.2, volume: 0.25, decay: 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            self.playTone(frequency: 330, duration: 0.3, volume: 0.2, decay: 0.5)
        }
    }

    // MARK: - Noise Generator

    private func playNoise(
        duration: Double,
        volume: Float,
        attackMs: Double,
        decayMs: Double,
        filterType: AVAudioUnitEQFilterType,
        filterFreq: Float
    ) {
        guard soundEnabled, let playerNode, let engine, let eq else { return }
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

    // MARK: - Tone Generator (for musical sounds)

    private func playTone(frequency: Double, duration: Double, volume: Float, decay: Double) {
        guard soundEnabled, let playerNode, let engine, let eq else { return }
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
