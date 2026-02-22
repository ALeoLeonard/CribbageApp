import SwiftUI

struct PlayAreaView: View {
    let playPile: [Card]
    let runningTotal: Int
    let starter: Card?
    var starterCeremonyPhase: StarterCeremonyPhase = .idle

    @State private var starterRevealed = false

    var body: some View {
        VStack(spacing: 10) {
            // Starter area: ceremony or normal display
            if starterCeremonyPhase == .cutting || starterCeremonyPhase == .revealing {
                starterCeremonyView
                    .transition(.opacity)
            } else if let starter {
                HStack(spacing: 8) {
                    Text("Starter")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.8))
                    CardView(card: starter, isFaceDown: !starterRevealed, isSmall: true)
                        .rotation3DEffect(
                            .degrees(starterRevealed ? 0 : 180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.easeInOut(duration: 0.5), value: starterRevealed)
                }
                .onChange(of: starter.id) {
                    starterRevealed = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        starterRevealed = true
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        starterRevealed = true
                    }
                }
            }

            // Play pile — fanned with slight rotation
            if !playPile.isEmpty {
                HStack(spacing: -14) {
                    ForEach(Array(playPile.enumerated()), id: \.element.id) { idx, card in
                        let count = playPile.count
                        let midpoint = Double(count - 1) / 2.0
                        let rotation = (Double(idx) - midpoint) * 2.0

                        PlayedCardView(card: card, rotation: rotation, zIndex: Double(idx))
                    }
                }
                .frame(minHeight: CribbageTheme.cardSmallHeight + 10)
            }

            // Count badge
            if runningTotal > 0 || !playPile.isEmpty {
                Text("Count: \(runningTotal) / 31")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CribbageTheme.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.3))
                    )
            }
        }
    }

    // MARK: - Starter Ceremony

    private var starterCeremonyView: some View {
        VStack(spacing: 8) {
            Text("Cutting deck...")
                .font(.caption.weight(.medium))
                .foregroundStyle(CribbageTheme.ivory.opacity(0.8))

            DeckView(
                cardCount: 40,
                isCutting: starterCeremonyPhase == .revealing,
                revealedCard: starterCeremonyPhase == .revealing ? starter : nil,
                isSmall: true
            )
        }
    }
}

/// A card that animates into the play area when it appears.
private struct PlayedCardView: View {
    let card: Card
    let rotation: Double
    let zIndex: Double

    @State private var appeared = false

    var body: some View {
        CardView(card: card, isSmall: true)
            .rotationEffect(.degrees(rotation))
            .zIndex(zIndex)
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 40)
            .animation(.spring(duration: 0.4, bounce: 0.25), value: appeared)
            .onAppear { appeared = true }
    }
}
