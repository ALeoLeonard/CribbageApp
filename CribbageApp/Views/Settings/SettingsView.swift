import SwiftUI

struct SettingsView: View {
    @AppStorage("playerName") private var playerName = "Player"
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Player section
                settingsCard(title: "Player") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(CribbageTheme.gold)
                            .frame(width: 24)
                        TextField("Name", text: $playerName)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                // Audio section
                settingsCard(title: "Audio") {
                    Toggle(isOn: $soundEnabled) {
                        HStack {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundStyle(CribbageTheme.gold)
                                .frame(width: 24)
                            Text("Sound Effects")
                                .foregroundStyle(CribbageTheme.ivory)
                        }
                    }
                    .tint(CribbageTheme.gold)
                }

                // Customize section
                settingsCard(title: "Appearance") {
                    NavigationLink {
                        ThemePickerView()
                    } label: {
                        HStack {
                            Image(systemName: "paintpalette.fill")
                                .foregroundStyle(CribbageTheme.gold)
                                .frame(width: 24)
                            Text("Customize")
                                .foregroundStyle(CribbageTheme.ivory)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                        }
                    }
                }

                // About section
                settingsCard(title: "About") {
                    VStack(spacing: 8) {
                        aboutRow(label: "Version", value: "1.0.0")
                        aboutRow(label: "Game", value: "Cribbage")
                        aboutRow(label: "Target Score", value: "121")
                    }
                }
            }
            .padding(.vertical)
        }
        .feltBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CribbageTheme.feltGreenDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Helpers

    private func settingsCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CribbageTheme.gold)

            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(CribbageTheme.feltGreenDark.opacity(0.8))
                .strokeBorder(CribbageTheme.gold.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CribbageTheme.ivory)
        }
    }
}
