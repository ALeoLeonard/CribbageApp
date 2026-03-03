import SwiftUI

struct ThemePickerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Card Backs
                themeSection(title: CosmeticSlot.cardBack.displayName) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.cardBacks, id: \.id) { theme in
                                cardBackPreview(theme)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Card Fronts
                themeSection(title: CosmeticSlot.cardFront.displayName) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.items(for: .cardFront).compactMap { $0 as? CardFrontCosmeticItem }, id: \.id) { item in
                                cardFrontPreview(item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Tables
                themeSection(title: CosmeticSlot.table.displayName) {
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
                themeSection(title: CosmeticSlot.board.displayName) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.boards, id: \.id) { theme in
                                boardPreview(theme)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Peg Colors
                themeSection(title: CosmeticSlot.peg.displayName) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(themeManager.items(for: .peg).compactMap { $0 as? PegThemeCosmeticItem }, id: \.id) { item in
                                pegPreview(item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Phrase Packs
                themeSection(title: CosmeticSlot.phrasePack.displayName) {
                    VStack(spacing: 8) {
                        ForEach(themeManager.items(for: .phrasePack).compactMap { $0 as? PhrasePackCosmeticItem }, id: \.id) { item in
                            phrasePackRow(item)
                        }
                    }
                    .padding(.horizontal)
                }

                // Sound Packs
                themeSection(title: CosmeticSlot.soundPack.displayName) {
                    VStack(spacing: 8) {
                        ForEach(themeManager.items(for: .soundPack).compactMap { $0 as? SoundPackCosmeticItem }, id: \.id) { item in
                            soundPackRow(item)
                        }
                    }
                    .padding(.horizontal)
                }

                // Haptic Packs
                themeSection(title: CosmeticSlot.hapticPack.displayName) {
                    VStack(spacing: 8) {
                        ForEach(themeManager.items(for: .hapticPack).compactMap { $0 as? HapticPackCosmeticItem }, id: \.id) { item in
                            hapticPackRow(item)
                        }
                    }
                    .padding(.horizontal)
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
        let item = themeManager.items(for: .cardBack).first { $0.id == theme.id }

        return Button {
            if isLocked {
                handleLockedTap(item)
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
                        lockOverlay(for: item?.unlockCondition ?? .premium)
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

    // MARK: - Card Front Preview

    private func cardFrontPreview(_ item: CardFrontCosmeticItem) -> some View {
        let theme = item.theme
        let isActive = themeManager.equippedID(for: .cardFront) == item.id
        let isLocked = !themeManager.isUnlocked(item.id)

        return Button {
            if isLocked {
                handleLockedTap(item)
            } else {
                themeManager.equip(item.id, in: .cardFront)
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.backgroundGradient)
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(theme.borderColor, lineWidth: theme.borderWidth)
                            .padding(2)
                        Text("A\u{2660}")
                            .font(.system(size: 18, weight: theme.rankFontWeight == .bold ? .bold : .semibold))
                            .foregroundStyle(theme.suitColor(for: .spades))
                    }
                    .frame(width: 60, height: 84)

                    if isLocked {
                        lockOverlay(for: item.unlockCondition)
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

                Text(item.displayName)
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
        let item = themeManager.items(for: .table).first { $0.id == theme.id }

        return Button {
            if isLocked {
                handleLockedTap(item)
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
                        lockOverlay(for: item?.unlockCondition ?? .premium)
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
        let item = themeManager.items(for: .board).first { $0.id == theme.id }

        return Button {
            if isLocked {
                handleLockedTap(item)
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
                        lockOverlay(for: item?.unlockCondition ?? .premium)
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

    // MARK: - Peg Preview

    private func pegPreview(_ item: PegThemeCosmeticItem) -> some View {
        let theme = item.theme
        let isActive = themeManager.equippedID(for: .peg) == item.id
        let isLocked = !themeManager.isUnlocked(item.id)

        return Button {
            if isLocked {
                handleLockedTap(item)
            } else {
                themeManager.equip(item.id, in: .peg)
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.15))
                        .frame(width: 70, height: 50)
                        .overlay {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(theme.playerColor)
                                    .frame(width: 18, height: 18)
                                    .shadow(color: theme.playerGlowColor.opacity(0.7), radius: 4)
                                Circle()
                                    .fill(theme.opponentColor)
                                    .frame(width: 18, height: 18)
                                    .shadow(color: theme.opponentGlowColor.opacity(0.7), radius: 4)
                            }
                        }

                    if isLocked {
                        lockOverlay(for: item.unlockCondition)
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

                Text(item.displayName)
                    .font(.caption2)
                    .foregroundStyle(CribbageTheme.ivory.opacity(isLocked ? 0.5 : 1))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Phrase Pack Row

    private func phrasePackRow(_ item: PhrasePackCosmeticItem) -> some View {
        let isActive = themeManager.equippedID(for: .phrasePack) == item.id
        let isLocked = !themeManager.isUnlocked(item.id)
        let sampleFifteen = item.pack.phrases(for: .fifteen).first ?? ""
        let sampleWin = item.pack.phrases(for: .win).first ?? ""

        return Button {
            if isLocked {
                handleLockedTap(item)
            } else {
                themeManager.equip(item.id, in: .phrasePack)
                HapticManager.selection()
            }
        } label: {
            HStack(spacing: 12) {
                radioIndicator(isActive: isActive)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(item.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(CribbageTheme.ivory)
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                        }
                    }
                    Text("\"\(sampleFifteen)\" · \"\(sampleWin)\"")
                        .font(.caption2)
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? CribbageTheme.gold.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sound Pack Row

    private func soundPackRow(_ item: SoundPackCosmeticItem) -> some View {
        let isActive = themeManager.equippedID(for: .soundPack) == item.id
        let isLocked = !themeManager.isUnlocked(item.id)

        return Button {
            if isLocked {
                handleLockedTap(item)
            } else {
                themeManager.equip(item.id, in: .soundPack)
                HapticManager.selection()
            }
        } label: {
            HStack(spacing: 12) {
                radioIndicator(isActive: isActive)

                HStack(spacing: 4) {
                    Text(item.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory)
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                    }
                }

                Spacer()

                if !isLocked {
                    Button {
                        item.pack.playCardPlace(using: SoundManager.shared)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(CribbageTheme.gold)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? CribbageTheme.gold.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Haptic Pack Row

    private func hapticPackRow(_ item: HapticPackCosmeticItem) -> some View {
        let isActive = themeManager.equippedID(for: .hapticPack) == item.id
        let isLocked = !themeManager.isUnlocked(item.id)

        return Button {
            if isLocked {
                handleLockedTap(item)
            } else {
                themeManager.equip(item.id, in: .hapticPack)
                HapticManager.selection()
            }
        } label: {
            HStack(spacing: 12) {
                radioIndicator(isActive: isActive)

                HStack(spacing: 4) {
                    Text(item.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory)
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                    }
                }

                Spacer()

                if !isLocked {
                    Button {
                        item.pack.mediumImpact()
                    } label: {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(CribbageTheme.gold)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? CribbageTheme.gold.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Radio Indicator

    private func radioIndicator(isActive: Bool) -> some View {
        Circle()
            .fill(isActive ? CribbageTheme.gold : Color.clear)
            .frame(width: 14, height: 14)
            .overlay(
                Circle()
                    .strokeBorder(isActive ? CribbageTheme.gold : CribbageTheme.ivory.opacity(0.4), lineWidth: 1.5)
            )
    }

    // MARK: - Lock Overlay

    private func lockOverlay(for condition: UnlockCondition) -> some View {
        let label: String = switch condition {
        case .premium: "Premium"
        case .achievement: "Achievement"
        default: "Locked"
        }

        return ZStack {
            Color.black.opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(spacing: 2) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.8))
                Text(label)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(CribbageTheme.gold)
            }
        }
    }

    // MARK: - Locked Tap Handler

    private func handleLockedTap(_ item: (any CosmeticItem)?) {
        HapticManager.invalidAction()
        if item?.isPremium == true {
            showPaywall = true
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
