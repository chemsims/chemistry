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
        self.saltModel = saltModel
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
    @Published var saltModel: BufferSaltComponents
    @Published var strongSubstanceModel: BufferStrongSubstanceComponents

    @Published var selectedBottomGraph = BottomGraph.bars
    @Published var equationState = EquationState.weakAcidBlank

    // This is published as otherwise the beaky box is not redrawn when the computed
    // property changes
    @Published var canGoNext: Bool = true

    private(set) var shakeModel: MultiContainerShakeViewModel<Phase>!
    private(set) var navigation: NavigationModel<BufferScreenState>?
}

// MARK: Navigation
extension BufferScreenViewModel {
    func next() {
        if canGoNext {
            navigation?.next()
            canGoNext = canGoNextComputedProperty
        }
    }

    func back() {
        navigation?.back()
        canGoNext = true
    }

    private var canGoNextComputedProperty: Bool {
        switch input {
        case .addMolecule(phase: .addWeakSubstance):
            assert(weakSubstanceModel.limitsAreValid) // TODO - find a better way to handle this
            return weakSubstanceModel.hasAddedEnoughSubstance
        case .addMolecule(phase: .addSalt):
            return saltModel.hasAddedEnoughSubstance
        case .addMolecule(phase: .addStrongSubstance):
            return strongSubstanceModel.hasAddedEnoughSubstance
        default:
            return true
        }
    }

    func goToAddSaltPhase() {
        saltModel = BufferSaltComponents(prev: weakSubstanceModel)
        phase = .addSalt
    }

    func goToStrongSubstancePhase() {
        strongSubstanceModel = BufferStrongSubstanceComponents(prev: saltModel)
        phase = .addStrongSubstance
    }

    func goToWeakBufferPhase() {
        substance = AcidOrBase.weakBases.first!
        weakSubstanceModel = BufferWeakSubstanceComponents(
            substance: .weakBases.first!,
            settings: .standard,
            cols: MoleculeGridSettings.cols,
            rows: AcidAppSettings.initialRows
        )
        phase = .addWeakSubstance
    }
}

// MARK: Adding molecules
extension BufferScreenViewModel {

    private func addMolecule(phase: Phase, count: Int) {
        switch phase {
        case .addWeakSubstance: weakSubstanceModel.incrementSubstance(count: count)
        case .addSalt: saltModel.incrementSalt(count: count)
        case .addStrongSubstance: strongSubstanceModel.incrementStrongSubstance(count: count)
        }
        canGoNext = canGoNextComputedProperty
    }

    private func canAddMolecule(phase: Phase) -> Bool {
        switch phase {
        case .addWeakSubstance: return weakSubstanceModel.canAddSubstance
        case .addSalt: return saltModel.canAddSubstance
        case .addStrongSubstance: return strongSubstanceModel.canAddSubstance
        }
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
