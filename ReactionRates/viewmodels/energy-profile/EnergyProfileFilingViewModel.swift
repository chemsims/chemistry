//
// Reactions App
//

import SwiftUI
import ReactionsCore

class EnergyProfileFilingViewModel: ObservableObject {

    init(persistence: EnergyProfilePersistence) {
        self.persistence = persistence
    }

    @Published var page: Int = 0

    private let persistence: EnergyProfilePersistence

    func navigation(index: Int) -> NavigationModel<EnergyProfileState> {
        let model = EnergyProfileViewModel()
        let input = getInput(index: index)
        let nextCatalyst = index == input.catalysts.count - 1 ? nil : input.catalysts[index + 1]

        let nav = NavigationModel(
            model: model,
            rootNode: ScreenStateTreeNode<EnergyProfileState>(
                state: EnergyProfileEndState(
                    catalyst: input.catalysts[index],
                    order: input.order,
                    nextCatalyst: nextCatalyst
                )
            )
        )
        nav.nextScreen = next
        nav.prevScreen = back
        model.navigation = nav
        return nav
    }

    private func next() {
        if page < 2 {
            page += 1
        }
    }

    private func back() {
        if page > 0 {
            page -= 1
        }
    }

    private func getInput(index: Int) -> EnergyProfileInput {
        persistence.getInput().map(validate) ?? defaultInput
    }

    private func validate(input: EnergyProfileInput) -> EnergyProfileInput {
        if input.catalysts.count < 3 {
            let missing = Catalyst.allCases.filter { !input.catalysts.contains($0) }
            assert(missing.count + input.catalysts.count == 3)
            return EnergyProfileInput(
                catalysts: input.catalysts + missing,
                order: input.order
            )
        }
        return input
    }

    private var defaultInput: EnergyProfileInput {
        EnergyProfileInput(catalysts: [.A, .B, .C], order: .Zero)
    }
}

private class EnergyProfileEndState: EnergyProfileState {

    let catalyst: Catalyst
    let order: ReactionOrder
    let nextCatalyst: Catalyst?

    init(catalyst: Catalyst, order: ReactionOrder, nextCatalyst: Catalyst?) {
        self.catalyst = catalyst
        self.order = order
        self.nextCatalyst = nextCatalyst
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.statement = EnergyProfileFilingStatements.statement(
            catalyst: catalyst,
            order: order,
            nextCatalyst: nextCatalyst
        )
        model.catalystState = .selected(catalyst: catalyst)
        model.selectedReaction = order
        model.particleState = .appearInBeaker
        model.concentrationC = 1
        model.reactionState = .completed
        model.temp2 = 425
        model.canSetReaction = false
    }
}
