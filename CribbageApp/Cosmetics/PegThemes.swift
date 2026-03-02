import SwiftUI

// MARK: - Classic Peg

struct ClassicPeg: PegTheme {
    let id = "classic-peg"
    let displayName = "Classic"
    let playerColor = Color.blue
    let opponentColor = Color.red
    let playerGlowColor = Color.blue
    let opponentGlowColor = Color.red
}

// MARK: - Brass Peg

struct BrassPeg: PegTheme {
    let id = "brass-peg"
    let displayName = "Brass"
    let playerColor = Color(red: 0.80, green: 0.65, blue: 0.20)
    let opponentColor = Color(red: 0.72, green: 0.45, blue: 0.20)
    let playerGlowColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let opponentGlowColor = Color(red: 0.80, green: 0.50, blue: 0.20)
}

// MARK: - Ivory Peg

struct IvoryPeg: PegTheme {
    let id = "ivory-peg"
    let displayName = "Ivory"
    let playerColor = Color(red: 1.0, green: 0.97, blue: 0.90)
    let opponentColor = Color(red: 0.35, green: 0.38, blue: 0.42)
    let playerGlowColor = Color(red: 1.0, green: 0.95, blue: 0.80)
    let opponentGlowColor = Color.gray
}

// MARK: - Ruby Peg

struct RubyPeg: PegTheme {
    let id = "ruby-peg"
    let displayName = "Ruby"
    let playerColor = Color(red: 0.72, green: 0.05, blue: 0.15)
    let opponentColor = Color(red: 0.15, green: 0.25, blue: 0.75)
    let playerGlowColor = Color.red
    let opponentGlowColor = Color.blue
}

// MARK: - Jade Peg

struct JadePeg: PegTheme {
    let id = "jade-peg"
    let displayName = "Jade"
    let playerColor = Color(red: 0.0, green: 0.66, blue: 0.42)
    let opponentColor = Color(red: 0.85, green: 0.65, blue: 0.13)
    let playerGlowColor = Color.green
    let opponentGlowColor = Color(red: 1.0, green: 0.75, blue: 0.0)
}

// MARK: - Obsidian Peg

struct ObsidianPeg: PegTheme {
    let id = "obsidian-peg"
    let displayName = "Obsidian"
    let playerColor = Color(red: 0.75, green: 0.75, blue: 0.78)
    let opponentColor = Color(red: 0.35, green: 0.10, blue: 0.55)
    let playerGlowColor = Color(red: 0.85, green: 0.85, blue: 0.90)
    let opponentGlowColor = Color.purple
}
