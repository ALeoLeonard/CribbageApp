import SwiftUI

struct ThemePickerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Card Backs
                themeSection(title: "Card Backs") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.cardBacks, id: \.id) { theme in
                                cardBackPreview(theme)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Tables
                themeSection(title: "Tables") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.tables, id: \.id) { theme in
                                tablePreview(theme)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Boards
                themeSection(title: "Boards") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.boards, id: \.id) { theme in
                                boardPreview(theme)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .feltBackground()
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CribbageTheme.feltGreenDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Section

    private func themeSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CribbageTheme.gold)
                Text("Changes apply instantly")
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
            }
            .padding(.horizontal)
            content()
        }
    }

    // MARK: - Card Back Preview

    private func cardBackPreview(_ theme: any CardBackTheme) -> some View {
        let isActive = themeManager.activeCardBackID == theme.id
        let isLocked = !themeManager.isUnlocked(theme.id)

        return Button {
            if isLocked {
                HapticManager.invalidAction()
                showPaywall = true
            } else {
                themeManager.selectCardBack(theme.id)
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // Card back preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.primaryColor)
                        Canvas { context, size in
                            theme.render(in: context, size: size)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6).inset(by: 2))
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(theme.accentColor.opacity(0.25), lineWidth: 1)
                            .padding(2)
                    }
                    .frame(width: 60, height: 84)

                    if isLocked {
                        lockOverlay
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isActive ? CribbageTheme.gold : .clear, lineWidth: 2)
                )
                .overlay(alignment: .bottomTrailing) {
                    if isActive {
                        checkmarkBadge
                    }
                }

                Text(theme.displayName)
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(isLocked ? 0.5 : 1))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Table Preview

    private func tablePreview(_ theme: any TableTheme) -> some View {
        let isActive = themeManager.activeTableID == theme.id
        let isLocked = !themeManager.isUnlocked(theme.id)

        return Button {
            if isLocked {
                HapticManager.invalidAction()
                showPaywall = true
            } else {
                themeManager.selectTable(theme.id)
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [theme.secondaryColor, theme.primaryColor, theme.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 60)

                    if isLocked {
                        lockOverlay
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isActive ? CribbageTheme.gold : .clear, lineWidth: 2)
                )
                .overlay(alignment: .bottomTrailing) {
                    if isActive {
                        checkmarkBadge
                    }
                }

                Text(theme.displayName)
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(isLocked ? 0.5 : 1))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Board Preview

    private func boardPreview(_ theme: any BoardTheme) -> some View {
        let isActive = themeManager.activeBoardID == theme.id
        let isLocked = !themeManager.isUnlocked(theme.id)

        return Button {
            if isLocked {
                HapticManager.invalidAction()
                showPaywall = true
            } else {
                themeManager.selectBoard(theme.id)
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // Mini board preview
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [theme.woodLight, theme.woodDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 80, height: 40)
                        .overlay {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(theme.pegPlayerColor)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(theme.pegOpponentColor)
                                    .frame(width: 8, height: 8)
                            }
                        }

                    if isLocked {
                        lockOverlay
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isActive ? CribbageTheme.gold : .clear, lineWidth: 2)
                )
                .overlay(alignment: .bottomTrailing) {
                    if isActive {
                        checkmarkBadge
                    }
                }

                Text(theme.displayName)
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(isLocked ? 0.5 : 1))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lock Overlay

    private var lockOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(spacing: 2) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Premium")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(CribbageTheme.gold)
            }
        }
    }

    // MARK: - Checkmark Badge

    private var checkmarkBadge: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 16))
            .foregroundStyle(CribbageTheme.gold)
            .background(Circle().fill(CribbageTheme.feltGreenDark).padding(2))
            .offset(x: 4, y: 4)
    }
}
