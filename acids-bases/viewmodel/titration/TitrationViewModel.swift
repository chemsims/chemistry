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
    @Published var equationState = EquationState.strongAcidBlank

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
        if components.state.substance.isStrong {
            components.strongSubstancePreparationModel.incrementSubstance(count: count)
        } else {
            components.weakSubstancePreparationModel.incrementSubstance(count: count)
        }
    }

    func incrementTitrant(count: Int) {
        let isStrong = components.state.substance.isStrong
        switch components.state.phase {
        case .preEP where isStrong:
            components.strongSubstancePreEPModel.incrementTitrant(count: count)
        case .postEP where isStrong:
            components.strongSubstancePostEPModel.incrementTitrant(count: count)

        case .preEP:
            components.weakSubstancePreEPModel.incrementTitrant(count: count)
        case .postEP:
            components.weakSubstancePostEPModel.incrementTitrant(count: count)
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

    enum EquationState: CaseIterable {
        case strongAcidBlank,
             strongAcidAddingSubstance,
             strongAcidPreEPFilled,
             strongAcidPostEP,
             strongBaseBlank,
             strongBaseAddingSubstance,
             strongBasePreEPFilled,
             strongBasePostEP,
             weakAcidBlank,
             weakAcidAddingSubstance,
             weakAcidPostInitialReaction,
             weakAcidPreEPFilled,
             weakAcidAtEP,
             weakAcidPostEP

        var equationSet: TitrationEquationSet {
            switch self {
            case .strongAcidBlank:
                return .strongAcidPreEP(
                    fillSubstanceAndHydrogen: false,
                    fillTitrantMolarity: false,
                    fillAll: false
                )

            case .strongAcidAddingSubstance:
                return .strongAcidPreEP(
                    fillSubstanceAndHydrogen: true,
                    fillTitrantMolarity: false,
                    fillAll: false
                )

            case .strongAcidPreEPFilled:
                return .strongAcidPreEP(
                    fillSubstanceAndHydrogen: true,
                    fillTitrantMolarity: true,
                    fillAll: true
                )

            case .strongAcidPostEP: return .strongAcidPostEP

            case .strongBaseBlank:
                return .strongBasePreEp(
                    fillSubstanceAndHydroxide: false,
                    fillTitrantMolarity: false,
                    fillAll: false
                )

            case .strongBaseAddingSubstance:
                return .strongBasePreEp(
                    fillSubstanceAndHydroxide: true,
                    fillTitrantMolarity: false,
                    fillAll: false
                )


            case .strongBasePreEPFilled:
                return .strongBasePreEp(
                    fillSubstanceAndHydroxide: true,
                    fillTitrantMolarity: true,
                    fillAll: true
                )

            case .strongBasePostEP: return .strongBasePostEp

            case .weakAcidBlank:
                return .weakAcidInitialReaction(fillSubstance: false, fillAll: false)

            case .weakAcidAddingSubstance:
                return .weakAcidInitialReaction(fillSubstance: true, fillAll: false)

            case .weakAcidPostInitialReaction:
                return .weakAcidInitialReaction(fillSubstance: true, fillAll: true)

            case .weakAcidPreEPFilled:
                return .weakBasePreEp(fillTitrantMolarity: true, fillAll: true)

            case .weakAcidAtEP: return .weakAcidAtEp

            case .weakAcidPostEP: return .weakAcidPostEp
            }
        }
    }

    enum ReactionPhase {
        case strongSubstancePreparation,
             strongSubstancePreEP,
             strongSubstancePostEP
    }
}
