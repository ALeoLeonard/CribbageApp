import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last updated: March 1, 2026")
                    .font(.caption)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.5))

                section(title: "Overview", "Cribbage respects your privacy. We do not collect, store, or share any personal information. This policy explains what limited data interactions exist within the app.")

                section(title: "Analytics", "We use TelemetryDeck, a privacy-friendly analytics service, to understand general app usage patterns (e.g., games played, features used). TelemetryDeck does not collect any personally identifiable information (PII), does not use advertising identifiers, and does not track users across apps.")

                section(title: "iCloud Sync", "If you have iCloud enabled, your game statistics are synced across your devices using iCloud Key-Value Storage. This data stays within your personal iCloud account and is not accessible to us.")

                section(title: "Game Center", "Leaderboards and achievements are managed by Apple's Game Center. Your Game Center display name and scores are handled entirely by Apple under their privacy policy.")

                section(title: "Data Storage", "All game data, settings, and statistics are stored locally on your device. We have no servers and do not transmit your data to any third party.")

                section(title: "Children's Privacy", "Cribbage does not knowingly collect any information from children. The app contains no user accounts, no social features, and no data collection.")

                section(title: "Contact", "If you have questions about this privacy policy, please contact us through the App Store.")
            }
            .padding()
        }
        .feltBackground()
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CribbageTheme.feltGreenDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func section(title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(CribbageTheme.gold)
            Text(text)
                .font(.body)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
