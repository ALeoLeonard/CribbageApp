import SwiftUI

struct SettingsView: View {
    @AppStorage("playerName") private var playerName = "Player"
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        Form {
            Section("Player") {
                TextField("Name", text: $playerName)
            }

            Section("Audio") {
                Toggle("Sound Effects", isOn: $soundEnabled)
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Game", value: "Cribbage")
            }
        }
        .navigationTitle("Settings")
    }
}
