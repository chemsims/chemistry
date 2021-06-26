//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        self.rows = CGFloat(initialRows)
        self.availableSubstances = AcidOrBase.strongAcids

        let initialSubstance =  AcidOrBase.strongAcids.first!
        self.substance = initialSubstance

        self.components = TitrationComponentState(
            strongAcid: initialSubstance,
            weakAcid: .weakAcids.first!,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )

        self.shakeModel = MultiContainerShakeViewModel(
            canAddMolecule: {
                self.canAdd(substance: $0)
            },
            addMolecules: {
                self.increment(substance: $0, count: $1)
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
        self.availableSubstances = AcidOrBase.strongAcids
        self.navigation = TitrationNavigationModel.model(self)
    }

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat {
        didSet {
            components.setRows(rows)
        }
    }
    @Published var inputState = InputState.none
    @Published var equationState = EquationState.strongAcidBlank

    @Published var components: TitrationComponentState

    @Published var availableSubstances: [AcidOrBase]
    @Published var substanceSelectionIsToggled: Bool = false 
    @Published var substance: AcidOrBase {
        didSet {
            components.setSubstance(substance)
        }
    }

    /// This is published instead of reading from a computer property so that observers of this model will be
    /// notified when it changes rather than reading from a comp
    @Published var canGoNext: Bool = true

    private(set) var navigation: NavigationModel<TitrationScreenState>!
    var shakeModel: MultiContainerShakeViewModel<TitrationComponentState.Substance>!
    var dropperEmitModel: MoleculeEmittingViewModel!
    var buretteEmitModel: MoleculeEmittingViewModel!

    enum TempMolecule: String, CaseIterable {
        case A
    }
}

// MARK: Navigation
extension TitrationViewModel {
    func next() {
        if canGoNext {
            navigation?.next()
            updateCanGoNext()
        }

    }

    func back() {
        navigation.back()
        canGoNext = canGoNextComputedProperty
    }
}

// MARK: Adding molecules
extension TitrationViewModel {
    private func increment(substance: TitrationComponentState.Substance, count: Int) {
        guard substance == components.state.substance else {
            return
        }
        if substance.isStrong {
            components.strongSubstancePreparationModel.incrementSubstance(count: count)
        } else {
            components.weakSubstancePreparationModel.incrementSubstance(count: count)
        }
        updateCanGoNext()
    }

    private func incrementTitrant(count: Int) {
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

    private func canAdd(substance: TitrationComponentState.Substance) -> Bool {
        guard substance == components.state.substance else {
            return false
        }
        return components.currentPreparationModel?.canAddSubstance ?? false
    }
}

// MARK: Navigation validation
extension TitrationViewModel {
    private func updateCanGoNext() {
        canGoNext = canGoNextComputedProperty
    }

    private var canGoNextComputedProperty: Bool {
        switch inputState {
        case .addSubstance: return hasAddedEnoughSubstance
        case .addIndicator: return hasAddedEnoughIndicator
        default: return true
        }
    }

    /// Returns true if enough substance has been added, or if model component state is not adding substance
    private var hasAddedEnoughSubstance: Bool {
        components.currentPreparationModel?.hasAddedEnoughSubstance ?? true
    }

    private var hasAddedEnoughIndicator: Bool {
        false
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
             addTitrant,
             setTitrantMolarity
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
