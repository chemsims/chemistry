//
// Reactions App
//

import SwiftUI

struct TitrationComponentState {

    init(
        strongAcid: AcidOrBase,
        weakAcid: AcidOrBase,
        cols: Int,
        rows: Int,
        settings: TitrationSettings = .standard
    ) {
        let strongPreparationModel = TitrationStrongSubstancePreparationModel(
            substance: strongAcid,
            titrant: .potassiumHydroxide,
            cols: cols,
            rows: rows,
            settings: settings
        )
        let strongPreEPModel = TitrationStrongSubstancePreEPModel(previous: strongPreparationModel)
        let strongPostEPModel = TitrationStrongSubstancePostEPModel(previous: strongPreEPModel)

        let weakPreparationModel = TitrationWeakSubstancePreparationModel(
            substance: weakAcid,
            titrant: .potassiumHydroxide,
            cols: cols,
            rows: rows,
            settings: settings
        )
        let weakPreEPModel = TitrationWeakSubstancePreEPModel(previous: weakPreparationModel)
        let weakPostEPModel = TitrationWeakSubstancePostEPModel(previous: weakPreEPModel)

        self.state = State(substance: .strongAcid, phase: .preparation)
        self.initialCols = cols
        self.initialRows = rows
        self.settings = settings
        self.strongSubstancePreparationModel = strongPreparationModel
        self.strongSubstancePreEPModel = strongPreEPModel
        self.strongSubstancePostEPModel = strongPostEPModel
        self.weakSubstancePreparationModel = weakPreparationModel
        self.weakSubstancePreEPModel = weakPreEPModel
        self.weakSubstancePostEPModel = weakPostEPModel
    }

    private(set) var state: State

    private(set) var strongSubstancePreparationModel: TitrationStrongSubstancePreparationModel
    private(set) var strongSubstancePreEPModel: TitrationStrongSubstancePreEPModel
    private(set) var strongSubstancePostEPModel: TitrationStrongSubstancePostEPModel

    private(set) var weakSubstancePreparationModel: TitrationWeakSubstancePreparationModel
    private(set) var weakSubstancePreEPModel: TitrationWeakSubstancePreEPModel
    private(set) var weakSubstancePostEPModel: TitrationWeakSubstancePostEPModel

    private let settings: TitrationSettings
    private let initialCols: Int
    private let initialRows: Int

    private var strongAcidSavedState: StrongSubstanceModels?
    private var strongBaseSavedState: StrongSubstanceModels?
    private var weakAcidSavedState: WeakSubstanceModels?
    private var weakBaseSavedState: WeakSubstanceModels?
}

// MARK: - Set model data
extension TitrationComponentState {
    func setRows(_ rows: CGFloat) {
        if state.phase == .preparation && state.substance.isStrong {
            strongSubstancePreparationModel.exactRows = rows
        } else if state.phase == .preparation {
            weakSubstancePreparationModel.exactRows = rows
            // TODO rows
        }
    }

    func setSubstance(_ substance: AcidOrBase) {
        if state.phase == .preparation && state.substance.isStrong {
            strongSubstancePreparationModel.substance = substance
        } else if state.phase == .preparation {
            // TODO
        }
    }
}

// MARK: - API Data access
extension TitrationComponentState {
    var currentPH: CGFloat {
        let isStrong = state.substance.isStrong
        switch state.phase {
        case .preparation where isStrong:
            return currentPH(
                strongSubstancePreparationModel.equationData,
                CGFloat(strongSubstancePreparationModel.substanceAdded)
            )
        case .preEP where isStrong:
            return currentPH(
                strongSubstancePreEPModel.equationData,
                CGFloat(strongSubstancePreEPModel.titrantAdded)
            )

        case .postEP where isStrong:
            return currentPH(
                strongSubstancePostEPModel.equationData,
                CGFloat(strongSubstancePostEPModel.titrantAdded)
            )

        case .preparation:
            return currentPH(
                weakSubstancePreparationModel.equationData,
                CGFloat(weakSubstancePreparationModel.substanceAdded)
            )
        case .preEP:
            return currentPH(
                weakSubstancePreEPModel.equationData,
                CGFloat(weakSubstancePreEPModel.titrantAdded)
            )

        case .postEP:
            return currentPH(
                weakSubstancePostEPModel.equationData,
                CGFloat(weakSubstancePostEPModel.titrantAdded)
            )
        }
    }

    private func currentPH(_ equationData: TitrationEquationData, _ input: CGFloat) -> CGFloat {
        equationData.pValues.value(for: .hydrogen).getY(at: input)
    }
}

// MARK: - API Model access
extension TitrationComponentState {
    var currentPreparationModel: TitrationPreparationModel? {
        guard state.phase == .preparation else {
            return nil
        }
        if state.substance.isStrong {
            return strongSubstancePreparationModel
        }
        return weakSubstancePreparationModel
    }

    var currentTitrantInputLimits: TitrantInputModel? {
        let isStrong = state.substance.isStrong
        switch state.phase {
        case .preEP where isStrong: return strongSubstancePreEPModel
        case .postEP where isStrong: return strongSubstancePostEPModel
        case .preEP: return weakSubstancePreEPModel
        case .postEP: return weakSubstancePostEPModel
        default: return nil
        }
    }

    var currentPreEPTitrantModel: TitrantInputModel? {
        let isStrong = state.substance.isStrong
        let isPreEP = state.phase == .preEP
        if isPreEP && isStrong {
            return strongSubstancePreEPModel
        } else if isPreEP {
            return weakSubstancePreEPModel
        }
        return nil
    }

    var currentPostEPTitrantModel: TitrantInputModel? {
        let isStrong = state.substance.isStrong
        let isPostEP = state.phase == .postEP
        if isPostEP && isStrong {
            return strongSubstancePostEPModel
        } else if isPostEP {
            return weakSubstancePostEPModel
        }
        return nil
    }
}

// MARK: - Data types
extension TitrationComponentState {

    struct State: Equatable {
        let substance: Substance
        let phase: Phase
    }

    enum Phase: CaseIterable {
        case preparation, preEP, postEP
    }

    enum Substance: CaseIterable {
        case strongAcid, strongBase, weakAcid, weakBase

        var isStrong: Bool {
            self == .strongAcid || self == .strongBase
        }
    }

    private struct StrongSubstanceModels {
        let preparation: TitrationStrongSubstancePreparationModel
        let preEP: TitrationStrongSubstancePreEPModel
        let postEP: TitrationStrongSubstancePostEPModel
    }

    private struct WeakSubstanceModels {
        let preparation: TitrationWeakSubstancePreparationModel
        let preEP: TitrationWeakSubstancePreEPModel
        let postEP: TitrationWeakSubstancePostEPModel
    }
}

// MARK: - Navigation
extension TitrationComponentState {

    /// Goes to the provided state, with an assertion that the new state was applied
    mutating func assertGoTo(state newState: State) {
        assert(goTo(state: newState), "Could not go to new state. From: \(state), to: \(newState)")
    }

    /// Goes to the provided state.
    ///
    /// - Returns: True if the state was applied, else false
    mutating func goTo(state newState: State) -> Bool {
        let didGoForward = goForwardTo(state: newState)
        let didGoBackward = !didGoForward && goBackTo(state: newState)

        if didGoForward || didGoBackward {
            state = newState
            return true
        }
        return false
    }

    private mutating func goForwardTo(state newState: State) -> Bool {
        let isSameSubstance = state.substance == newState.substance

        switch (state.phase, newState.phase) {

        // We must set the post EP model here, as the pH equation is visible on screen
        case (.preparation, .preEP) where isSameSubstance:
            initialiseModel(substance: state.substance, phase: .preEP)
            initialiseModel(substance: state.substance, phase: .postEP)
            break

        // We se the post EP model again to reset its state
        case (.preEP, .postEP) where isSameSubstance:
            initialiseModel(substance: state.substance, phase: .postEP)
            break

        case (.postEP, .preparation):
            if let nextSubstance = Substance.allCases.element(after: state.substance),
               nextSubstance == newState.substance {
                saveModels(forSubstance: state.substance)
                initialiseModel(substance: nextSubstance, phase: .preparation)
                return true
            }
            return false

        default: return false
        }

        return true
    }

    private mutating func goBackTo(state newState: State) -> Bool {
        let isSameSubstance = state.substance == newState.substance

        switch (state.phase, newState.phase) {

        // These cases are valid, but need no action
        case (.preEP, .preparation) where isSameSubstance: break
        case (.postEP, .preEP) where isSameSubstance: break

        case (.preparation, .postEP):
            if let previousSubstance = Substance.allCases.element(before: state.substance),
               previousSubstance == newState.substance {
                return restoreModels(forSubstance: previousSubstance)
            }
            return false

        default: return false
        }

        return true
    }
}

// MARK: - Actions
private extension TitrationComponentState {
    private mutating func initialiseModel(
        substance: Substance,
        phase: Phase
    ) {
        switch phase {
        case .preparation where substance.isStrong:
            strongSubstancePreparationModel = TitrationStrongSubstancePreparationModel(
                substance: substance == .strongAcid ? .strongAcids.first! : .strongBases.first!,
                titrant: substance == .strongAcid ? .potassiumHydroxide : .hydrogenChloride,
                cols: initialCols,
                rows: initialRows,
                settings: settings
            )
        case .preEP where substance.isStrong:
            strongSubstancePreEPModel = .init(previous: strongSubstancePreparationModel)

        case .postEP where substance.isStrong:
            strongSubstancePostEPModel = .init(previous: strongSubstancePreEPModel)

        case .preparation:
            weakSubstancePreparationModel = TitrationWeakSubstancePreparationModel(
                substance: substance == .weakAcid ? .weakAcids.first! : .weakBases.first!,
                titrant: substance == .weakAcid ? .potassiumHydroxide : .hydrogenChloride,
                cols: initialCols,
                rows: initialRows,
                settings: settings
            )

        case .preEP:
            weakSubstancePreEPModel = .init(previous: weakSubstancePreparationModel)

        case .postEP:
            weakSubstancePostEPModel = .init(previous: weakSubstancePreEPModel)
        }
    }

    private mutating func restoreModels(forSubstance substance: Substance) -> Bool {
        func restoreStrong(_ models: StrongSubstanceModels?) -> Bool {
            if let models = models {
                restoreStrongSubstanceModels(models)
                return true
            }
            return false
        }

        func restoreWeak(_ models: WeakSubstanceModels?) -> Bool {
            if let models = models {
                restoreWeakSubstanceModels(models)
                return true
            }
            return false
        }

        switch substance {
        case .strongAcid: return restoreStrong(strongAcidSavedState)
        case .strongBase: return restoreStrong(strongBaseSavedState)
        case .weakAcid: return restoreWeak(weakAcidSavedState)
        case .weakBase: return restoreWeak(weakBaseSavedState)
        }
    }

    private mutating func saveModels(forSubstance substance: Substance) {
        switch substance {
        case .strongAcid:
            strongAcidSavedState = strongSubstanceModels
        case .strongBase:
            strongBaseSavedState = strongSubstanceModels
        case .weakAcid:
            weakAcidSavedState = weakSubstanceModels
        case .weakBase:
            weakBaseSavedState = weakSubstanceModels
        }
    }

    private mutating func restoreStrongSubstanceModels(_ models: StrongSubstanceModels) {
        strongSubstancePreparationModel = models.preparation
        strongSubstancePreEPModel = models.preEP
        strongSubstancePostEPModel = models.postEP
    }

    private mutating func restoreWeakSubstanceModels(_ models: WeakSubstanceModels) {
        weakSubstancePreparationModel = models.preparation
        weakSubstancePreEPModel = models.preEP
        weakSubstancePostEPModel = models.postEP
    }

    private var strongSubstanceModels: StrongSubstanceModels {
        StrongSubstanceModels(
            preparation: strongSubstancePreparationModel,
            preEP: strongSubstancePreEPModel,
            postEP: strongSubstancePostEPModel
        )
    }

    private var weakSubstanceModels: WeakSubstanceModels {
        WeakSubstanceModels(
            preparation: weakSubstancePreparationModel,
            preEP: weakSubstancePreEPModel,
            postEP: weakSubstancePostEPModel
        )
    }
}
