//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationViewModel: ObservableObject {

    init(namePersistence: NamePersistence) {
        self.namePersistence = namePersistence
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
            canAddMolecule: { [weak self] in
                self?.canAdd(substance: $0) ?? false
            },
            addMolecules: { [weak self] in
                self?.increment(substance: $0, count: $1)
            }
        )
        self.dropperEmitModel = MoleculeEmittingViewModel(
            canAddMolecule: { [weak self] in self?.canAddIndicator ?? false },
            didEmitMolecules: { [weak self] in self?.didEmitIndicator(count: $0) },
            doAddMolecule: { [weak self] in self?.addedIndicator(count: $0) }
        )
        self.buretteEmitModel = MoleculeEmittingViewModel(
            canAddMolecule: { [weak self] in self?.canAddTitrant ?? false },
            didEmitMolecules: { [weak self] (_) in self?.didEmitTitrant() },
            doAddMolecule: { [weak self] in self?.incrementTitrant(count: $0) }
        )
        self.availableSubstances = AcidOrBase.strongAcids
        self.navigation = TitrationNavigationModel.model(self, namePersistence: namePersistence)
    }

    let namePersistence: NamePersistence

    @Published var statement = [TextLine]()
    @Published var rows: CGFloat {
        didSet {
            components.setRows(rows)
            if highlights.elements == [.waterSlider] {
                highlights.clear()
            }
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

    @Published var showPhString = true

    @Published var showIndicatorFill = false
    @Published var showTitrantFill = false

    /// This is published instead of reading from a computer property so that observers of this model will be
    /// notified when it changes rather than reading from a comp
    @Published var canGoNext = true

    @Published private(set) var indicatorEmitted = 0
    @Published private(set) var indicatorAdded = 0

    let maxIndicator = 25

    @Published var macroBeakerState = MacroBeakerState.indicator

    @Published var highlights = HighlightedElements<TitrationScreenElement>()

    @Published var beakerState = BeakerState.microscopic

    private(set) var navigation: NavigationModel<TitrationScreenState>!
    var shakeModel: MultiContainerShakeViewModel<TitrationComponentState.Substance>!
    var dropperEmitModel: MoleculeEmittingViewModel!
    var buretteEmitModel: MoleculeEmittingViewModel!
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
        updateCanGoNext()
    }
}

// MARK: Adding molecules
extension TitrationViewModel {
    func increment(substance: TitrationComponentState.Substance, count: Int) {
        guard substance == components.state.substance,
              inputState == .addSubstance else {
            return
        }

        if substance.isStrong {
            components.strongSubstancePreparationModel.incrementSubstance(count: count)
        } else {
            components.weakSubstancePreparationModel.incrementSubstance(count: count)
        }
        updateCanGoNext()
        updateStatementPostSubstanceIncrement()
        goNextIfNeededPostSubstanceIncrement()
    }

    private func canAdd(substance: TitrationComponentState.Substance) -> Bool {
        guard substance == components.state.substance else {
            return false
        }
        return components.currentPreparationModel?.canAddSubstance ?? false
    }
}

// MARK: Navigation input limits
extension TitrationViewModel {
    private func updateCanGoNext() {
        let nextComputed = canGoNextComputedProperty

        // Only apply this if it changes to prevent view redraw
        if canGoNext != nextComputed {
            canGoNext = nextComputed
        }
    }

    private var canGoNextComputedProperty: Bool {
        switch inputState {
        case .addSubstance: return hasAddedEnoughSubstance
        case .addIndicator: return hasAddedEnoughIndicator
        case .addTitrant: return hasAddedEnoughTitrant
        default: return true
        }
    }

    /// Returns true if enough substance has been added, or if model component state is not adding substance
    private var hasAddedEnoughSubstance: Bool {
        components.currentPreparationModel?.hasAddedEnoughSubstance ?? true
    }

    /// Returns true if enough titrant has been added, or if model component state is not adding titrant
    private var hasAddedEnoughTitrant: Bool {
        components.currentTitrantInputLimits?.hasAddedEnoughTitrant ?? true
    }
}

// MARK: Adding indicator
extension TitrationViewModel {

    var dropperFillPercent: CGFloat {
        LinearEquation(
            x1: 1,
            y1: 1,
            x2: CGFloat(maxIndicator),
            y2: 0
        ).getY(at: CGFloat(indicatorEmitted))
    }

    private func didEmitIndicator(count: Int) {
        if highlights.elements == [.indicator] {
            highlights.clear()
        }
        let maxToAdd = min(remainingIndicatorAvailable, count)
        guard inputState == .addIndicator, maxToAdd > 0 else {
            return
        }
        withAnimation(.linear(duration: 1)) {
            indicatorEmitted += maxToAdd
        }
    }


    private func addedIndicator(count: Int) {
        let maxToAdd = min(remainingIndicatorAvailable, count)
        guard inputState == .addIndicator, maxToAdd > 0 else {
            return
        }

        withAnimation(.linear(duration: 1)) {
            indicatorAdded += maxToAdd
        }
        updateCanGoNext()
        goNextIfNeededPostIndicatorIncrement()
    }

    private var canAddIndicator: Bool {
        remainingIndicatorAvailable > 0
    }

    private var hasAddedEnoughIndicator: Bool {
        !canAddIndicator
    }

    private var remainingIndicatorAvailable: Int {
        max(0, maxIndicator - indicatorAdded)
    }
}

// MARK: Adding titrant
extension TitrationViewModel {
    func incrementTitrant(count: Int) {
        guard inputState == .addTitrant else {
            return
        }

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
        default: break
        }

        updateCanGoNext()
        updateStatementPostTitrantIncrement()
        goNextIfNeededPostTitrantIncrement()
        updateEquationPostTitrantIncrement()
    }

    private func didEmitTitrant() {
        if highlights.elements == [.burette] {
            highlights.clear()
        }
    }

    private var canAddTitrant: Bool {
        components.currentTitrantInputLimits?.canAddTitrant ?? false
    }
}

// MARK: Reset state
extension TitrationViewModel {
    func resetIndicator() {
        indicatorAdded = 0
        indicatorEmitted = 0
    }

    func resetInitialSubstance() {
        components.currentPreparationModel?.resetState()
    }

    func resetPreEPTitrant() {
        components.currentPreEPTitrantModel?.resetState()
    }

    func resetPostEPTitrant() {
        components.currentPostEPTitrantModel?.resetState()
    }
}

// MARK: Updating statement mid adding molecules
extension TitrationViewModel {
    private func updateStatementPostSubstanceIncrement() {
        let shouldUpdateStatement = components.currentPreparationModel?.hasAddedEnoughSubstance ?? false
        guard shouldUpdateStatement else {
            return
        }

        switch components.state.substance {
        case .strongAcid:
            statement = TitrationStatements.midAddingStrongAcid
        case .strongBase:
            statement = TitrationStatements.midAddingStrongBase
        default:
            return
        }
    }

    private func updateStatementPostTitrantIncrement() {
        guard inputState == .addTitrant else {
            return
        }
        if components.state.phase == .preEP {
            updateStrongSubstancePreEPTitrantStatement()
        } else if components.state.phase == .postEP {
            updateStrongSubstancePostEPTitrantStatement()
        }
    }

    private func updateStrongSubstancePreEPTitrantStatement() {
        guard let model = components.currentPreEPTitrantModel else {
            return
        }
        let percentAdded = Double(model.titrantAdded) / Double(model.maxTitrant)
        let shouldUpdate = percentAdded >= 0.4
        guard shouldUpdate else {
            return
        }
        switch components.state.substance {
        case .strongAcid:
            statement = TitrationStatements.midAddingStrongBaseTitrant
        case .strongBase:
            statement = TitrationStatements.midAddingStrongAcidTitrant
        default: return
        }
    }

    private func updateStrongSubstancePostEPTitrantStatement() {
        guard let model = components.currentPostEPTitrantModel else {
            return
        }
        let percentAdded = Double(model.titrantAdded) / Double(model.maxTitrant)
        let shouldUpdate = percentAdded >= 0.1
        guard shouldUpdate else {
            return
        }
        switch components.state.substance {
        case .strongAcid:
            statement = TitrationSubstanceStatements(
                substance: substance,
                namePersistence: namePersistence
            ).midAddingStrongBaseTitrantPostEP
        case .strongBase:
            statement = TitrationSubstanceStatements(
                substance: substance,
                namePersistence: namePersistence
            ).midAddingStrongAcidTitrantPostEP
        default: return
        }
    }
}

// MARK: Going next automatically post increment
extension TitrationViewModel {
    private func goNextIfNeededPostSubstanceIncrement() {
        guard inputState == .addSubstance else {
            return
        }
        if let model = components.currentPreparationModel, !model.canAddSubstance {
            next()
        }
    }

    private func goNextIfNeededPostIndicatorIncrement() {
        guard inputState == .addIndicator else {
            return
        }
        if inputState == .addIndicator && !canAddIndicator {
            next()
        }
    }

    private func goNextIfNeededPostTitrantIncrement() {
        guard inputState == .addTitrant else {
            return
        }
        if let model = components.currentPreEPTitrantModel, !model.canAddTitrant {
            next()
        } else if let model = components.currentPostEPTitrantModel, !model.canAddTitrant {
            next()
        }
    }

    private func updateEquationPostTitrantIncrement() {
        guard inputState == .addTitrant,
              components.state.phase == .postEP else {
            return
        }

        if components.state.substance == .weakAcid {
            equationState = .weakAcidPostEPPostAddingTitrant
        } else if components.state.substance == .weakBase {
            equationState = .weakBasePostEPPostAddingTitrant
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
             weakAcidPreEPBlank,
             weakAcidPreEPFilled,
             weakAcidAtEP,
             weakAcidPostEPPreAddingTitrant,
             weakAcidPostEPPostAddingTitrant,
             weakBaseBlank,
             weakBaseAddingSubstance,
             weakBasePostInitialReaction,
             weakBasePreEPBlank,
             weakBasePreEPFilled,
             weakBaseAtEP,
             weakBasePostEPPreAddingTitrant,
             weakBasePostEPPostAddingTitrant

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

            case .weakAcidPreEPBlank:
                return .weakAcidPreEp(fillTitrantMolarity: false, fillAll: false)

            case .weakAcidPreEPFilled:
                return .weakAcidPreEp(fillTitrantMolarity: true, fillAll: true)

            case .weakAcidAtEP: return .weakAcidAtEp

            case .weakAcidPostEPPreAddingTitrant:
                return .weakAcidPostEp(fillMolesAndVolume: false)

            case .weakAcidPostEPPostAddingTitrant:
                return .weakAcidPostEp(fillMolesAndVolume: true)

            case .weakBaseBlank:
                return .weakBaseInitialReaction(fillSubstance: false, fillAll: false)

            case .weakBaseAddingSubstance:
                return .weakBaseInitialReaction(fillSubstance: true, fillAll: false)

            case .weakBasePostInitialReaction:
                return .weakBaseInitialReaction(fillSubstance: true, fillAll: true)

            case .weakBasePreEPBlank:
                return .weakBasePreEp(fillTitrantMolarity: false, fillAll: false)

            case .weakBasePreEPFilled:
                return .weakBasePreEp(fillTitrantMolarity: true, fillAll: true)

            case .weakBaseAtEP: return .weakBaseAtEp

            case .weakBasePostEPPreAddingTitrant:
                return .weakBasePostEp(fillMolesAndVolume: false)

            case .weakBasePostEPPostAddingTitrant:
                return .weakBasePostEp(fillMolesAndVolume: true)
            }
        }
    }

    enum ReactionPhase {
        case strongSubstancePreparation,
             strongSubstancePreEP,
             strongSubstancePostEP
    }

    enum MacroBeakerState {
        case indicator, strongTitrant, weakTitrant

        var startColor: RGB {
            switch self {
            case .indicator: return .beakerLiquid
            default: return .maxIndicator
            }
        }

        var endColor: RGB {
            switch self {
            case .indicator: return .maxIndicator
            default: return .equivalencePointLiquid
            }
        }
    }

    enum BeakerState {
        case microscopic, macroscopic
    }
}
