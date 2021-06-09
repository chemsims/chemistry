//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferScreenViewModel: ObservableObject {

    init() {
        let initialSubstance = AcidOrBase.weakAcids[1]
        self.substance = initialSubstance
        self.weakSubstanceModel = BufferWeakSubstanceComponents(substance: initialSubstance)
        self.navigation = BufferNavigationModel.model(self)
    }

    @Published var rows = CGFloat(AcidAppSettings.initialRows)
    @Published var statement = [TextLine]()
    @Published var input = InputState.none
    @Published var phase = Phase.addWeakSubstance
    @Published var substance: AcidOrBase
    @Published var weakSubstanceModel: BufferWeakSubstanceComponents
    @Published var saltComponents = BufferSaltComponents(prev: nil)
    @Published var phase3Model = BufferComponents3(prev: nil)

    private(set) var navigation: NavigationModel<BufferScreenState>?
}

// MARK: Navigation
extension BufferScreenViewModel {
    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func goToAddSaltPhase() {
        saltComponents = BufferSaltComponents(prev: weakSubstanceModel)
        phase = .addSalt
    }

    func goToPhase3() {
        phase3Model = BufferComponents3(prev: saltComponents)
        phase = .addStrongSubstance
    }
}

// MARK: Adding molecules
extension BufferScreenViewModel {
    func incrementWeakSubstance() {
        weakSubstanceModel.incrementSubstance(count: 1)
    }

    func incrementSalt() {
        saltComponents.incrementSalt()
    }

    func incrementStrongSubstance() {
        phase3Model.incrementStrongAcid()
    }
}

// MARK: Enums
extension BufferScreenViewModel {
    enum Phase {
        case addWeakSubstance, addSalt, addStrongSubstance
    }

    enum InputState {
        case none, setWaterLevel, addWeakAcid
    }
}
