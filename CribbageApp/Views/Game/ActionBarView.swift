import SwiftUI

struct ActionBarView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        Group {
            switch viewModel.phase {
            case .discard:
                discardBar
            case .play:
                playBar
            case .countNonDealer, .countDealer, .countCrib:
                countBar
            case .gameOver:
                EmptyView()
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Discard Phase

    private var discardBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text(viewModel.hintMessage ?? "Select 2 cards for the crib")
                    .font(.subheadline)
                    .foregroundStyle(viewModel.hintMessage != nil ? CribbageTheme.gold : CribbageTheme.ivory)

                Spacer()

                if viewModel.hintsEnabled && !viewModel.isProcessing && viewModel.dealPhase == .ready {
                    hintButton
                }
            }

            Button {
                viewModel.discard()
            } label: {
                Label("Send to Crib", systemImage: "arrow.right.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CribbageTheme.feltGreenDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: CribbageTheme.gold.opacity(0.3), radius: 4, y: 2)
            }
            .accessibilityLabel("Send selected cards to crib")
            .disabled(viewModel.selectedIndices.count != 2 || viewModel.isProcessing)
            .opacity(viewModel.selectedIndices.count != 2 || viewModel.isProcessing ? 0.5 : 1)
        }
    }

    // MARK: - Play Phase

    private var playBar: some View {
        VStack(spacing: 8) {
            if viewModel.isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(CribbageTheme.gold)
                    Text(viewModel.statusMessage ?? "Computer is thinking...")
                        .font(.subheadline)
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                }
            } else if viewModel.yourTurn {
                if viewModel.humanCanPlay {
                    HStack {
                        Text(viewModel.hintMessage ?? "Tap a card to play it")
                            .font(.subheadline)
                            .foregroundStyle(viewModel.hintMessage != nil ? CribbageTheme.gold : CribbageTheme.ivory)

                        Spacer()

                        if viewModel.hintsEnabled {
                            hintButton
                        }
                    }
                } else {
                    Button {
                        viewModel.sayGo()
                    } label: {
                        Label("Say Go", systemImage: "hand.raised.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CribbageTheme.feltGreenDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.75, blue: 0.30),
                                        Color(red: 0.90, green: 0.60, blue: 0.20)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 4, y: 2)
                    }
                    .accessibilityLabel("Say Go")
                    .accessibilityHint("Pass your turn")
                }
            } else {
                Text("Waiting for computer...")
                    .font(.subheadline)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
            }
        }
    }

    // MARK: - Count Phase

    private var countBar: some View {
        VStack(spacing: 8) {
            phaseLabel

            if viewModel.mugginsPending && viewModel.mugginsResult == nil {
                mugginsClaimBar
            } else if let result = viewModel.mugginsResult {
                mugginsResultBar(result: result)
            } else {
                Button {
                    viewModel.acknowledge()
                } label: {
                    Label("Next", systemImage: "arrow.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CribbageTheme.feltGreenDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: CribbageTheme.gold.opacity(0.3), radius: 4, y: 2)
                }
                .accessibilityLabel("Continue to next phase")
                .disabled(viewModel.isProcessing)
                .opacity(viewModel.isProcessing ? 0.5 : 1)
            }
        }
    }

    // MARK: - Muggins Claim

    private var mugginsClaimBar: some View {
        VStack(spacing: 8) {
            Text("How many points do you count?")
                .font(.subheadline)
                .foregroundStyle(CribbageTheme.ivory)

            HStack(spacing: 16) {
                Button {
                    if viewModel.mugginsClaimedScore > 0 {
                        viewModel.mugginsClaimedScore -= 1
                        HapticManager.selection()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(CribbageTheme.ivory.opacity(viewModel.mugginsClaimedScore > 0 ? 0.8 : 0.3))
                }
                .disabled(viewModel.mugginsClaimedScore <= 0)

                Text("\(viewModel.mugginsClaimedScore)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(CribbageTheme.gold)
                    .frame(minWidth: 50)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.15), value: viewModel.mugginsClaimedScore)

                Button {
                    if viewModel.mugginsClaimedScore < 29 {
                        viewModel.mugginsClaimedScore += 1
                        HapticManager.selection()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(CribbageTheme.ivory.opacity(viewModel.mugginsClaimedScore < 29 ? 0.8 : 0.3))
                }
                .disabled(viewModel.mugginsClaimedScore >= 29)
            }

            Button {
                viewModel.submitMugginsClaim()
            } label: {
                Label("Claim \(viewModel.mugginsClaimedScore) Points", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CribbageTheme.feltGreenDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: CribbageTheme.gold.opacity(0.3), radius: 4, y: 2)
            }
        }
    }

    private func mugginsResultBar(result: MugginsResult) -> some View {
        VStack(spacing: 8) {
            if result.isPerfect {
                Label("Perfect count!", systemImage: "star.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CribbageTheme.gold)
            } else if result.mugginsPoints > 0 {
                VStack(spacing: 4) {
                    Label("Muggins!", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.red)
                    Text("You claimed \(result.claimedScore), actual was \(result.actualScore)")
                        .font(.caption)
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                    Text("Opponent claims \(result.mugginsPoints) points!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red.opacity(0.9))
                }
            } else if result.overClaimed {
                VStack(spacing: 4) {
                    Label("Overcounted", systemImage: "arrow.down.circle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.orange)
                    Text("You claimed \(result.claimedScore), actual was \(result.actualScore)")
                        .font(.caption)
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.7))
                }
            }

            Button {
                viewModel.acknowledge()
            } label: {
                Label("Continue", systemImage: "arrow.right.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CribbageTheme.feltGreenDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CribbageTheme.goldGradient, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: CribbageTheme.gold.opacity(0.3), radius: 4, y: 2)
            }
        }
    }

    // MARK: - Hint Button

    private var hintButton: some View {
        Button {
            viewModel.showHint()
        } label: {
            Image(systemName: "lightbulb.fill")
                .font(.subheadline)
                .foregroundStyle(viewModel.hintIndices.isEmpty ? CribbageTheme.ivory.opacity(0.6) : CribbageTheme.gold)
                .padding(8)
                .background(
                    Circle()
                        .fill(CribbageTheme.feltGreenDark.opacity(0.8))
                        .strokeBorder(
                            viewModel.hintIndices.isEmpty ? CribbageTheme.ivory.opacity(0.2) : CribbageTheme.gold.opacity(0.5),
                            lineWidth: 1
                        )
                )
        }
        .accessibilityLabel("Show hint")
    }

    private var phaseLabel: some View {
        Group {
            switch viewModel.phase {
            case .countNonDealer:
                Text("Count: \(viewModel.countPhasePlayerName)'s hand")
            case .countDealer:
                Text("Count: \(viewModel.countPhasePlayerName)'s hand")
            case .countCrib:
                Text("Count: \(viewModel.countPhasePlayerName)'s crib")
            default:
                EmptyView()
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(CribbageTheme.ivory)
    }
}
