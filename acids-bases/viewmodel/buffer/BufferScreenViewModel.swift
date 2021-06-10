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
        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: canAddMolecule,
            addMolecules: addMolecule
        )
    }

    @Published var rows = CGFloat(AcidAppSettings.initialRows) {
        didSet {
            weakSubstanceModel.rows = GridCoordinateList.availableRows(for: rows)
        }
    }
    @Published var statement = [TextLine]()
    @Published var input = InputState.none
    @Published var phase = Phase.addWeakSubstance
    @Published var substance: AcidOrBase
    @Published var weakSubstanceModel: BufferWeakSubstanceComponents
    @Published var saltComponents = BufferSaltComponents(prev: nil)
    @Published var phase3Model = BufferComponents3(prev: nil)

    @Published var selectedBottomGraph = BottomGraph.bars
    @Published var equationState = EquationState.weakAcidBlank

    private(set) var shakeModel: MultiContainerShakeViewModel<Phase>!
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

    private func addMolecule(phase: Phase, count: Int) {
        switch phase {
        case .addWeakSubstance: weakSubstanceModel.incrementSubstance(count: count)
        case .addSalt: saltComponents.incrementSalt() // TODO count
        case .addStrongSubstance: phase3Model.incrementStrongAcid()
        }
    }

    private func canAddMolecule(phase: Phase) -> Bool {
        true // TODO
    }

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
    enum Phase: CaseIterable {
        case addWeakSubstance, addSalt, addStrongSubstance
    }

    enum InputState: Equatable {
        case none, setWaterLevel
        case addMolecule(phase: Phase)
    }

    enum BottomGraph: String {
        case curve, bars, neutralization

        var name: String {
            self.rawValue.capitalized
        }
    }

    enum EquationState: String, CaseIterable {
        case weakAcidBlank,
             weakAcidWithSubstanceConcentration,
             weakAcidWithAllConcentration,
             weakAcidFilled,
             acidSummary
        case weakBaseBlank,
             weakBaseWithSubstanceConcentration,
             weakBaseWithAllConcentration,
             weakBaseFilled,
             baseSummary
    }
}
