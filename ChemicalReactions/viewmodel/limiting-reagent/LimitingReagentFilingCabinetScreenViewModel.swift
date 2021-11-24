//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct LimitingReagentFilingCabinetScreen: View {

    @ObservedObject var pagingModel: LimitingReagentFilingCabinetPagingViewModel

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

    // Wee must give this an explicit frame, otherwise there is a large
    // layout shift when the view appears
    private func getView(page: Int, _ geo: GeometryProxy) -> some View {
        LimitingReagentScreen(model: pagingModel.model(page: page))
            .frame(size: geo.size)
    }
}

class LimitingReagentFilingCabinetPagingViewModel: ObservableObject {

    let persistence: LimitingReagentPersistence
    @Published var currentPage = 0

    init(persistence: LimitingReagentPersistence) {
        self.persistence = persistence
        self.model1 = LimitingReagentFilingCabinetScreenViewModel(
            persistence: persistence,
            reactionIndex: 0
        )
        self.model2 = LimitingReagentFilingCabinetScreenViewModel(
            persistence: persistence,
            reactionIndex: 1
        )
        self.model1.navigation.nextScreen = { self.currentPage += 1 }
        self.model2.navigation.prevScreen = { self.currentPage -= 1 }
    }

    private var model1: LimitingReagentFilingCabinetScreenViewModel
    private var model2: LimitingReagentFilingCabinetScreenViewModel

    fileprivate func model(page: Int) -> LimitingReagentFilingCabinetScreenViewModel {
        page == 0 ? model1 : model2
    }
}

private class LimitingReagentFilingCabinetScreenViewModel: LimitingReagentScreenViewModel {

    init(persistence: LimitingReagentPersistence, reactionIndex: Int) {
        super.init(persistence: persistence)
        self.navigation = LimitingReagentNavigationModel.filingCabinetModel(
            using: self,
            persistence: persistence,
            reactionIndex: reactionIndex
        )
    }

    // We only block next when there's no next screen
    override var nextIsDisabledComputedProperty: Bool {
        if let nav = navigation {
            return nav.nextScreen == nil && !nav.hasNext
        }
        return false
    }
}
