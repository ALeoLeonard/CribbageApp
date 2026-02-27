import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section(title: "Overview", icon: "info.circle.fill") {
                    Text("Cribbage is a two-player card game where the goal is to be the first player to reach **121 points**. Points are scored by making card combinations during play and in your hand.")
                }

                section(title: "The Deal", icon: "rectangle.stack.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("Each player is dealt **6 cards**")
                        bulletPoint("Each player discards **2 cards** to the **crib** (4 extra cards scored by the dealer)")
                        bulletPoint("A **starter card** is cut from the deck")
                        bulletPoint("If the starter is a **Jack**, the dealer scores **2 points** (His Heels)")
                    }
                }

                section(title: "The Play (Pegging)", icon: "figure.walk") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Players alternate playing cards, keeping a running total up to 31:")
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.9))
                        bulletPoint("**15** — Score 2 points when the total reaches 15")
                        bulletPoint("**31** — Score 2 points when the total reaches exactly 31")
                        bulletPoint("**Pair** — Score 2 points for matching the last card's rank")
                        bulletPoint("**Three of a Kind** — Score 6 points")
                        bulletPoint("**Four of a Kind** — Score 12 points")
                        bulletPoint("**Run** — Score points equal to the run length (3+)")
                        bulletPoint("**Go** — If you can't play without exceeding 31, say \"Go\". Last player to play scores 1 point.")
                    }
                }

                section(title: "The Count", icon: "number.circle.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("After pegging, each player counts their 4-card hand plus the starter:")
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.9))
                        scoringRow("Fifteens", "2 pts each", "Any combination totaling 15")
                        scoringRow("Pairs", "2 pts each", "Two cards of the same rank")
                        scoringRow("Runs", "1 pt/card", "Three or more consecutive ranks")
                        scoringRow("Flush", "4-5 pts", "All cards same suit (4 in hand, 5 with starter)")
                        scoringRow("Nobs", "1 pt", "Jack in hand matching starter's suit")

                        Text("The **non-dealer counts first**, then the dealer, then the dealer counts the crib.")
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.9))
                            .padding(.top, 4)
                    }
                }

                section(title: "Winning", icon: "trophy.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("First player to **121 points** wins")
                        bulletPoint("**Skunk**: Winner at 121, loser below 91")
                        bulletPoint("**Double Skunk**: Winner at 121, loser below 61")
                        bulletPoint("The non-dealer counts first, which can matter in close games!")
                    }
                }

                section(title: "Strategy Tips", icon: "lightbulb.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("**Fives are valuable** — keep them in your hand, avoid putting them in your opponent's crib")
                        bulletPoint("**As dealer**, discard generously to your own crib")
                        bulletPoint("**As non-dealer**, avoid discarding pairs or cards that sum to 15 to the crib")
                        bulletPoint("**During pegging**, try to avoid leaving the count at 5 or 21")
                        bulletPoint("**Use the hint button** during play to see recommended moves")
                    }
                }
            }
            .padding()
        }
        .feltBackground()
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CribbageTheme.feltGreenDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Helpers

    private func section(title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(CribbageTheme.gold)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(CribbageTheme.gold)
            }

            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(CribbageTheme.feltGreenDark.opacity(0.8))
                .strokeBorder(CribbageTheme.gold.opacity(0.2), lineWidth: 1)
        )
    }

    private func bulletPoint(_ text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(CribbageTheme.gold)
            Text(text)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.9))
        }
        .font(.subheadline)
    }

    private func scoringRow(_ name: String, _ points: String, _ description: String) -> some View {
        HStack(alignment: .top) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CribbageTheme.ivory)
                .frame(width: 70, alignment: .leading)
            Text(points)
                .font(.caption.weight(.bold))
                .foregroundStyle(CribbageTheme.gold)
                .frame(width: 60, alignment: .leading)
            Text(description)
                .font(.caption)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
        }
    }
}
