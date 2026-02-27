import SwiftUI

struct SettingsView: View {
    @AppStorage("playerName") private var playerName = "Player"
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") var hapticsEnabled = true
    @AppStorage("cardSort") private var cardSortRaw = CardSortPreference.dealt.rawValue
    @AppStorage("hintsEnabled") private var hintsEnabled = true

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

                // Gameplay section
                settingsCard(title: "Gameplay") {
                    VStack(spacing: 12) {
                        // Card sort
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundStyle(CribbageTheme.gold)
                                .frame(width: 24)
                            Text("Card Sort")
                                .foregroundStyle(CribbageTheme.ivory)
                            Spacer()
                            Picker("", selection: $cardSortRaw) {
                                ForEach(CardSortPreference.allCases, id: \.rawValue) { pref in
                                    Text(pref.rawValue).tag(pref.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(CribbageTheme.gold)
                        }

                        Toggle(isOn: $hintsEnabled) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(CribbageTheme.gold)
                                    .frame(width: 24)
                                Text("Show Hints")
                                    .foregroundStyle(CribbageTheme.ivory)
                            }
                        }
                        .tint(CribbageTheme.gold)
                    }
                }

                // Audio & Feedback section
                settingsCard(title: "Audio & Feedback") {
                    VStack(spacing: 12) {
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

                        Toggle(isOn: $hapticsEnabled) {
                            HStack {
                                Image(systemName: hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                    .foregroundStyle(CribbageTheme.gold)
                                    .frame(width: 24)
                                Text("Haptic Feedback")
                                    .foregroundStyle(CribbageTheme.ivory)
                            }
                        }
                        .tint(CribbageTheme.gold)
                    }
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
                            Text("Customize Themes")
                                .foregroundStyle(CribbageTheme.ivory)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                        }
                    }
                }

                // Tutorial section
                settingsCard(title: "Tutorial") {
                    Button {
                        UserDefaults.standard.set(false, forKey: "tutorialCompleted")
                    } label: {
                        settingsRow(icon: "graduationcap.fill", label: "Restart Tutorial")
                    }
                }

                // Support section
                settingsCard(title: "Support") {
                    VStack(spacing: 12) {
                        if let url = URL(string: "https://apps.apple.com/app/id0") { // placeholder
                            Link(destination: url) {
                                settingsRow(icon: "star.fill", label: "Rate on App Store")
                            }
                        }

                        if let url = URL(string: "https://example.com/privacy") { // placeholder
                            Link(destination: url) {
                                settingsRow(icon: "hand.raised.fill", label: "Privacy Policy")
                            }
                        }
                    }
                }

                // About section
                settingsCard(title: "About") {
                    VStack(spacing: 8) {
                        aboutRow(label: "Version", value: appVersion)
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

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

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

    private func settingsRow(icon: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(CribbageTheme.gold)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(CribbageTheme.ivory)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
        }
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
