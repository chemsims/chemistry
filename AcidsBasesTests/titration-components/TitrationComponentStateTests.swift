//
// Reactions App
//

import XCTest
@testable import AcidsBases

class TitrationComponentStateTests: XCTestCase {

    func testStrongAcidPreparationToStrongAcidPreEP() {
        var model = newModel()
        checkCanOnlyGoTo(states: [.strongAcidPreEP], model: model)

        model.strongPrep.incrementSubstance(count: 20)
        _ = model.goTo(state: .strongAcidPreEP)

        XCTAssertEqual(model.state, .init(substance: .strongAcid, phase: .preEP))

        XCTAssertIdentical(model.strongPrep, model.strongPreEp.previous)

        XCTAssertEqual(
            model.strongPrep.primaryIonCoords.coords,
            model.strongPreEp.primaryIonCoords.molecules.coords
        )

        // The post EP model also needs to be set, since it's pH equation
        // will be visible
        XCTAssertIdentical(model.strongPreEp, model.strongPostEp.previous)

        // Check going back resets titrant count, and maintains initial substance count
        model.strongPreEp.incrementTitrant(count: 1)
        XCTAssertEqual(model.strongPreEp.titrantAdded, 1)
        _ = model.goTo(state: .strongAcidPrep)

        XCTAssertEqual(model.strongPrep.substanceAdded, 20)

        _ = model.goTo(state: .strongAcidPreEP)
        XCTAssertEqual(model.strongPreEp.titrantAdded, 0)
    }

    func testStrongAcidPreEPToStrongAcidPostEP() {
        var model = newModel()
        model.strongSubstancePreparationModel.incrementSubstance(count: 20)
        _ = model.goTo(state: .strongAcidPreEP)

        checkCanOnlyGoTo(
            states: [.strongAcidPrep, .strongAcidPostEP],
            model: model
        )

        model.strongPreEp.incrementTitrant(count: model.strongPreEp.maxTitrant)

        _ = model.goTo(state: .strongAcidPostEP)

        XCTAssertIdentical(model.strongPreEp, model.strongPostEp.previous)

        // Check going back & forward resets post EP titrant count, and maintains
        // pre EP titrant count
        model.strongPostEp.incrementTitrant(count: 10)
        _ = model.goTo(state: .strongAcidPreEP)
        XCTAssertEqual(model.strongPreEp.titrantAdded, model.strongPreEp.maxTitrant)
        _ = model.goTo(state: .strongAcidPostEP)
        XCTAssertEqual(model.strongPostEp.titrantAdded, 0)
    }

    func testStrongAcidPostEPToStrongBasePreparation() {
        var model = newModel()

        model.strongPrep.incrementSubstance(count: 20)
        _ = model.goTo(state: .strongAcidPreEP)

        model.strongPreEp.incrementTitrant(count: model.strongPreEp.maxTitrant)
        _ = model.goTo(state: .strongAcidPostEP)

        model.strongPostEp.incrementTitrant(count: model.strongPostEp.maxTitrant)

        checkCanOnlyGoTo(
            states: [.strongAcidPreEP, .strongBasePrep],
            model: model
        )
        _ = model.goTo(state: .strongBasePrep)

        XCTAssertEqual(model.strongPrep.substanceAdded, 0)
        XCTAssertEqual(model.strongPrep.substance.type, .strongBase)

        // Check going back restores the previous state
        checkCanOnlyGoTo(
            states: [.strongAcidPostEP, .strongBasePreEP],
            model: model
        )
        _ = model.goTo(state: .strongAcidPostEP)

        XCTAssertEqual(model.strongPrep.substanceAdded, 20)
        XCTAssertEqual(model.strongPrep.substance.type, .strongAcid)
    }

    private func checkCanOnlyGoTo(
        states validNextStates: [TitrationComponentState.State],
        model: TitrationComponentState
    ) {
        TitrationComponentState.Substance.allCases.forEach { substance in
            TitrationComponentState.Phase.allCases.forEach { phase in
                // goTo is mutating, so we want to use a new copy for each case
                let state = TitrationComponentState.State(
                    substance: substance,
                    phase: phase
                )
                var modelCopy = model
                let didGoToState =  modelCopy.goTo(state: state)
                if validNextStates.contains(state) {
                    XCTAssert(didGoToState, "Failed for \(state)")
                } else {
                    XCTAssertFalse(didGoToState, "Failed for \(state)")
                }
            }
        }
    }

    private func newModel() -> TitrationComponentState {
        TitrationComponentState(
            initialStrongSubstance: .strongAcids.first!,
            initialWeakSubstance: .weakAcids.first!,
            initialTitrant: .potassiumHydroxide,
            cols: 10,
            rows: 10
        )
    }
}

// Define some shorter getters for test convenience
extension TitrationComponentState {
    var strongPrep: TitrationStrongSubstancePreparationModel {
        strongSubstancePreparationModel
    }

    var strongPreEp: TitrationStrongSubstancePreEPModel {
        strongSubstancePreEPModel
    }

    var strongPostEp: TitrationStrongSubstancePostEPModel {
        strongSubstancePostEPModel
    }
}


extension TitrationComponentState.State {

    static let strongAcidPrep = state(.strongAcid, .preparation)
    static let strongAcidPreEP = state(.strongAcid, .preEP)
    static let strongAcidPostEP = state(.strongAcid, .postEP)
    static let strongBasePrep = state(.strongBase, .preparation)
    static let strongBasePreEP = state(.strongBase, .preEP)
    static let strongBasePostEP = state(.strongBase, .postEP)
    static let weakAcidPrep = state(.weakAcid, .preparation)
    static let weakAcidPreEP = state(.weakAcid, .preEP)
    static let weakAcidPostEP = state(.weakAcid, .postEP)
    static let weakBasePrep = state(.weakBase, .preparation)
    static let weakBasePreEP = state(.weakBase, .preEP)
    static let weakBasePostEP = state(.weakBase, .postEP)

    private static func state(
        _ substance: TitrationComponentState.Substance,
        _ phase: TitrationComponentState.Phase
    ) -> TitrationComponentState.State {
        .init(substance: substance, phase: phase)
    }
}
