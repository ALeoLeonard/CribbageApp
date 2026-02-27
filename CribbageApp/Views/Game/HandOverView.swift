import SwiftUI

/// Full-screen overlay shown between turns in pass-and-play mode.
/// Hides the previous player's cards while transitioning to the next player.
struct HandOverView: View {
    let playerName: String
    let onReady: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 44))
                    .foregroundStyle(CribbageTheme.gold.opacity(0.6))

                Text("Pass to")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.7))

                Text(playerName)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(CribbageTheme.ivory)

                Button(action: onReady) {
                    Text("Ready")
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(CribbageTheme.feltGreenDark)
                        .frame(width: 200)
                        .padding(.vertical, 14)
                        .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 18))
                        .shadow(color: CribbageTheme.gold.opacity(0.3), radius: 6, y: 2)
                }
                .padding(.top, 12)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }
}
