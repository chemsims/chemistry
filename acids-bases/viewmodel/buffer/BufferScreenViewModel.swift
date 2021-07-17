//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferScreenViewModel: ObservableObject {

    init(
        namePersistence: NamePersistence
    ) {
        let initialSubstances = AcidOrBase.weakAcids
        let initialSubstance = initialSubstances.first!
        let initialRows = AcidAppSettings.initialRows
        let weakModel = BufferWeakSubstanceComponents(
            substance: initialSubstance,
            settings: .standard,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )
        let saltModel = BufferSaltComponents(prev: weakModel)
        let strongModel = BufferStrongSubstanceComponents(prev: saltModel)

        self.namePersistence = namePersistence
        self.rows = CGFloat(initialRows)
        self.weakSubstanceModel = weakModel
        self.saltModel = saltModel
        self.strongSubstanceModel = strongModel

        self.availableSubstances = initialSubstances
        self.navigation = BufferNavigationModel.model(self)
        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: canAddMolecule,
            addMolecules: addMolecule
        )
    }

    @Published var rows: CGFloat {
        didSet {
            weakSubstanceModel.rows = GridCoordinateList.availableRows(for: rows)
            if highlights.elements == [.waterSlider] {
                highlights.clear()
            }
        }
    }
    @Published var statement = [TextLine]()
    @Published var input = InputState.none
    @Published var phase = Phase.addWeakSubstance
    @Published var weakSubstanceModel: BufferWeakSubstanceComponents
    @Published var saltModel: BufferSaltComponents
    @Published var strongSubstanceModel: BufferStrongSubstanceComponents

    @Published var selectedBottomGraph = BottomGraph.bars
    @Published var equationState = EquationState.acidBlank

    // This is published as otherwise the beaky box is not redrawn when the computed
    // property changes
    @Published var canGoNext: Bool = true
    @Published var substanceSelectionIsToggled = false
    @Published var availableSubstances: [AcidOrBase]
    var substance: AcidOrBase {
        weakSubstanceModel.substance
    }

    @Published var highlights = HighlightedElements<BufferScreenElement>()

    let namePersistence: NamePersistence

    private var previousWeakAcidModel: BufferWeakSubstanceComponents?
    private var previousAcidSaltModel: BufferSaltComponents?
    private var previousStrongAcidModel: BufferStrongSubstanceComponents?

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
        canGoNext = canGoNextComputedProperty
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

    func goToWeakSubstancePhase() {
        weakSubstanceModel = BufferWeakSubstanceComponents(
            substance: .weakBases.first!,
            settings: .standard,
            cols: MoleculeGridSettings.cols,
            rows: AcidAppSettings.initialRows
        )
        phase = .addWeakSubstance
    }

    func goToSaltPhase() {
        saltModel = BufferSaltComponents(prev: weakSubstanceModel)
        phase = .addSalt
    }

    func goToStrongSubstancePhase() {
        strongSubstanceModel = BufferStrongSubstanceComponents(prev: saltModel)
        phase = .addStrongSubstance
    }

    func saveAcidModels() {
        previousWeakAcidModel = weakSubstanceModel
        previousAcidSaltModel = saltModel
        previousStrongAcidModel = strongSubstanceModel
    }

    func restoreSavedAcidModels() {
        if let weak = previousWeakAcidModel,
           let salt = previousAcidSaltModel,
           let strong = previousStrongAcidModel {
            weakSubstanceModel = weak
            saltModel = salt
            strongSubstanceModel = strong
        } else {
            assert(false, "Could not restore acid models")
        }
    }
}

// MARK: Adding molecules
extension BufferScreenViewModel {

    private func addMolecule(phase: Phase, count: Int) {
        guard input == .addMolecule(phase: phase) else {
            return
        }
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
        case none, setWaterLevel, selectSubstance
        case addMolecule(phase: Phase)
    }

    enum BottomGraph: String {
        case curve, bars, neutralization

        var name: String {
            self.rawValue.capitalized
        }
    }

    enum EquationState: String, CaseIterable {
        case acidBlank,
             acidWithSubstanceConcentration,
             acidWithAllConcentration,
             acidFilled,
             acidSummary
        case baseBlank,
             baseWithSubstanceConcentration,
             baseWithAllConcentration,
             baseFilled,
             baseSummary
    }
}
