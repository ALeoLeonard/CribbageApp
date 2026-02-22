import SwiftUI

struct CardView: View {
    let card: Card
    var isSelected: Bool = false
    var isFaceDown: Bool = false
    var isSmall: Bool = false

    @Environment(ThemeManager.self) private var themeManager

    private var width: CGFloat {
        isSmall ? CribbageTheme.cardSmallWidth : CribbageTheme.cardWidth
    }
    private var height: CGFloat {
        isSmall ? CribbageTheme.cardSmallHeight : CribbageTheme.cardHeight
    }
    private var cornerRadius: CGFloat { CribbageTheme.cardCornerRadius }

    private var rankFont: Font {
        isSmall ? .system(size: 10, weight: .bold) : .system(size: 14, weight: .bold)
    }
    private var suitFont: Font {
        isSmall ? .system(size: 8) : .system(size: 11)
    }
    private var centerFont: Font {
        isSmall ? .system(size: 18) : .system(size: 26)
    }

    var body: some View {
        ZStack {
            if isFaceDown {
                cardBack
            } else {
                cardFace
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(
            color: isSelected ? CribbageTheme.gold.opacity(0.6) : .black.opacity(0.18),
            radius: isSelected ? 8 : 3,
            y: isSelected ? 0 : 2
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .offset(y: isSelected ? -14 : 0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Card Face

    private var cardFace: some View {
        ZStack {
            // Ivory background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(CribbageTheme.cardFaceGradient)
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(CribbageTheme.cardBorder, lineWidth: 0.8)

            // Corner indices
            VStack {
                HStack {
                    cornerIndex
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    cornerIndex
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(isSmall ? 3 : 5)

            // Center pip
            Text(card.suit.symbol)
                .font(centerFont)
                .foregroundStyle(card.suit.color)
        }
    }

    private var cornerIndex: some View {
        VStack(spacing: -1) {
            Text(card.rank.rawValue)
                .font(rankFont)
            Text(card.suit.symbol)
                .font(suitFont)
        }
        .foregroundStyle(card.suit.color)
    }

    // MARK: - Card Back (themed)

    private var cardBack: some View {
        let theme = themeManager.activeCardBack

        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.primaryColor)

            // Theme-specific pattern
            Canvas { context, size in
                theme.render(in: context, size: size)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 2).inset(by: 3))

            // Inner border
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .strokeBorder(theme.accentColor.opacity(0.25), lineWidth: 1)
                .padding(3)

            // Outer border
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(theme.primaryColor.opacity(0.6), lineWidth: 0.8)
        }
    }
}
