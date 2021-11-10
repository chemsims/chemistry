//
// Reactions App
//

import SwiftUI
import ReactionsCore

class LimitingReagentFilingCabinetScreenViewModel: LimitingReagentScreenViewModel {

    override init(persistence: LimitingReagentPersistence) {
        super.init(persistence: persistence)
        let state = NavState(persistence: persistence)
        self.navigation = NavigationModel(model: self, states: [state])
    }
}

private class NavState: LimitingReagentScreenState {

    init(persistence: LimitingReagentPersistence) {
        self.persistence = persistence
    }

    let persistence: LimitingReagentPersistence

    override func apply(on model: LimitingReagentScreenViewModel) {
        model.statement = ["Check out the reaction you ran earlier!"]
        model.input = nil
        model.highlights.clear()
        model.equationState = .showActualData

        if let input = persistence.input,
            let reaction = LimitingReagentReaction.fromId(input.reactionId) {
            model.reaction = reaction
            model.components.runCompleteReaction(using: input)
        } else {
            model.components.runCompleteReaction()
        }
    }
}
