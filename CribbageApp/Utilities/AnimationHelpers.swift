import SwiftUI

// MARK: - Staggered Appearance

struct StaggeredAppearance: ViewModifier {
    let index: Int
    let delay: Double
    @State private var appeared = false

    init(index: Int, delay: Double = 0.08) {
        self.index = index
        self.delay = delay
    }

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(
                .easeOut(duration: 0.35).delay(Double(index) * delay),
                value: appeared
            )
            .onAppear { appeared = true }
    }
}

// MARK: - Score Pop

struct ScorePop: ViewModifier {
    @State private var popped = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(popped ? 1 : 0.5)
            .opacity(popped ? 1 : 0)
            .animation(.spring(duration: 0.4, bounce: 0.4), value: popped)
            .onAppear { popped = true }
    }
}

// MARK: - View extensions

extension View {
    func staggeredAppearance(index: Int, delay: Double = 0.08) -> some View {
        modifier(StaggeredAppearance(index: index, delay: delay))
    }

    func scorePop() -> some View {
        modifier(ScorePop())
    }
}
