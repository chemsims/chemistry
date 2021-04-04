//
// Reactions App
//

import SwiftUI
import ReactionsCore


enum SoluteType {
    case primary, commonIon, acid
}

class SolubilityViewModel: ObservableObject {

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0
    @Published var inputState = SolubilityInputState.none
    @Published var activeSolute: SoluteType?

    init() {
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.navigation = SolubilityNavigationModel.model(model: self)
    }

    let shakingModel: SoluteBeakerShakingViewModel

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func stopShaking() {
        shakingModel.shake.position.stop()
    }
}

enum SolubilityInputState {
    case none, addSolute
}
