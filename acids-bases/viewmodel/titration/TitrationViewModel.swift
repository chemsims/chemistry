//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        self.strongSubstancePhase1Model = TitrationStrongSubstancePhase1Model(
            cols: MoleculeGridSettings.cols,
            rows: CGFloat(AcidAppSettings.initialRows),
            settings: .standard
        )
        self.components = TitrationComponents(
            substance: .weakAcids.first!,
            cols: MoleculeGridSettings.cols,
            rows: AcidAppSettings.initialRows,
            settings: .standard
        )
        self.rows = CGFloat(initialRows)
        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in true },
            addMolecules: { (_, i) in
                self.incrementSubstance(count: i)
            }
        )
        self.dropperEmitModel = MoleculeEmittingViewModel(
            canAddMolecule: { true },
            doAddMolecule: { _ in }
        )
        self.buretteEmitModel = MoleculeEmittingViewModel(
            canAddMolecule: { true },
            doAddMolecule: { _ in }
        )
        self.navigation = TitrationNavigationModel.model(self)
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat
    @Published var inputState = InputState.none

    let components: TitrationComponents
    let strongSubstancePhase1Model: TitrationStrongSubstancePhase1Model

    private(set) var navigation: NavigationModel<TitrationScreenState>!
    var shakeModel: MultiContainerShakeViewModel<TempMolecule>!
    var dropperEmitModel: MoleculeEmittingViewModel!
    var buretteEmitModel: MoleculeEmittingViewModel!

    enum TempMolecule: String, CaseIterable {
        case A
    }
}

// MARK: Navigation
extension TitrationViewModel {
    func next() {
        navigation?.next()
    }

    func back() {
        navigation.back()
    }

    var nextIsDisabled: Bool {
        false
    }
}

// MARK: Adding molecules
extension TitrationViewModel {
    func incrementSubstance(count: Int) {
        strongSubstancePhase1Model.incrementSubstance(count: count)
    }
}

// MARK: Data types
extension TitrationViewModel {
    enum InputState {
        case none,
             selectSubstance,
             setWaterLevel,
             addSubstance,
             addIndicator,
             addTitrant
    }
}
