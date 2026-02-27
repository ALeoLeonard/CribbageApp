import SwiftUI

/// Brief animated callout that pops when scoring happens during pegging.
/// Shows text like "15 for 2!", "Pair!", "Run of 3!" with a spring pop animation.
struct ScoringCalloutView: View {
    let text: String
    let points: Int

    @State private var appeared = false
    @State private var dismissed = false

    private var color: Color {
        switch points {
        case 0: return CribbageTheme.ivory
        case 1...2: return CribbageTheme.gold
        case 3...5: return Color.orange
        default: return Color.yellow
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: points >= 4 ? 18 : 15, weight: .bold, design: .serif))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.black.opacity(0.5))
                    .strokeBorder(color.opacity(0.6), lineWidth: 1)
            )
            .scaleEffect(appeared ? (dismissed ? 0.6 : 1.0) : 0.3)
            .opacity(dismissed ? 0 : (appeared ? 1 : 0))
            .offset(y: dismissed ? -20 : (appeared ? 0 : 10))
            .onAppear {
                withAnimation(.spring(duration: 0.3, bounce: 0.5)) {
                    appeared = true
                }
                withAnimation(.easeOut(duration: 0.3).delay(1.2)) {
                    dismissed = true
                }
            }
    }
}

/// Container that shows stacking callouts from the ViewModel.
struct ScoringCalloutContainerView: View {
    let callouts: [ScoringCallout]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(callouts) { callout in
                ScoringCalloutView(text: callout.text, points: callout.points)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .animation(.spring(duration: 0.3, bounce: 0.4), value: callouts.map(\.id))
    }
}

/// Model for a scoring callout
struct ScoringCallout: Identifiable {
    let id = UUID()
    let text: String
    let points: Int
}
