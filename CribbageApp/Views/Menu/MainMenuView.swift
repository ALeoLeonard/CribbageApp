import SwiftUI

struct MainMenuView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 32) {
            Spacer()

            // Title
            VStack(spacing: 8) {
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)
                Text("Cribbage")
                    .font(.largeTitle.bold())
                Text("Classic Card Game")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Settings
            VStack(spacing: 16) {
                // Player name
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                    TextField("Your Name", text: $vm.playerName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // Difficulty picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Picker("Difficulty", selection: $vm.difficultyRaw) {
                        ForEach(AIDifficulty.allCases) { diff in
                            Text(diff.displayName).tag(diff.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
            }

            // Play button
            Button {
                viewModel.newGame()
            } label: {
                Label("Play", systemImage: "play.fill")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
