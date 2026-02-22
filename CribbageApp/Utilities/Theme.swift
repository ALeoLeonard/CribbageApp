import SwiftUI

// MARK: - CribbageTheme

enum CribbageTheme {

    // MARK: Felt

    static let feltGreen = Color(red: 0.08, green: 0.38, blue: 0.18)
    static let feltGreenDark = Color(red: 0.05, green: 0.30, blue: 0.12)
    static let feltGreenLight = Color(red: 0.12, green: 0.45, blue: 0.22)

    // MARK: Wood

    static let woodLight = Color(red: 0.55, green: 0.35, blue: 0.18)
    static let woodDark = Color(red: 0.38, green: 0.22, blue: 0.10)

    static var woodGradient: LinearGradient {
        LinearGradient(
            colors: [woodLight, woodDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Cards

    static let cardFaceLight = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let cardFaceDark = Color(red: 0.94, green: 0.91, blue: 0.86)
    static let cardBackNavy = Color(red: 0.15, green: 0.08, blue: 0.35)
    static let cardBackNavyLight = Color(red: 0.22, green: 0.14, blue: 0.45)
    static let cardBorder = Color(red: 0.75, green: 0.72, blue: 0.65)

    static var cardFaceGradient: LinearGradient {
        LinearGradient(
            colors: [cardFaceLight, cardFaceDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: Suit colors

    static let suitRed = Color(red: 0.78, green: 0.12, blue: 0.12)
    static let suitBlack = Color(red: 0.12, green: 0.12, blue: 0.14)

    // MARK: Accents

    static let gold = Color(red: 0.85, green: 0.70, blue: 0.30)
    static let goldLight = Color(red: 0.92, green: 0.82, blue: 0.50)
    static let goldDark = Color(red: 0.70, green: 0.55, blue: 0.18)
    static let ivory = Color(red: 0.95, green: 0.93, blue: 0.88)

    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldLight, gold, goldDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Sizes

    static let cardWidth: CGFloat = 72
    static let cardHeight: CGFloat = 104
    static let cardSmallWidth: CGFloat = 50
    static let cardSmallHeight: CGFloat = 72
    static let cardCornerRadius: CGFloat = 10
}

// MARK: - FeltBackground

struct FeltBackground: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    func body(content: Content) -> some View {
        let table = themeManager.activeTable
        content
            .background {
                ZStack {
                    LinearGradient(
                        colors: [
                            table.secondaryColor,
                            table.primaryColor,
                            table.secondaryColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Noise texture
                    Canvas { context, size in
                        var rng = SeededRandomNumberGenerator(seed: 42)
                        let step: CGFloat = 4
                        for x in stride(from: 0, to: size.width, by: step) {
                            for y in stride(from: 0, to: size.height, by: step) {
                                let opacity = Double.random(in: 0.0...0.06, using: &rng)
                                let rect = CGRect(x: x, y: y, width: step, height: step)
                                context.fill(
                                    Path(rect),
                                    with: .color(.white.opacity(opacity))
                                )
                            }
                        }
                    }
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea()
            }
    }
}

extension View {
    func feltBackground() -> some View {
        modifier(FeltBackground())
    }
}

// MARK: - Deterministic RNG for noise

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
