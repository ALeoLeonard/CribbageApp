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
            .disabled(viewModel.isProcessing)
            .opacity(viewModel.isProcessing ? 0.5 : 1)
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
