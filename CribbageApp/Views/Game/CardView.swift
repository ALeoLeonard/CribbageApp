import SwiftUI

struct CardView: View {
    let card: Card
    var isSelected: Bool = false
    var isFaceDown: Bool = false
    var isSmall: Bool = false

    private var width: CGFloat { isSmall ? 44 : 60 }
    private var height: CGFloat { isSmall ? 64 : 88 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isFaceDown ? Color.blue : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.secondary.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

            if isFaceDown {
                // Card back pattern
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.8))
                    .padding(3)
                    .overlay(
                        Image(systemName: "suit.diamond.fill")
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.title3)
                    )
            } else {
                VStack(spacing: 0) {
                    Text(card.rank.rawValue)
                        .font(isSmall ? .caption.bold() : .callout.bold())
                    Text(card.suit.symbol)
                        .font(isSmall ? .caption : .callout)
                }
                .foregroundStyle(card.suit.color)
            }
        }
        .frame(width: width, height: height)
        .offset(y: isSelected ? -12 : 0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
