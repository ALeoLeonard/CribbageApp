import SwiftUI

struct CribbageBoardView: View {
    let playerScore: Int
    let opponentScore: Int

    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.cardScale) private var cardScale

    // Layout constants (scaled for iPad)
    private var boardHeight: CGFloat { 80 * cardScale }
    private let hPad: CGFloat = 16
    private var topRowY: CGFloat { 24 * cardScale }
    private var bottomRowY: CGFloat { 56 * cardScale }
    private var holeRadius: CGFloat { 2.2 * cardScale }
    private var majorHoleRadius: CGFloat { 3.0 * cardScale }
    private var pegRadius: CGFloat { 5.5 * cardScale }
    private let holesPerRow = 60

    @State private var pegPulse = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let trackW = w - hPad * 2
            let board = themeManager.activeBoard

            ZStack {
                // Wood board background
                boardBackground(board: board)

                // Wood grain lines
                Canvas { context, size in
                    for yOff in [14.0, 30.0, 48.0, 64.0] {
                        var path = Path()
                        path.move(to: CGPoint(x: 12, y: yOff))
                        path.addLine(to: CGPoint(x: size.width - 12, y: yOff + 2))
                        context.stroke(
                            path,
                            with: .color(board.woodDark.opacity(0.15)),
                            lineWidth: 0.5
                        )
                    }
                }
                .allowsHitTesting(false)

                // Center dividing line
                Rectangle()
                    .fill(board.woodDark.opacity(0.25))
                    .frame(height: 1)
                    .padding(.horizontal, 12)
                    .offset(y: 0)

                // Holes — top row (0→60, left to right)
                ForEach(0...holesPerRow, id: \.self) { i in
                    let x = hPad + (trackW * CGFloat(i) / CGFloat(holesPerRow))
                    let isMilestone = i > 0 && i % 30 == 0
                    let isFive = i > 0 && i % 5 == 0

                    Circle()
                        .fill(board.woodDark.opacity(isMilestone ? 0.6 : 0.35))
                        .frame(
                            width: (isMilestone ? majorHoleRadius : (isFive ? holeRadius + 0.4 : holeRadius)) * 2,
                            height: (isMilestone ? majorHoleRadius : (isFive ? holeRadius + 0.4 : holeRadius)) * 2
                        )
                        .position(x: x, y: topRowY)
                }

                // Holes — bottom row (61→121, right to left)
                ForEach(0...holesPerRow, id: \.self) { i in
                    let hole = i + holesPerRow
                    let x = hPad + trackW - (trackW * CGFloat(i) / CGFloat(holesPerRow))
                    let isMilestone = hole % 30 == 0
                    let isFive = hole % 5 == 0

                    Circle()
                        .fill(board.woodDark.opacity(isMilestone ? 0.6 : 0.35))
                        .frame(
                            width: (isMilestone ? majorHoleRadius : (isFive ? holeRadius + 0.4 : holeRadius)) * 2,
                            height: (isMilestone ? majorHoleRadius : (isFive ? holeRadius + 0.4 : holeRadius)) * 2
                        )
                        .position(x: x, y: bottomRowY)
                }

                // Skunk lines at 61 and 91
                skunkLine(at: 61, trackW: trackW, label: "S")
                skunkLine(at: 91, trackW: trackW, label: "S")

                // Milestone labels
                milestoneLabels(trackW: trackW)

                // Start / finish labels
                Text("S")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                    .position(x: hPad, y: boardHeight / 2)

                Text("121")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(CribbageTheme.gold.opacity(0.7))
                    .position(x: hPad + trackW * CGFloat(holesPerRow) / CGFloat(holesPerRow) + 1, y: bottomRowY + 14)

                // Player peg
                pegView(
                    score: playerScore,
                    color: board.pegPlayerColor,
                    glowColor: .blue,
                    trackW: trackW,
                    yOffset: -3
                )

                // Opponent peg
                pegView(
                    score: opponentScore,
                    color: board.pegOpponentColor,
                    glowColor: .red,
                    trackW: trackW,
                    yOffset: 3
                )
            }
        }
        .frame(height: boardHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cribbage board. You: \(playerScore). Opponent: \(opponentScore).")
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pegPulse = true
            }
        }
    }

    // MARK: - Board Background

    private func boardBackground(board: any BoardTheme) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        board.woodLight,
                        board.woodLight.opacity(0.9),
                        board.woodDark
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                board.woodDark.opacity(0.6),
                                board.woodDark.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }

    // MARK: - Milestone Labels

    private func milestoneLabels(trackW: CGFloat) -> some View {
        Group {
            Text("30")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(CribbageTheme.gold.opacity(0.7))
                .position(
                    x: hPad + trackW * 30 / CGFloat(holesPerRow),
                    y: topRowY - 10
                )

            Text("60")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(CribbageTheme.gold.opacity(0.7))
                .position(
                    x: hPad + trackW * 60 / CGFloat(holesPerRow),
                    y: topRowY - 10
                )

            Text("90")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(CribbageTheme.gold.opacity(0.7))
                .position(
                    x: hPad + trackW - trackW * 30 / CGFloat(holesPerRow),
                    y: bottomRowY + 12
                )

            Text("120")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(CribbageTheme.gold.opacity(0.7))
                .position(
                    x: hPad + trackW - trackW * 60 / CGFloat(holesPerRow),
                    y: bottomRowY + 12
                )
        }
    }

    // MARK: - Skunk Lines

    private func skunkLine(at score: Int, trackW: CGFloat, label: String) -> some View {
        let pos = pegPositionForSkunk(score: score, trackW: trackW)
        return Group {
            // Vertical tick mark
            Rectangle()
                .fill(.red.opacity(0.35))
                .frame(width: 1.5, height: 18 * cardScale)
                .position(x: pos.x, y: pos.y)
        }
    }

    private func pegPositionForSkunk(score: Int, trackW: CGFloat) -> CGPoint {
        if score <= holesPerRow {
            let x = hPad + trackW * CGFloat(score) / CGFloat(holesPerRow)
            return CGPoint(x: x, y: topRowY)
        } else {
            let bottomHole = score - holesPerRow
            let x = hPad + trackW - trackW * CGFloat(bottomHole) / CGFloat(holesPerRow)
            return CGPoint(x: x, y: bottomRowY)
        }
    }

    // MARK: - Peg

    private func pegView(
        score: Int,
        color: Color,
        glowColor: Color,
        trackW: CGFloat,
        yOffset: CGFloat
    ) -> some View {
        let clampedScore = min(score, 121)
        let pos = pegPosition(score: clampedScore, trackW: trackW)

        return ZStack {
            // Trail glow that follows the peg
            Circle()
                .fill(glowColor.opacity(0.2))
                .frame(width: pegRadius * 4, height: pegRadius * 4)
                .blur(radius: 4)
                .position(x: pos.x, y: pos.y + yOffset)
                .animation(.spring(duration: 0.8, bounce: 0.2), value: score)

            // Main peg
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.8)],
                        center: .center,
                        startRadius: 0,
                        endRadius: pegRadius
                    )
                )
                .frame(
                    width: pegRadius * 2 * (pegPulse ? 1.15 : 1.0),
                    height: pegRadius * 2 * (pegPulse ? 1.15 : 1.0)
                )
                .shadow(color: glowColor.opacity(pegPulse ? 0.8 : 0.3), radius: pegPulse ? 6 : 3)
                .position(x: pos.x, y: pos.y + yOffset)
                .animation(.spring(duration: 0.6, bounce: 0.3), value: score)
        }
    }

    private func pegPosition(score: Int, trackW: CGFloat) -> CGPoint {
        if score <= holesPerRow {
            let x = hPad + trackW * CGFloat(score) / CGFloat(holesPerRow)
            return CGPoint(x: x, y: topRowY)
        } else {
            let bottomHole = score - holesPerRow
            let x = hPad + trackW - trackW * CGFloat(bottomHole) / CGFloat(holesPerRow)
            return CGPoint(x: x, y: bottomRowY)
        }
    }
}
