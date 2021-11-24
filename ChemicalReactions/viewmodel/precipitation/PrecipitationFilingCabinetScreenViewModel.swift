//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PrecipitationFilingCabinetScreen: View {

    @ObservedObject var pagingModel: PrecipitationFilingCabinetPagingViewModel

    var body: some View {
        GeometryReader { geo in
            PageViewController(
                pages: [
                    getView(page: 0, geo),
                    getView(page: 1, geo)
                ],
                currentPage: $pagingModel.currentPage
            )
        }
    }

    // We must give this an explicit frame, otherwise there is a large
    // layout shift when the view appears
    private func getView(page: Int, _ geo: GeometryProxy) -> some View {
        PrecipitationScreen(model: pagingModel.model(page: page))
            .frame(size: geo.size)
    }
}

class PrecipitationFilingCabinetPagingViewModel: ObservableObject {

    let persistence: PrecipitationInputPersistence
    @Published var currentPage = 0

    init(persistence: PrecipitationInputPersistence) {
        self.persistence = persistence
        self.model1 = PrecipitationFilingCabinetScreenViewModel(
            persistence: persistence,
            reactionIndex: 0
        )
        self.model2 = PrecipitationFilingCabinetScreenViewModel(
            persistence: persistence,
            reactionIndex: 1
        )
        self.model1.navigation.nextScreen = { self.currentPage += 1 }
        self.model2.navigation.prevScreen = { self.currentPage -= 1 }
    }

    private var model1: PrecipitationFilingCabinetScreenViewModel
    private var model2: PrecipitationFilingCabinetScreenViewModel

    fileprivate func model(page: Int) -> PrecipitationFilingCabinetScreenViewModel {
        page == 0 ? model1 : model2
    }
}

private class PrecipitationFilingCabinetScreenViewModel: PrecipitationScreenViewModel {

    init(persistence: PrecipitationInputPersistence, reactionIndex: Int) {
        super.init(persistence: persistence)
        let state = NavState(persistence: persistence, reactionIndex: reactionIndex)
        self.navigation = NavigationModel(model: self, states: [state])
    }

    // This override is here in case we decide to let user weigh
    // the precipitate again
    override var beakerToggleIsDisabled: Bool {
        false
    }

    override var nextIsDisabled: Bool {
        navigation.nextScreen == nil
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

    init(persistence: PrecipitationInputPersistence, reactionIndex: Int) {
        self.persistence = persistence
        self.reactionIndex = reactionIndex
    }

    let persistence: PrecipitationInputPersistence
    let reactionIndex: Int

    override func apply(on model: PrecipitationScreenViewModel) {
        model.statement = PrecipitationStatements.filingCabinet(index: reactionIndex)
        model.input = nil
        model.highlights.clear()
        model.equationState = .showAll
        model.showUnknownMetal = true
        model.showReRunReactionButton = true
        if reactionIndex < model.availableReactions.count {
            model.chosenReaction = model.availableReactions[reactionIndex]
        }
        if let input = persistence.getComponentInput(reactionIndex: reactionIndex) {
            model.chosenReaction = model.chosenReaction.replacingMetal(with: input.reactantMetal)
            model.rows = CGFloat(input.rows)
            model.components.runCompleteReaction(using: input)
        } else {
            model.components.runCompleteReaction()
        }
    }
}
