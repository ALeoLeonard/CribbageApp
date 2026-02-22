import SwiftUI

/// A visual stack of face-down cards that looks like a physical deck.
/// Supports shuffle and cut animations.
struct DeckView: View {
    var cardCount: Int = 52
    var isShuffling: Bool = false
    var isCutting: Bool = false
    var revealedCard: Card? = nil
    var isSmall: Bool = false

    @Environment(ThemeManager.self) private var themeManager

    private var width: CGFloat {
        isSmall ? CribbageTheme.cardSmallWidth : CribbageTheme.cardWidth
    }
    private var height: CGFloat {
        isSmall ? CribbageTheme.cardSmallHeight : CribbageTheme.cardHeight
    }
    private let cornerRadius = CribbageTheme.cardCornerRadius

    // Shuffle animation state
    @State private var shufflePhase: Int = 0

    var body: some View {
        ZStack {
            if isShuffling {
                shuffleView
            } else if isCutting {
                cutView
            } else {
                stackView
            }
        }
        .frame(width: width + 6, height: height + 6)
        .onChange(of: isShuffling) { _, newValue in
            if newValue {
                animateShuffle()
            } else {
                shufflePhase = 0
            }
        }
    }

    // MARK: - Static Stack

    private var stackView: some View {
        ZStack {
            // Bottom layers for depth
            ForEach(0..<min(3, max(cardCount - 1, 0)), id: \.self) { i in
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(themeManager.activeCardBack.primaryColor.opacity(0.7))
                    .frame(width: width, height: height)
                    .offset(x: CGFloat(i) * 1.0, y: CGFloat(i) * 1.0)
                    .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
            }

            // Top card
            if cardCount > 0 {
                cardBackFace
                    .offset(x: CGFloat(min(3, cardCount - 1)) * 1.0,
                            y: CGFloat(min(3, cardCount - 1)) * 1.0)
                    .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
            }
        }
    }

    // MARK: - Shuffle Animation

    private var shuffleView: some View {
        ZStack {
            // Left half
            cardBackFace
                .offset(x: shuffleOffset(for: .left), y: 0)
                .rotationEffect(.degrees(shuffleRotation(for: .left)))

            // Right half
            cardBackFace
                .offset(x: shuffleOffset(for: .right), y: 0)
                .rotationEffect(.degrees(shuffleRotation(for: .right)))
        }
    }

    private enum HalfSide { case left, right }

    private func shuffleOffset(for side: HalfSide) -> CGFloat {
        let spread: CGFloat = width * 0.4
        switch shufflePhase {
        case 0: return 0
        case 1: return side == .left ? -spread : spread
        case 2: return side == .left ? spread * 0.3 : -spread * 0.3
        case 3: return side == .left ? -spread * 0.6 : spread * 0.6
        case 4: return side == .left ? spread * 0.15 : -spread * 0.15
        case 5: return side == .left ? -spread * 0.3 : spread * 0.3
        case 6: return 0
        default: return 0
        }
    }

    private func shuffleRotation(for side: HalfSide) -> Double {
        switch shufflePhase {
        case 1: return side == .left ? -3 : 3
        case 2: return side == .left ? 2 : -2
        case 3: return side == .left ? -4 : 4
        case 4: return side == .left ? 1 : -1
        case 5: return side == .left ? -2 : 2
        default: return 0
        }
    }

    private func animateShuffle() {
        let phases = [1, 2, 3, 4, 5, 6]
        for (i, phase) in phases.enumerated() {
            let delay = Double(i) * 0.18
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.16)) {
                    shufflePhase = phase
                }
            }
        }
    }

    // MARK: - Cut Animation

    private var cutView: some View {
        ZStack {
            // Bottom portion stays
            cardBackFace
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

            // Top portion slides right
            Group {
                if let card = revealedCard {
                    // Show the revealed starter card face-up
                    CardView(card: card, isSmall: isSmall)
                } else {
                    cardBackFace
                }
            }
            .offset(x: width * 0.4)
            .rotationEffect(.degrees(5))
            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
        }
    }

    // MARK: - Card Back (themed)

    private var cardBackFace: some View {
        let theme = themeManager.activeCardBack
        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.primaryColor)

            Canvas { context, size in
                theme.render(in: context, size: size)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 2).inset(by: 3))

            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .strokeBorder(theme.accentColor.opacity(0.25), lineWidth: 1)
                .padding(3)

            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(theme.primaryColor.opacity(0.6), lineWidth: 0.8)
        }
        .frame(width: width, height: height)
    }
}
