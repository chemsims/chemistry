//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BalancedReactionFilingCabinetScreenViewModel: BalancedReactionScreenViewModel {
    override init() {
        super.init()
        self.navigation = NavigationModel(model: self, states: [NavState()])
        self.inputState = .selectReaction
    }

    @Published var reactionSelectionIsToggled: Bool = true

    override var reactionToggleIndicatorIsDisabled: Bool {
        false
    }

    override var canGoNext: Bool {
        true
    }

    override var reactionToggleBinding: Binding<Bool> {
        Binding(
            get: {
                self.reactionSelectionIsToggled
            },
            set: {
                self.reactionSelectionIsToggled = $0
            }
        )
    }

    override func didSelectReaction() {
        reactionSelectionIsToggled = false
        moleculePosition = .init(reaction: reaction, isBalanced: true)
    }
}

private class NavState: BalancedReactionScreenState {
    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = BalancedReactionStatements.filingCabinet
    }
}
