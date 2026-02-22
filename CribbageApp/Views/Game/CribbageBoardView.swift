import SwiftUI

struct CribbageBoardView: View {
    let playerScore: Int
    let opponentScore: Int

    @Environment(ThemeManager.self) private var themeManager

    // Layout constants
    private let boardHeight: CGFloat = 80
    private let hPad: CGFloat = 16
    private let topRowY: CGFloat = 24
    private let bottomRowY: CGFloat = 56
    private let holeRadius: CGFloat = 2.2
    private let majorHoleRadius: CGFloat = 3.0
    private let pegRadius: CGFloat = 5.5
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

        return Circle()
            .fill(color)
            .frame(
                width: pegRadius * 2 * (pegPulse ? 1.15 : 1.0),
                height: pegRadius * 2 * (pegPulse ? 1.15 : 1.0)
            )
            .shadow(color: glowColor.opacity(pegPulse ? 0.7 : 0.3), radius: pegPulse ? 6 : 3)
            .position(x: pos.x, y: pos.y + yOffset)
            .animation(.easeOut(duration: 0.7), value: score)
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
