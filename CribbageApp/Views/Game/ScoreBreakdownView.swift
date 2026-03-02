import SwiftUI

// MARK: - Muggins Hand View

/// Shows the hand cards during muggins claiming. Reveals score breakdown after claim.
struct MugginsHandView: View {
    let hand: [Card]
    let starter: Card?
    let result: MugginsResult?

    @State private var revealed = false

    var body: some View {
        VStack(spacing: 12) {
            // Show the hand + starter
            HStack(spacing: -8) {
                ForEach(hand) { card in
                    CardView(card: card, isSmall: true)
                }
                if let starter {
                    CardView(card: starter, isSmall: true)
                        .overlay(
                            RoundedRectangle(cornerRadius: CribbageTheme.cardCornerRadius)
                                .strokeBorder(CribbageTheme.gold, lineWidth: 2)
                        )
                }
            }

            if result == nil {
                // Counting prompt
                Text("Count your hand carefully...")
                    .font(.caption)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                    .italic()
            } else if let result {
                // Show muggins result summary
                if result.isPerfect {
                    Label("Perfect! \(result.actualScore) points", systemImage: "star.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CribbageTheme.gold)
                        .scorePop()
                } else if result.mugginsPoints > 0 {
                    VStack(spacing: 4) {
                        Text("Actual: \(result.actualScore) points")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(CribbageTheme.ivory)

                        Rectangle()
                            .fill(Color.red.opacity(0.4))
                            .frame(height: 1)

                        HStack {
                            Text("Muggins")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.red)
                            Spacer()
                            Text("-\(result.mugginsPoints) to opponent")
                                .font(.subheadline.bold())
                                .foregroundStyle(.red)
                        }
                    }
                } else if result.overClaimed {
                    Text("Actual: \(result.actualScore) points")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CribbageTheme.feltGreenDark.opacity(0.9))
                .strokeBorder(
                    (result?.mugginsPoints ?? 0) > 0
                        ? Color.red.opacity(0.5)
                        : CribbageTheme.gold.opacity(0.3),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.3), value: result?.actualScore)
    }
}

// MARK: - Score Breakdown View

struct ScoreBreakdownView: View {
    let breakdown: ScoreBreakdown

    @State private var currentItemIndex = -1
    @State private var highlightedCardIDs: Set<String> = []
    @State private var showTotal = false
    @State private var animationTask: Task<Void, Never>?

    private var allCards: [Card] {
        breakdown.hand + [breakdown.starter]
    }

    private var isFinished: Bool {
        currentItemIndex >= breakdown.items.count
    }

    var body: some View {
        VStack(spacing: 12) {
            // Show the hand + starter with highlight support
            HStack(spacing: -8) {
                ForEach(breakdown.hand) { card in
                    CardView(card: card, isSmall: true)
                        .offset(y: highlightedCardIDs.contains(card.id) ? -15 : 0)
                        .shadow(
                            color: highlightedCardIDs.contains(card.id)
                                ? CribbageTheme.gold.opacity(0.7) : .clear,
                            radius: highlightedCardIDs.contains(card.id) ? 8 : 0
                        )
                        .animation(.easeInOut(duration: 0.3), value: highlightedCardIDs)
                }
                CardView(card: breakdown.starter, isSmall: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: CribbageTheme.cardCornerRadius)
                            .strokeBorder(CribbageTheme.gold, lineWidth: 2)
                    )
                    .offset(y: highlightedCardIDs.contains(breakdown.starter.id) ? -15 : 0)
                    .shadow(
                        color: highlightedCardIDs.contains(breakdown.starter.id)
                            ? CribbageTheme.gold.opacity(0.7) : .clear,
                        radius: highlightedCardIDs.contains(breakdown.starter.id) ? 8 : 0
                    )
                    .animation(.easeInOut(duration: 0.3), value: highlightedCardIDs)
            }

            // Score items
            if breakdown.items.isEmpty {
                Text("No points")
                    .font(.subheadline)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(breakdown.items.enumerated()), id: \.element.id) { index, event in
                        if index <= currentItemIndex || isFinished {
                            HStack {
                                Text(event.reason)
                                    .font(.subheadline)
                                    .foregroundStyle(CribbageTheme.ivory)
                                Spacer()
                                Text("+\(event.points)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(CribbageTheme.gold)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: currentItemIndex)
            }

            // Divider + total (shown after all items revealed)
            if isFinished || breakdown.items.isEmpty {
                Rectangle()
                    .fill(CribbageTheme.gold.opacity(0.4))
                    .frame(height: 1)

                HStack {
                    Text("Total")
                        .font(.headline)
                        .foregroundStyle(CribbageTheme.ivory)
                    Spacer()
                    Text("\(breakdown.total)")
                        .font(.headline.bold())
                        .foregroundStyle(CribbageTheme.gold)
                }
                .scorePop()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CribbageTheme.feltGreenDark.opacity(0.9))
                .strokeBorder(CribbageTheme.gold.opacity(0.3), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            skipToEnd()
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }

    private func startAnimation() {
        guard !breakdown.items.isEmpty else {
            currentItemIndex = 0
            return
        }
        animationTask = Task { @MainActor in
            // Brief pause before starting
            try? await Task.sleep(for: .seconds(0.4))
            for index in 0..<breakdown.items.count {
                guard !Task.isCancelled else { return }
                let item = breakdown.items[index]
                // Highlight contributing cards
                withAnimation {
                    highlightedCardIDs = Set(item.cards.map(\.id))
                    currentItemIndex = index
                }
                // Hold the highlight
                try? await Task.sleep(for: .seconds(1.2))
            }
            guard !Task.isCancelled else { return }
            // Clear highlights and show total
            withAnimation {
                highlightedCardIDs = []
                currentItemIndex = breakdown.items.count
            }
        }
    }

    private func skipToEnd() {
        animationTask?.cancel()
        withAnimation {
            highlightedCardIDs = []
            currentItemIndex = breakdown.items.count
        }
    }
}
