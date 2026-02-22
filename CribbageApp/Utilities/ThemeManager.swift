import SwiftUI

// MARK: - Theme Protocols

protocol CardBackTheme: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var isPremium: Bool { get }
    var primaryColor: Color { get }
    var accentColor: Color { get }
    func render(in context: GraphicsContext, size: CGSize)
}

protocol TableTheme: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var isPremium: Bool { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    func drawTexture(in context: GraphicsContext, size: CGSize)
}

protocol BoardTheme: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var isPremium: Bool { get }
    var woodLight: Color { get }
    var woodDark: Color { get }
    var pegPlayerColor: Color { get }
    var pegOpponentColor: Color { get }
}

// MARK: - ThemeManager

@MainActor @Observable
final class ThemeManager {
    static let shared = ThemeManager()

    var activeCardBackID: String {
        didSet { UserDefaults.standard.set(activeCardBackID, forKey: "activeCardBack") }
    }
    var activeTableID: String {
        didSet { UserDefaults.standard.set(activeTableID, forKey: "activeTable") }
    }
    var activeBoardID: String {
        didSet { UserDefaults.standard.set(activeBoardID, forKey: "activeBoard") }
    }

    var unlockedThemeIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(unlockedThemeIDs), forKey: "unlockedThemes")
        }
    }

    // All available themes
    let cardBacks: [any CardBackTheme] = [
        ClassicNavyBack(), RoyalRedBack(), EmeraldBack(), CelticKnotBack(), ArtDecoBack()
    ]
    let tables: [any TableTheme] = [
        GreenFeltTable(), BlueFeltTable(), RedVelvetTable(), MahoganyTable()
    ]
    let boards: [any BoardTheme] = [
        ClassicWoodBoard(), DarkWalnutBoard(), MarbleBoard(), GoldInlayBoard()
    ]

    var activeCardBack: any CardBackTheme {
        cardBacks.first { $0.id == activeCardBackID } ?? cardBacks[0]
    }
    var activeTable: any TableTheme {
        tables.first { $0.id == activeTableID } ?? tables[0]
    }
    var activeBoard: any BoardTheme {
        boards.first { $0.id == activeBoardID } ?? boards[0]
    }

    func isUnlocked(_ themeID: String) -> Bool {
        unlockedThemeIDs.contains(themeID)
    }

    func selectCardBack(_ id: String) {
        guard isUnlocked(id) else { return }
        activeCardBackID = id
    }
    func selectTable(_ id: String) {
        guard isUnlocked(id) else { return }
        activeTableID = id
    }
    func selectBoard(_ id: String) {
        guard isUnlocked(id) else { return }
        activeBoardID = id
    }

    private init() {
        // Free themes
        let freeIDs: Set<String> = [
            "classic-navy", "royal-red", "emerald",
            "green-felt", "blue-felt",
            "classic-wood", "dark-walnut"
        ]

        let saved = Set(UserDefaults.standard.stringArray(forKey: "unlockedThemes") ?? [])
        self.unlockedThemeIDs = freeIDs.union(saved)
        self.activeCardBackID = UserDefaults.standard.string(forKey: "activeCardBack") ?? "classic-navy"
        self.activeTableID = UserDefaults.standard.string(forKey: "activeTable") ?? "green-felt"
        self.activeBoardID = UserDefaults.standard.string(forKey: "activeBoard") ?? "classic-wood"
    }
}

// MARK: - Card Back Themes

struct ClassicNavyBack: CardBackTheme {
    let id = "classic-navy"
    let displayName = "Classic Navy"
    let isPremium = false
    let primaryColor = Color(red: 0.15, green: 0.08, blue: 0.35)
    let accentColor = CribbageTheme.goldLight

    func render(in context: GraphicsContext, size: CGSize) {
        // Diamond lattice
        let spacing: CGFloat = 12
        for x in stride(from: spacing, to: size.width, by: spacing) {
            for y in stride(from: spacing, to: size.height, by: spacing) {
                let diamond = Path { p in
                    let s: CGFloat = 4
                    p.move(to: CGPoint(x: x, y: y - s))
                    p.addLine(to: CGPoint(x: x + s, y: y))
                    p.addLine(to: CGPoint(x: x, y: y + s))
                    p.addLine(to: CGPoint(x: x - s, y: y))
                    p.closeSubpath()
                }
                context.stroke(diamond, with: .color(accentColor.opacity(0.25)), lineWidth: 0.6)
            }
        }
    }
}

struct RoyalRedBack: CardBackTheme {
    let id = "royal-red"
    let displayName = "Royal Red"
    let isPremium = false
    let primaryColor = Color(red: 0.45, green: 0.08, blue: 0.10)
    let accentColor = CribbageTheme.goldLight

    func render(in context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 14
        for x in stride(from: spacing / 2, to: size.width, by: spacing) {
            for y in stride(from: spacing / 2, to: size.height, by: spacing) {
                let circle = Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
                context.stroke(circle, with: .color(accentColor.opacity(0.2)), lineWidth: 0.5)
            }
        }
    }
}

struct EmeraldBack: CardBackTheme {
    let id = "emerald"
    let displayName = "Emerald"
    let isPremium = false
    let primaryColor = Color(red: 0.05, green: 0.28, blue: 0.18)
    let accentColor = Color(red: 0.6, green: 0.85, blue: 0.65)

    func render(in context: GraphicsContext, size: CGSize) {
        // Cross-hatch
        let spacing: CGFloat = 10
        for x in stride(from: 0, to: size.width + size.height, by: spacing) {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x - size.height, y: size.height))
            context.stroke(path, with: .color(accentColor.opacity(0.12)), lineWidth: 0.4)

            var path2 = Path()
            path2.move(to: CGPoint(x: x - size.height, y: 0))
            path2.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path2, with: .color(accentColor.opacity(0.12)), lineWidth: 0.4)
        }
    }
}

struct CelticKnotBack: CardBackTheme {
    let id = "celtic-knot"
    let displayName = "Celtic Knot"
    let isPremium = true
    let primaryColor = Color(red: 0.12, green: 0.10, blue: 0.30)
    let accentColor = Color(red: 0.75, green: 0.65, blue: 0.30)

    func render(in context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 16
        for x in stride(from: spacing, to: size.width, by: spacing) {
            for y in stride(from: spacing, to: size.height, by: spacing) {
                // Interlocking circles
                let r: CGFloat = 6
                let circle1 = Path(ellipseIn: CGRect(x: x - r, y: y - r / 2, width: r * 2, height: r))
                let circle2 = Path(ellipseIn: CGRect(x: x - r / 2, y: y - r, width: r, height: r * 2))
                context.stroke(circle1, with: .color(accentColor.opacity(0.3)), lineWidth: 0.6)
                context.stroke(circle2, with: .color(accentColor.opacity(0.3)), lineWidth: 0.6)
            }
        }
    }
}

struct ArtDecoBack: CardBackTheme {
    let id = "art-deco"
    let displayName = "Art Deco"
    let isPremium = true
    let primaryColor = Color(red: 0.08, green: 0.08, blue: 0.12)
    let accentColor = Color(red: 0.85, green: 0.70, blue: 0.30)

    func render(in context: GraphicsContext, size: CGSize) {
        // Fan pattern
        let spacing: CGFloat = 20
        for x in stride(from: 0, to: size.width, by: spacing) {
            for y in stride(from: 0, to: size.height, by: spacing) {
                for i in 1...3 {
                    let r = CGFloat(i) * 4
                    let arc = Path { p in
                        p.addArc(
                            center: CGPoint(x: x, y: y + spacing),
                            radius: r,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(0),
                            clockwise: false
                        )
                    }
                    context.stroke(arc, with: .color(accentColor.opacity(0.2)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - Table Themes

struct GreenFeltTable: TableTheme {
    let id = "green-felt"
    let displayName = "Green Felt"
    let isPremium = false
    let primaryColor = Color(red: 0.08, green: 0.38, blue: 0.18)
    let secondaryColor = Color(red: 0.05, green: 0.30, blue: 0.12)

    func drawTexture(in context: GraphicsContext, size: CGSize) {
        // Default felt noise (handled by FeltBackground)
    }
}

struct BlueFeltTable: TableTheme {
    let id = "blue-felt"
    let displayName = "Blue Felt"
    let isPremium = false
    let primaryColor = Color(red: 0.10, green: 0.18, blue: 0.40)
    let secondaryColor = Color(red: 0.06, green: 0.12, blue: 0.32)

    func drawTexture(in context: GraphicsContext, size: CGSize) {}
}

struct RedVelvetTable: TableTheme {
    let id = "red-velvet"
    let displayName = "Red Velvet"
    let isPremium = true
    let primaryColor = Color(red: 0.40, green: 0.08, blue: 0.10)
    let secondaryColor = Color(red: 0.30, green: 0.05, blue: 0.07)

    func drawTexture(in context: GraphicsContext, size: CGSize) {}
}

struct MahoganyTable: TableTheme {
    let id = "mahogany"
    let displayName = "Mahogany"
    let isPremium = true
    let primaryColor = Color(red: 0.35, green: 0.15, blue: 0.08)
    let secondaryColor = Color(red: 0.25, green: 0.10, blue: 0.05)

    func drawTexture(in context: GraphicsContext, size: CGSize) {}
}

// MARK: - Board Themes

struct ClassicWoodBoard: BoardTheme {
    let id = "classic-wood"
    let displayName = "Classic Wood"
    let isPremium = false
    let woodLight = Color(red: 0.63, green: 0.47, blue: 0.16)
    let woodDark = Color(red: 0.48, green: 0.35, blue: 0.10)
    let pegPlayerColor = Color(red: 0.37, green: 0.65, blue: 0.95)
    let pegOpponentColor = Color(red: 0.94, green: 0.35, blue: 0.35)
}

struct DarkWalnutBoard: BoardTheme {
    let id = "dark-walnut"
    let displayName = "Dark Walnut"
    let isPremium = false
    let woodLight = Color(red: 0.35, green: 0.25, blue: 0.14)
    let woodDark = Color(red: 0.22, green: 0.15, blue: 0.08)
    let pegPlayerColor = Color(red: 0.45, green: 0.75, blue: 1.0)
    let pegOpponentColor = Color(red: 1.0, green: 0.45, blue: 0.45)
}

struct MarbleBoard: BoardTheme {
    let id = "marble"
    let displayName = "Marble"
    let isPremium = true
    let woodLight = Color(red: 0.85, green: 0.83, blue: 0.80)
    let woodDark = Color(red: 0.70, green: 0.68, blue: 0.65)
    let pegPlayerColor = Color(red: 0.20, green: 0.50, blue: 0.80)
    let pegOpponentColor = Color(red: 0.80, green: 0.20, blue: 0.25)
}

struct GoldInlayBoard: BoardTheme {
    let id = "gold-inlay"
    let displayName = "Gold Inlay"
    let isPremium = true
    let woodLight = Color(red: 0.15, green: 0.12, blue: 0.10)
    let woodDark = Color(red: 0.08, green: 0.06, blue: 0.05)
    let pegPlayerColor = Color(red: 0.85, green: 0.70, blue: 0.30)
    let pegOpponentColor = Color(red: 0.90, green: 0.45, blue: 0.40)
}
