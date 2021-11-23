//
// Reactions App
//

import SwiftUI
import ReactionsCore

class PrecipitationFilingCabinetScreenViewModel: PrecipitationScreenViewModel {

    override init(persistence: PrecipitationInputPersistence) {
        super.init(persistence: persistence)
        let state = NavState(persistence: persistence)
        self.navigation = NavigationModel(model: self, states: [state])
    }

    // These overrides are here in case we decide to let user weigh
    // the precipitate again
    override var beakerToggleIsDisabled: Bool {
        false
    }
    override var nextIsDisabled: Bool {
        true
    }

    override func runReactionAgain() {
        withAnimation(.linear(duration: 0)) {
            components.resetReaction()
        }
        withAnimation(.linear(duration: 3)) {
            components.completeReaction()
        }
    }
}

private class NavState: PrecipitationScreenState {

    init(persistence: PrecipitationInputPersistence) {
        self.persistence = persistence
    }

    let persistence: PrecipitationInputPersistence

    override func apply(on model: PrecipitationScreenViewModel) {
        model.statement = PrecipitationStatements.filingCabinet
        model.input = nil
        model.highlights.clear()
        model.equationState = .showAll
        model.showUnknownMetal = true
        model.showReRunReactionButton = true
        if let componentInput = persistence.input, let reaction = persistence.reaction {
            model.chosenReaction = reaction
            model.rows = CGFloat(componentInput.rows)
            model.components.runCompleteReaction(using: componentInput)
        } else {
            model.components.runCompleteReaction()
        }
    }
}
