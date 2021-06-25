//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        self.rows = CGFloat(initialRows)

        self.components = TitrationComponentState(
            strongAcid: .strongAcids.first!,
            weakAcid: .weakAcids.first!,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )

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
            doAddMolecule: { i in self.incrementTitrant(count: i) }
        )
        self.navigation = TitrationNavigationModel.model(self)
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat
    @Published var inputState = InputState.none
    @Published var equationState = EquationState.strongSubstanceBlank

    @Published var components: TitrationComponentState

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
        components.strongSubstancePreparationModel.incrementSubstance(count: count)
    }

    func incrementTitrant(count: Int) {
        switch components.state.phase {
        case .preEP:
            components.strongSubstancePreEPModel.incrementTitrant(count: count)
        case .postEP:
            components.strongSubstancePostEPModel.incrementTitrant(count: count)
        default:
            return
        }
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

    enum EquationState {
        case strongSubstanceBlank,
             strongSubstanceAddingSubstance,
             strongSubstancePreEPFilled,
             strongSubstancePostEP

        var equationSet: TitrationEquationSet {
            switch self {
            case .strongSubstanceBlank:
                return .strongAcidPreEP(
                    fillSubstanceAndHydrogen: false,
                    fillTitrantMolarity: false,
                    fillAll: false
                )

            case .strongSubstanceAddingSubstance:
                return .strongAcidPreEP(
                    fillSubstanceAndHydrogen: true,
                    fillTitrantMolarity: false,
                    fillAll: false
                )

            case .strongSubstancePreEPFilled:
                return .strongAcidPreEP(
                    fillSubstanceAndHydrogen: true,
                    fillTitrantMolarity: true,
                    fillAll: true
                )

            case .strongSubstancePostEP: return .strongAcidPostEP
            }
        }
    }

    enum ReactionPhase {
        case strongSubstancePreparation,
             strongSubstancePreEP,
             strongSubstancePostEP
    }
}
