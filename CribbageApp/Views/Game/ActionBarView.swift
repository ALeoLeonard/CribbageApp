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
            Text("Select 2 cards for the crib")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.discard()
            } label: {
                Label("Send to Crib", systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.selectedIndices.count != 2 || viewModel.isProcessing)
        }
    }

    // MARK: - Play Phase

    private var playBar: some View {
        VStack(spacing: 8) {
            if viewModel.isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(viewModel.statusMessage ?? "Computer is thinking...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if viewModel.yourTurn {
                if viewModel.humanCanPlay {
                    Text("Tap a card to play it")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Button {
                        viewModel.sayGo()
                    } label: {
                        Label("Say Go", systemImage: "hand.raised.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            } else {
                Text("Waiting for computer...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isProcessing)
        }
    }

    private var phaseLabel: some View {
        Group {
            switch viewModel.phase {
            case .countNonDealer:
                Text("Count: \(viewModel.engine?.nonDealer.name ?? "")'s hand")
            case .countDealer:
                Text("Count: \(viewModel.engine?.dealer.name ?? "")'s hand")
            case .countCrib:
                Text("Count: \(viewModel.engine?.dealer.name ?? "")'s crib")
            default:
                EmptyView()
            }
        }
        .font(.subheadline.weight(.medium))
    }
}
