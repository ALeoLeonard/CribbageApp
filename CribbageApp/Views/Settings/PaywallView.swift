import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    private var store = StoreManager.shared
    @State private var isPurchasing = false

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(CribbageTheme.ivory.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 24) {
                    // Crown header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(CribbageTheme.goldGradient)

                        Text("Premium Upgrade")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundStyle(CribbageTheme.ivory)

                        Text("Unlock the full experience")
                            .font(.subheadline)
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                    }
                    .padding(.top, 24)

                    // Feature rows
                    VStack(spacing: 16) {
                        featureRow(
                            icon: "paintpalette.fill",
                            title: "All Premium Themes",
                            subtitle: "Card backs, tables, and boards"
                        )
                        featureRow(
                            icon: "eye.slash.fill",
                            title: "Remove Ads",
                            subtitle: "Enjoy uninterrupted gameplay"
                        )
                        featureRow(
                            icon: "heart.fill",
                            title: "Support Development",
                            subtitle: "Help us keep improving"
                        )
                    }
                    .padding(.horizontal, 24)

                    // Purchase button
                    Button {
                        isPurchasing = true
                        Task {
                            await store.purchase()
                            isPurchasing = false
                        }
                    } label: {
                        VStack(spacing: 4) {
                            if isPurchasing {
                                ProgressView()
                                    .tint(CribbageTheme.feltGreenDark)
                            } else {
                                Text(store.premiumProduct?.displayPrice ?? "$4.99")
                                    .font(.system(.title2, design: .serif).weight(.bold))
                                    .foregroundStyle(CribbageTheme.feltGreenDark)
                                Text("One-Time Purchase")
                                    .font(.caption)
                                    .foregroundStyle(CribbageTheme.feltGreenDark.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 18))
                        .shadow(color: CribbageTheme.gold.opacity(0.4), radius: 8, y: 3)
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal, 32)

                    // Error message
                    if let error = store.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Restore
                    Button {
                        Task { await store.restore() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
                    }

                    Spacer(minLength: 24)
                }
            }
        }
        .feltBackground()
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium {
                ThemeManager.shared.unlockAllPremiumThemes()
                dismiss()
            }
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(CribbageTheme.goldGradient)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .foregroundStyle(CribbageTheme.ivory)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(CribbageTheme.gold)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CribbageTheme.feltGreenDark.opacity(0.6))
                .strokeBorder(CribbageTheme.gold.opacity(0.15), lineWidth: 1)
        )
    }
}
