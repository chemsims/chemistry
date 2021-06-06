//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferScreenViewModel: ObservableObject {

    init() {
        self.navigation = BufferNavigationModel.model(self)
    }

    @Published var rows = CGFloat(AcidAppSettings.initialRows)
    @Published var phase = Phase.addWeakSubstance
    @Published var phase1Model = BufferWeakAcidComponents(substance: .weakAcids[1])
    @Published var phase2Model = BufferComponents2(prev: nil)
    @Published var phase3Model = BufferComponents3(prev: nil)
    @Published var statement = [TextLine]()

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

    func goToPhase2() {
        phase2Model = BufferComponents2(prev: phase1Model)
        phase = .addSalt
    }

    func goToPhase3() {
        phase3Model = BufferComponents3(prev: phase2Model)
        phase = .addStrongSubstance
    }
}

// MARK: Adding molecules
extension BufferScreenViewModel {
    func incrementWeakSubstance() {
        phase1Model.incrementWeakAcid(count: 1)
    }

    func incrementSalt() {
        phase2Model.incrementSalt()
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
}
