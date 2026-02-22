import SwiftUI

struct MainMenuView: View {
    @Environment(GameViewModel.self) private var viewModel
    @State private var pulsing = false

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 32) {
            Spacer()

            // Title area
            VStack(spacing: 12) {
                // Suit diamond decoration
                ZStack {
                    Text("♠").offset(y: -22)
                    Text("♥").offset(x: -22)
                    Text("♦").offset(y: 22)
                    Text("♣").offset(x: 22)
                }
                .font(.system(size: 20))
                .foregroundStyle(CribbageTheme.gold.opacity(0.6))
                .staggeredAppearance(index: 0)

                Text("CRIBBAGE")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundStyle(CribbageTheme.ivory)
                    .staggeredAppearance(index: 1)

                // Gold underline ornament
                RoundedRectangle(cornerRadius: 1)
                    .fill(CribbageTheme.goldGradient)
                    .frame(width: 80, height: 2)
                    .staggeredAppearance(index: 2)

                Text("Classic Card Game")
                    .font(.system(.subheadline, design: .serif))
                    .italic()
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                    .staggeredAppearance(index: 3)
            }

            Spacer()

            // Settings
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(CribbageTheme.gold)
                    TextField("Your Name", text: $vm.playerName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                    Picker("Difficulty", selection: $vm.difficultyRaw) {
                        ForEach(AIDifficulty.allCases) { diff in
                            Text(diff.displayName).tag(diff.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(CribbageTheme.woodDark.opacity(0.4))
            )
            .padding(.horizontal, 16)
            .staggeredAppearance(index: 4)

            // Play button
            Button {
                viewModel.newGame()
            } label: {
                Label("Play", systemImage: "play.fill")
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(CribbageTheme.feltGreenDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 18))
                    .shadow(
                        color: CribbageTheme.gold.opacity(pulsing ? 0.5 : 0.2),
                        radius: pulsing ? 10 : 4,
                        y: 2
                    )
            }
            .padding(.horizontal, 32)
            .staggeredAppearance(index: 5)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }

            // Stats and Settings row
            HStack(spacing: 24) {
                NavigationLink {
                    StatsView()
                } label: {
                    Label("Stats", systemImage: "chart.bar.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.8))
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.8))
                }
            }
            .staggeredAppearance(index: 6)

            Spacer()
        }
        .feltBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CribbageTheme.feltGreenDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
