import AVFoundation

// MARK: - Classic Sound Pack

struct ClassicSoundPack: SoundPack {
    nonisolated let id = "classic-sounds"
    nonisolated let displayName = "Classic"

    // MARK: Physical Card Sounds

    func playCardSlide(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.08, volume: 0.25, attackMs: 10, decayMs: 70,
            filterType: .lowPass, filterFreq: 2000
        )
    }

    func playCardPlace(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.05, volume: 0.4, attackMs: 2, decayMs: 48,
            filterType: .bandPass, filterFreq: 800
        )
    }

    func playCardFlip(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.03, volume: 0.2, attackMs: 1, decayMs: 29,
            filterType: .highPass, filterFreq: 3000
        )
    }

    func playShuffleRiffle(using synth: any SoundSynth) {
        Task { @MainActor in
            let clickCount = Int.random(in: 8...12)
            for i in 0..<clickCount {
                let vol: Float = 0.12 + Float.random(in: -0.03...0.03)
                let freq: Float = 1500 + Float.random(in: -200...200)
                synth.playNoise(
                    duration: 0.025, volume: vol, attackMs: 1, decayMs: 24,
                    filterType: .bandPass, filterFreq: freq
                )
                let gap = Int.random(in: 30...50)
                let factor = max(0.6, 1.0 - Double(i) * 0.04)
                try? await Task.sleep(for: .milliseconds(Int(Double(gap) * factor)))
            }
        }
    }

    func playDeckTap(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.04, volume: 0.35, attackMs: 3, decayMs: 37,
            filterType: .lowPass, filterFreq: 600
        )
    }

    func playGo(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.05, volume: 0.2, attackMs: 2, decayMs: 48,
            filterType: .bandPass, filterFreq: 800
        )
    }

    // MARK: Musical Sounds

    func playScoreChime(points: Int, using synth: any SoundSynth) {
        let baseFreq: Double = 660 + Double(min(points, 12)) * 30
        synth.playTone(frequency: baseFreq, duration: 0.1, volume: 0.25, decay: 0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            synth.playTone(frequency: baseFreq * 1.25, duration: 0.12, volume: 0.3, decay: 0.6)
        }
        if points >= 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                synth.playTone(frequency: baseFreq * 1.5, duration: 0.15, volume: 0.3, decay: 0.5)
            }
        }
    }

    func playFifteenOrThirtyOne(using synth: any SoundSynth) {
        synth.playTone(frequency: 1320, duration: 0.08, volume: 0.35, decay: 0.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            synth.playTone(frequency: 1760, duration: 0.15, volume: 0.3, decay: 0.3)
        }
    }

    func playRoundTransition(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(523, 0.08), (659, 0.08), (784, 0.12)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.09) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.2, decay: 0.5)
            }
        }
    }

    func playAnticipation(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(330, 0.1), (370, 0.1), (415, 0.1), (466, 0.15)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.2, decay: 0.5)
            }
        }
    }

    func playHisHeelsCelebration(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(523, 0.12), (659, 0.12), (784, 0.12), (1047, 0.2)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.13) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.3, decay: 0.5)
            }
        }
    }

    func playInvalidAction(using synth: any SoundSynth) {
        synth.playTone(frequency: 200, duration: 0.12, volume: 0.15, decay: 0.3)
    }

    func playWin(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(660, 0.15), (880, 0.15), (1100, 0.25)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.35, decay: 0.5)
            }
        }
    }

    func playLose(using synth: any SoundSynth) {
        synth.playTone(frequency: 440, duration: 0.2, volume: 0.25, decay: 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            synth.playTone(frequency: 330, duration: 0.3, volume: 0.2, decay: 0.5)
        }
    }

    func playStreakFanfare(milestone: StreakMilestone, using synth: any SoundSynth) {
        let notes: [(Double, Double)]
        switch milestone {
        case .rolling:
            notes = [(660, 0.12), (880, 0.12), (1100, 0.2)]
        case .hotStreak:
            notes = [(660, 0.1), (880, 0.1), (1100, 0.1), (1320, 0.2)]
        case .legendary:
            notes = [(660, 0.1), (880, 0.1), (1100, 0.1), (1320, 0.1), (1540, 0.25)]
        case .domination:
            notes = [(660, 0.08), (880, 0.08), (1100, 0.08), (1320, 0.08), (1540, 0.08), (1760, 0.3)]
        }
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.14) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.35, decay: 0.5)
            }
        }
    }
}

// MARK: - Quiet Evening Sound Pack

struct QuietEveningSoundPack: SoundPack {
    nonisolated let id = "quiet-evening"
    nonisolated let displayName = "Quiet Evening"

    // MARK: Physical Card Sounds

    func playCardSlide(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.10, volume: 0.12, attackMs: 15, decayMs: 85,
            filterType: .lowPass, filterFreq: 1200
        )
    }

    func playCardPlace(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.06, volume: 0.18, attackMs: 5, decayMs: 55,
            filterType: .lowPass, filterFreq: 500
        )
    }

    func playCardFlip(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.04, volume: 0.08, attackMs: 2, decayMs: 38,
            filterType: .bandPass, filterFreq: 2000
        )
    }

    func playShuffleRiffle(using synth: any SoundSynth) {
        Task { @MainActor in
            let clickCount = Int.random(in: 6...8)
            for i in 0..<clickCount {
                let vol: Float = 0.06 + Float.random(in: -0.02...0.02)
                let freq: Float = 1200 + Float.random(in: -150...150)
                synth.playNoise(
                    duration: 0.025, volume: vol, attackMs: 2, decayMs: 23,
                    filterType: .bandPass, filterFreq: freq
                )
                let gap = Int.random(in: 35...55)
                let factor = max(0.6, 1.0 - Double(i) * 0.04)
                try? await Task.sleep(for: .milliseconds(Int(Double(gap) * factor)))
            }
        }
    }

    func playDeckTap(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.05, volume: 0.15, attackMs: 5, decayMs: 45,
            filterType: .lowPass, filterFreq: 400
        )
    }

    func playGo(using synth: any SoundSynth) {
        synth.playNoise(
            duration: 0.05, volume: 0.1, attackMs: 3, decayMs: 47,
            filterType: .bandPass, filterFreq: 600
        )
    }

    // MARK: Musical Sounds

    func playScoreChime(points: Int, using synth: any SoundSynth) {
        let baseFreq: Double = 440 + Double(min(points, 12)) * 20
        synth.playTone(frequency: baseFreq, duration: 0.12, volume: 0.12, decay: 0.9)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            synth.playTone(frequency: baseFreq * 1.25, duration: 0.15, volume: 0.15, decay: 0.8)
        }
    }

    func playFifteenOrThirtyOne(using synth: any SoundSynth) {
        synth.playTone(frequency: 880, duration: 0.1, volume: 0.15, decay: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            synth.playTone(frequency: 1100, duration: 0.18, volume: 0.12, decay: 0.4)
        }
    }

    func playRoundTransition(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(440, 0.1), (554, 0.15)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.1, decay: 0.6)
            }
        }
    }

    func playAnticipation(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(262, 0.12), (294, 0.12), (330, 0.18)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.14) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.1, decay: 0.6)
            }
        }
    }

    func playHisHeelsCelebration(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(440, 0.15), (554, 0.25)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.15, decay: 0.7)
            }
        }
    }

    func playInvalidAction(using synth: any SoundSynth) {
        synth.playTone(frequency: 330, duration: 0.1, volume: 0.08, decay: 0.4)
    }

    func playWin(using synth: any SoundSynth) {
        let notes: [(Double, Double)] = [(440, 0.18), (554, 0.3)]
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.15, decay: 0.6)
            }
        }
    }

    func playLose(using synth: any SoundSynth) {
        synth.playTone(frequency: 330, duration: 0.3, volume: 0.12, decay: 0.7)
    }

    func playStreakFanfare(milestone: StreakMilestone, using synth: any SoundSynth) {
        let notes: [(Double, Double)]
        switch milestone {
        case .rolling:
            notes = [(440, 0.15), (554, 0.25)]
        case .hotStreak:
            notes = [(440, 0.12), (554, 0.12), (660, 0.25)]
        case .legendary, .domination:
            notes = [(440, 0.1), (554, 0.1), (660, 0.3)]
        }
        for (i, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.16) {
                synth.playTone(frequency: note.0, duration: note.1, volume: 0.15, decay: 0.6)
            }
        }
    }
}
