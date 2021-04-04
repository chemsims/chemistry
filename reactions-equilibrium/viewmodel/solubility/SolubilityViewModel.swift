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

    @Published var currentTime: CGFloat = 0

    var componentWrapper: SolubilityComponentsWrapper

    init() {
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.componentWrapper = SolubilityComponentsWrapper(equilibriumConstant: 0.1)
        self.navigation = SolubilityNavigationModel.model(model: self)
    }

    var components: SolubilityComponents {
        componentWrapper.components
    }

    let shakingModel: SoluteBeakerShakingViewModel

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func onDissolve() {
        withAnimation(.linear(duration: 0.5)) {
            currentTime += 0.5
        }
    }

    func stopShaking() {
        shakingModel.shake.position.stop()
    }
}

enum SolubilityInputState {
    case none, addSolute
}
