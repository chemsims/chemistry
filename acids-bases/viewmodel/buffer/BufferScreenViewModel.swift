//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferScreenViewModel: ObservableObject {

    init() {
        let initialSubstance = AcidOrBase.weakAcids[1]
        let initialRows = AcidAppSettings.initialRows
        let weakModel = BufferWeakSubstanceComponents(
            substance: initialSubstance,
            settings: .standard,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )
        let saltModel = BufferSaltComponents(prev: weakModel)
        let strongModel = BufferStrongSubstanceComponents(prev: saltModel)

        self.rows = CGFloat(initialRows)
        self.weakSubstanceModel = weakModel
        self.saltComponents = saltModel
        self.strongSubstanceModel = strongModel

        self.substance = initialSubstance
        self.navigation = BufferNavigationModel.model(self)
        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: canAddMolecule,
            addMolecules: addMolecule
        )
    }

    @Published var rows: CGFloat {
        didSet {
            weakSubstanceModel.rows = GridCoordinateList.availableRows(for: rows)
        }
    }
    @Published var statement = [TextLine]()
    @Published var input = InputState.none
    @Published var phase = Phase.addWeakSubstance
    @Published var substance: AcidOrBase
    @Published var weakSubstanceModel: BufferWeakSubstanceComponents
    @Published var saltComponents: BufferSaltComponents
    @Published var strongSubstanceModel: BufferStrongSubstanceComponents

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
        strongSubstanceModel = BufferStrongSubstanceComponents(prev: saltComponents)
        phase = .addStrongSubstance
    }
}

// MARK: Adding molecules
extension BufferScreenViewModel {

    private func addMolecule(phase: Phase, count: Int) {
        switch phase {
        case .addWeakSubstance: weakSubstanceModel.incrementSubstance(count: count)
        case .addSalt: saltComponents.incrementSalt() // TODO count
        case .addStrongSubstance: strongSubstanceModel.incrementStrongSubstance()
        }
    }

    private func canAddMolecule(phase: Phase) -> Bool {
        true // TODO
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
