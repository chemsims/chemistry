//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class LimitingReagentComponentTests: XCTestCase {

    func testMolarityAndMolesOfLimitingReactant() {
        let reaction = reaction()
        let model = newModel(
            reaction: reaction,
            rows: 5,
            rowsToVolume: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 0.5)
        )
        model.rows = 10
        
        XCTAssertEqual(model.volume, 0.5)
        model.addLimitingReactant(count: 20)

        XCTAssertEqual(model.limitingReactantMolarity, 0.2)
        XCTAssertEqual(model.equationData.limitingReactantMoles, 0.5 * 0.2)
    }

    func testExcessReactantTheoreticalMoles() {
        let coeff = 3
        let reaction = reaction(excessReactantCoefficient: coeff)
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 30)

        let expectedMoles = CGFloat(coeff) * model.equationData.limitingReactantMoles
        XCTAssertEqual(model.equationData.neededExcessReactantMoles, expectedMoles)
    }

    func testProductTheoreticalMolesAndMass() {
        let reaction = reaction(
            yield: 0.5,
            excessReactantCoefficient: 2,
            excessReactantMolecularMass: 50
        )
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 20)

        let expectedMass = model.equationData.limitingReactantMoles * CGFloat(reaction.product.molarMass)
        XCTAssertEqual(model.equationData.theoreticalProductMoles, model.equationData.limitingReactantMoles)
        XCTAssertEqual(model.equationData.theoreticalProductMass, expectedMass)
    }

    func testActualProductMolesAndMass() {
        let reaction = reaction(
            yield: 0.5,
            excessReactantCoefficient: 2,
            productMolecularMass: 50
        )
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 20)

        let initialMass = model.equationData.actualProductMass.getY(at: 0)
        let finalMass = model.equationData.actualProductMass.getY(at: 1)

        XCTAssertEqual(initialMass, 0)
        XCTAssertEqual(finalMass, model.equationData.theoreticalProductMass * 0.5)

        let initialMoles = model.equationData.actualProductMoles.getY(at: 0)
        let finalMoles = model.equationData.actualProductMoles.getY(at: 1)
        XCTAssertEqual(initialMoles, 0)
        XCTAssertEqual(finalMoles, finalMass / CGFloat(reaction.product.molarMass))
    }

    func testActualReactantMolesAndMass() {
        let coeff = 3
        let reaction = reaction(
            yield: 0.5,
            excessReactantCoefficient: coeff,
            productMolecularMass: 50
        )
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 20)

        let initialMoles = model.equationData.reactingExcessReactantMoles.getY(at: 0)
        let finalMoles = model.equationData.reactingExcessReactantMoles.getY(at: 1)

        let finalProductMoles = model.equationData.actualProductMoles.getY(at: 1)
        let expectedFinalMoles = CGFloat(coeff) * finalProductMoles

        XCTAssertEqual(initialMoles, 0)
        XCTAssertEqual(finalMoles, expectedFinalMoles)

        let initialMass = model.equationData.reactingExcessReactantMass.getY(at: 0)
        let finalMass = model.equationData.reactingExcessReactantMass.getY(at: 1)

        XCTAssertEqual(initialMass, 0)
        XCTAssertEqual(finalMass, finalMoles * CGFloat(reaction.excessReactant.molarMass))
    }

    func testCoordsArePopulatedWhenAddingLimitingReactant() {
        let model = newModel(reaction: reaction())

        model.addLimitingReactant(count: 10)
        XCTAssertEqual(Set(model.limitingReactantCoords).count, 10)

        model.addLimitingReactant(count: 5)
        XCTAssertEqual(Set(model.limitingReactantCoords).count, 15)
    }

    func testCoordsArePopulatedWhenAddingExcessReactant() {
        let model = newModel(reaction: reaction())

        model.addLimitingReactant(count: 10)
        model.addExcessReactant(count: 10)

        let limitingCoordsSet = Set(model.limitingReactantCoords)
        let excessCoordsSet = Set(model.excessReactantCoords)

        XCTAssertEqual(excessCoordsSet.count, 10)
        XCTAssertEqual(limitingCoordsSet.intersection(excessCoordsSet).count, 0)
    }

    func testProductCoordsAreProducedAfterAddingExcessReactant() {
        let model = newModel(reaction: reaction())

        model.addLimitingReactant(count: 10)
        model.addExcessReactant(count: 10)

        model.prepareReaction()

        XCTAssertEqual(model.productCoords.count, 18)

        let setOfProduct = Set(model.productCoords)
        let setOfLimitingReactant = Set(model.limitingReactantCoords)
        let setOfExcessReactant = Set(model.excessReactantCoords)

        XCTAssertEqual(setOfProduct.intersection(setOfLimitingReactant).count, 9)
        XCTAssertEqual(setOfProduct.intersection(setOfExcessReactant).count, 9)
    }

    func testInputLimitsOfLimitingReactant() {
        let minLimitingCoords = 15
        let minExtraToAdd = 10
        let settings = LimitingReagentComponents.Settings(
            minLimitingReactantCoords: minLimitingCoords,
            minExtraReactantCoordsToAdd: minExtraToAdd
        )
        let excessCoeff = 3
        let reaction = reaction(excessReactantCoefficient: excessCoeff)
        let model = newModel(reaction: reaction, settings: settings)
        XCTAssert(model.canAdd(reactant: .limiting))
        XCTAssertFalse(model.hasAddedEnough(of: .limiting))

        model.addLimitingReactant(count: minLimitingCoords)
        XCTAssert(model.canAdd(reactant: .limiting))
        XCTAssert(model.hasAddedEnough(of: .limiting))

        let maxCountOfReactants = 100 - minExtraToAdd
        let maxCountOfLimitingReactant = maxCountOfReactants / (1 + excessCoeff)

        model.addLimitingReactant(count: 100)
        XCTAssertEqual(model.limitingReactantCoords.count, maxCountOfLimitingReactant)
        XCTAssertFalse(model.canAdd(reactant: .limiting))
        XCTAssert(model.hasAddedEnough(of: .limiting))
    }

    func testInputLimitsOfExcessReactantWhenAddingTheMaximumLimitingReactant() {
        let minLimitingCoords = 5
        let minExtraToAdd = 10
        let settings = LimitingReagentComponents.Settings(
            minLimitingReactantCoords: minLimitingCoords,
            minExtraReactantCoordsToAdd: minExtraToAdd
        )
        let excessCoeff = 2
        let reaction = reaction(excessReactantCoefficient: excessCoeff)
        let model = newModel(reaction: reaction, settings: settings)

        model.addLimitingReactant(count: 10)

        XCTAssertFalse(model.hasAddedEnough(of: .excess))
        XCTAssert(model.canAdd(reactant: .excess))

        let neededExcessCoords = 10 * excessCoeff
        model.addExcessReactant(count: 2 * neededExcessCoords)
        XCTAssertEqual(model.excessReactantCoords.count, neededExcessCoords)
        XCTAssert(model.hasAddedEnough(of: .excess))
        XCTAssertFalse(model.canAdd(reactant: .excess))

        model.shouldReactExcessReactant = false
        XCTAssert(model.canAdd(reactant: .excess))
        XCTAssertFalse(model.hasAddedEnough(of: .excess))

        model.addExcessReactant(count: minExtraToAdd)
        XCTAssertEqual(model.excessReactantCoords.count, neededExcessCoords + minExtraToAdd)
        XCTAssert(model.canAdd(reactant: .excess))
        XCTAssert(model.hasAddedEnough(of: .excess))

        model.addExcessReactant(count: 100)
        XCTAssertEqual(model.limitingReactantCoords.count, 10)
        XCTAssertEqual(model.excessReactantCoords.count, 90)
    }

    func testInputLimitsOfExcessReactantWhenAddingTheMinimumLimitingReactant() {
        let minLimitingCoords = 10
        let minExtraToAdd = 5
        let settings = LimitingReagentComponents.Settings(
            minLimitingReactantCoords: minLimitingCoords,
            minExtraReactantCoordsToAdd: minExtraToAdd
        )
        let excessCoeff = 2
        let reaction = reaction(excessReactantCoefficient: excessCoeff)
        let model = newModel(reaction: reaction, settings: settings)

        model.addLimitingReactant(count: minLimitingCoords)

        let maxExcessCoords = excessCoeff * minLimitingCoords
        model.addExcessReactant(count: maxExcessCoords)
        XCTAssertFalse(model.canAdd(reactant: .excess))
        XCTAssert(model.hasAddedEnough(of: .excess))
    }

    func testAllReactionsHaveValidInputLimits() {
        func doTest(reaction: LimitingReagentReaction) {
            let model = LimitingReagentComponents(reaction: reaction)
            model.rows = CGFloat(ChemicalReactionsSettings.minRows)

            XCTAssert(model.canAdd(reactant: .limiting))
            XCTAssertFalse(model.hasAddedEnough(of: .limiting))

            model.addLimitingReactant(count: model.settings.minLimitingReactantCoords)
            XCTAssert(model.hasAddedEnough(of: .limiting))

            while(!model.hasAddedEnough(of: .excess)) {
                model.addExcessReactant(count: 1)
            }

            model.shouldReactExcessReactant = false
            while(!model.hasAddedEnough(of: .excess)) {
                model.addExcessReactant(count: 1)
            }

            let limitingCount = model.limitingReactantCoords.count
            let excessCount = model.excessReactantCoords.count
            let gridSize = model.beakerCols * ChemicalReactionsSettings.minRows
            XCTAssertLessThanOrEqual(limitingCount + excessCount, gridSize)
        }

        LimitingReagentReaction.availableReactions.forEach { reaction in
            doTest(reaction: reaction)
        }
    }

    func testReactionProgressIsPopulatedWhenAddingReactants() {
        let settings = LimitingReagentComponents.Settings(
            minLimitingReactantCoords: 10,
            minExtraReactantCoordsToAdd: 10,
            minLimitingReactantReactionProgressMolecules: 2
        )
        let model = newModel(
            reaction: reaction(excessReactantCoefficient: 2),
            settings: settings
        )

        func countOf(_ element: LimitingReagentComponents.Element) -> Int {
            model.reactionProgressModel.moleculeCounts(ofType: element)
        }

        model.addLimitingReactant(count: 10)

        XCTAssertGreaterThanOrEqual(countOf(.limitingReactant), 2)

        while(model.canAdd(reactant: .limiting)) {
            model.addLimitingReactant(count: 1)
        }

        // there will be double the number of excess reactant, so should only fill half
        XCTAssertEqual(countOf(.limitingReactant), settings.maxReactionProgressMolecules / 2)

        while(model.canAdd(reactant: .excess)) {
            model.addExcessReactant(count: 1)
        }
        XCTAssertEqual(countOf(.excessReactant), settings.maxReactionProgressMolecules)
    }

    func testExcessReactantReactionProgressMoleculesHaveDoubleTheLimitingReactantForCoefficientOfTwo() {
        let settings = LimitingReagentComponents.Settings(
            minLimitingReactantCoords: 10,
            minExtraReactantCoordsToAdd: 10,
            minLimitingReactantReactionProgressMolecules: 2
        )
        let model = newModel(
            reaction: reaction(excessReactantCoefficient: 2),
            settings: settings
        )

        func countOf(_ element: LimitingReagentComponents.Element) -> Int {
            model.reactionProgressModel.moleculeCounts(ofType: element)
        }

        model.addLimitingReactant(count: 10)

        XCTAssertGreaterThanOrEqual(countOf(.limitingReactant), 2)

        model.addMaximumExcessReactant()
        XCTAssertEqual(countOf(.excessReactant), 2 * countOf(.limitingReactant))
    }

    func testResettingLimitingReactantCoords() {
        let model = newModel(reaction: reaction())
        model.addMaximumLimitingReactant()

        model.resetLimitingReactantCoords()

        XCTAssertEqual(model.limitingReactantCoords.count, 0)
        XCTAssertEqual(model.reactionProgressModel.moleculeCounts(ofType: .limitingReactant), 0)
    }

    func testResettingExcessReactantCoords() {
        let model = newModel(reaction: reaction())

        func countOfRPMolecules(_ element: LimitingReagentComponents.Element) -> Int {
            model.reactionProgressModel.moleculeCounts(ofType: element)
        }

        model.addMaximumLimitingReactant()

        let initialLimitingRPMolecules = countOfRPMolecules(.limitingReactant)

        model.addMaximumExcessReactant()

        model.resetExcessReactantCoords()

        XCTAssertEqual(model.excessReactantCoords.count, 0)
        XCTAssertEqual(countOfRPMolecules(.excessReactant), 0)
        XCTAssertEqual(countOfRPMolecules(.limitingReactant), initialLimitingRPMolecules)
    }

    func testResettingReaction() {
        func countOfRPMolecules(_ element: LimitingReagentComponents.Element) -> Int {
            model.reactionProgressModel.moleculeCounts(ofType: element)
        }

        let model = newModel(reaction: reaction())
        model.addMaximumLimitingReactant()
        model.addMaximumExcessReactant()

        let initialLimiting = countOfRPMolecules(.limitingReactant)
        let initialExcess = countOfRPMolecules(.excessReactant)

        model.runAllReactionProgressReactions(duration: 0)

        model.resetReactionCoords()

        XCTAssertEqual(countOfRPMolecules(.limitingReactant), initialLimiting)
        XCTAssertEqual(countOfRPMolecules(.excessReactant), initialExcess)
        XCTAssertEqual(countOfRPMolecules(.product), 0)
    }

    func testResettingNonReactingExcessReactantCoords() {
        let model = newModel(reaction: reaction())
        model.addMaximumLimitingReactant()
        model.addMaximumExcessReactant()

        model.shouldReactExcessReactant = false

        let initialLimitingCount = model.limitingReactantCoords.count
        let initialExcessCount = model.excessReactantCoords.count

        model.runAllReactionProgressReactions(duration: 0)
        model.addMaximumExcessReactant()
        model.resetNonReactingExcessReactantCoords()

        XCTAssertEqual(model.limitingReactantCoords.count, initialLimitingCount)
        XCTAssertEqual(model.excessReactantCoords.count, initialExcessCount)

        let excessRPCountPostReset = model.reactionProgressModel.moleculeCounts(
            ofType: .excessReactant
        )
        XCTAssertEqual(excessRPCountPostReset, 0)
    }

    private func newModel(
        reaction: LimitingReagentReaction,
        rows: Int = 10,
        cols: Int = 10,
        rowsToVolume: Equation = IdentityEquation(),
        settings: LimitingReagentComponents.Settings = .init()
    ) -> LimitingReagentComponents {
        LimitingReagentComponents(
            reaction: reaction,
            initialRows: rows,
            cols: cols,
            rowsToVolume: rowsToVolume,
            settings: settings
        )
    }

    private func reaction(
        yield: CGFloat = 1,
        excessReactantCoefficient: Int = 1,
        excessReactantMolecularMass: Int = 1,
        productMolecularMass: Int = 1
    ) -> LimitingReagentReaction {
        LimitingReagentReaction(
            yield: yield,
            limitingReactant: .init(
                name: "",
                state: .aqueous,
                color: .red
            ),
            excessReactant: .init(
                name: "",
                state: .aqueous,
                color: .red,
                coefficient: excessReactantCoefficient,
                molarMass: excessReactantMolecularMass
            ),
            product: .init(
                name: "",
                state: .aqueous,
                color: .red,
                molarMass: productMolecularMass
            ),
            firstExtraProduct: nil,
            secondExtraProduct: nil
        )
    }
}

private extension LimitingReagentComponents {
    func addMaximumLimitingReactant() {
        while canAdd(reactant: .limiting) {
            addLimitingReactant(count: 1)
        }
    }

    func addMaximumExcessReactant() {
        while canAdd(reactant: .excess) {
            addExcessReactant(count: 1)
        }
    }
}
