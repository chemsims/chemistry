//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationComponentsTests: XCTestCase {

    func testCoordinatesIncreaseAfterAddingKnownReactant() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 5)
        let coords = model.coords(for: .knownReactant)
        XCTAssertEqual(coords.coords(at: 0).count, 5)
    }

    func testKnownMolarityAndMolesIncreaseAfterAddingKnownReactant() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 10)

        XCTAssertEqual(model.knownReactantInitialMolarity, 0.1)
        let expectedMoles = model.volume * 0.1
        XCTAssertEqual(model.knownReactantInitialMoles, expectedMoles)
    }

    func testKnownMolarityAndMolesStayTheSameThroughAllReactions() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)

        let expectedMoles = model.volume * 0.2
        func checkMolesAndMolarity() {
            XCTAssertEqual(model.knownReactantInitialMolarity, 0.2)
            XCTAssertEqual(model.knownReactantInitialMoles, expectedMoles)
        }

        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        checkMolesAndMolarity()

        model.goNextTo(phase: .runReaction)
        checkMolesAndMolarity()

        model.goNextTo(phase: .addExtraUnknownReactant)
        checkMolesAndMolarity()
        model.add(reactant: .unknown, count: 10)

        model.goNextTo(phase: .runFinalReaction)
        checkMolesAndMolarity()
    }

    func testKnownReactantCoordinatesAreResetAfterAddingKnownReactantAndResettingPhase() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 5)
        model.resetPhase()
        let coords = model.coords(for: .knownReactant)
        XCTAssertEqual(coords.coords(at: 0).count, 0)
    }

    func testCoordinatesIncreaseAfterAddingUnKnownReactant() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 5)

        let coords = model.coords(for: .unknownReactant)
        XCTAssertEqual(coords.coords(at: 0).count, 5)
    }

    func testUnknownReactantCoordinatesAreResetAfterAddingUnknownReactantAndResettingPhase() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 5)
        model.resetPhase()

        let coords = model.coords(for: .unknownReactant)
        XCTAssertEqual(coords.coords(at: 0).count, 0)
    }

    func testKnownReactantCoordsAreResetAfterAddingUnknownReactantAndGoingBackAndResetting() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 5)
        model.goBackTo(phase: .addKnownReactant)
        model.resetPhase()

        let knownCoords = model.coords(for: .knownReactant)
        let unKnownCoords = model.coords(for: .unknownReactant)
        XCTAssertEqual(knownCoords.coords(at: 0).count, 0)
        XCTAssertEqual(unKnownCoords.coords(at: 0).count, 0)
    }

    func testUnknownReactantMassAndMolesAddedIncreaseAfterAddingUnknownReactant() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)

        let concentration: CGFloat = 0.1
        let expectedMolesAdded = model.volume * concentration
        let molarMass = model.reaction.unknownReactant.molarMass
        let expectedMassAdded = CGFloat(molarMass) * expectedMolesAdded

        XCTAssertEqual(model.unknownReactantMassAdded, expectedMassAdded)
        XCTAssertEqualWithTolerance(model.unknownReactantMolesAdded, expectedMolesAdded)
    }

    func testReactantCoordsAreConsumedAndProduceProductDuringInitialReactionPhase() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)

        let t2 = model.endOfInitialReaction

        let knownCoords = model.coords(for: .knownReactant)
        let unknownCoords = model.coords(for: .unknownReactant)
        let productCoords = model.coords(for: .product)

        let finalKnown = knownCoords.coords(at: t2).count
        let consumedKnown = 20 - finalKnown
        XCTAssertGreaterThan(consumedKnown, 0)

        let finalUnknown = unknownCoords.coords(at: t2).count
        XCTAssertEqual(finalUnknown, 0)

        let initialProduct = productCoords.coords(at: 0)
        let finalProduct = productCoords.coords(at: t2)
        XCTAssertEqual(initialProduct.count, 0)

        // known reactant and product have the same coeff, so we
        // should produce the same amount of product as reactant is
        // consumed
        XCTAssertEqual(finalProduct.count, consumedKnown)
    }

    func testUnknownReactantReactingMolesAndMassIncreaseDuringReactionPhase() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)

        let massAdded = model.unknownReactantMassAdded

        let t2 = model.endOfInitialReaction

        let moles = model.reactingUnknownReactantMoles
        let molarMass = model.reaction.unknownReactant.molarMass
        let expectedFinalMoles = massAdded / CGFloat(molarMass)

        XCTAssertEqual(moles.getY(at: 0), 0)
        XCTAssertEqual(moles.getY(at: t2), expectedFinalMoles)

        let mass = model.reactingUnknownReactantMass
        XCTAssertEqual(mass.getY(at: 0), 0)
        XCTAssertEqual(mass.getY(at: t2), massAdded)
    }

    func testProductMolesAndMassIncreaseDuringReactionPhase() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)

        let mass = model.productMassProduced
        let moles = model.productMolesProduced

        let t2 = model.endOfInitialReaction

        // unknown reactant coeff is 1, so we expect the number
        // of product moles to equal the unknown reactant moles
        let expectedFinalMoles = model.unknownReactantMolesAdded
        XCTAssertEqual(moles.getY(at: 0), 0)
        XCTAssertEqual(moles.getY(at: t2), expectedFinalMoles)

        let molarMass = CGFloat(model.reaction.product.molarMass)
        let expectedFinalMass = expectedFinalMoles * molarMass
        XCTAssertEqual(mass.getY(at: 0), 0)
        XCTAssertEqual(mass.getY(at: t2), expectedFinalMass)

    }

    func testUnknownReactantCoordsIncreaseWhenAddingExtraReactant() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)
        model.goNextTo(phase: .addExtraUnknownReactant)


        var coords: FractionedCoordinates {
            model.coords(for: .unknownReactant)
        }

        let t1 = model.endOfInitialReaction

        XCTAssertEqual(coords.coords(at: t1).count, 0)

        model.add(reactant: .unknown, count: 8)

        XCTAssertEqual(coords.coords(at: t1).count, 8)
    }

    func testProductCoordsAreUnchangedWhenGoingBackToInitialReaction() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)

        let initialCoords = model.coords(for: .product)

        model.goNextTo(phase: .addExtraUnknownReactant)
        model.goBackTo(phase: .runReaction)

        let coords = model.coords(for: .product)

        let t2 = model.endOfInitialReaction
        let initialT2Coords = initialCoords.coords(at: t2)
        let t2Coords = coords.coords(at: t2)
        XCTAssertEqual(t2Coords, initialT2Coords)
    }

    func testUnknownReactantMassAddedIncreasesAfterAddingExtraUnknownReactant() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)

        let initialMass = model.unknownReactantMassAdded

        model.goNextTo(phase: .runReaction)
        model.goNextTo(phase: .addExtraUnknownReactant)

        XCTAssertEqual(model.unknownReactantMassAdded, initialMass)

        model.add(reactant: .unknown, count: 10)

        // we add the same amount, so mass should double
        let expected = 2 * initialMass
        XCTAssertEqual(model.unknownReactantMassAdded, expected)
    }

    func testUnknownReactantReactingMassAndMolesIncreaseDuringSecondReaction() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)

        let initialMass = model.unknownReactantMassAdded

        model.goNextTo(phase: .runReaction)
        model.goNextTo(phase: .addExtraUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runFinalReaction)

        let mass = model.reactingUnknownReactantMass

        let t1 = model.endOfInitialReaction
        let t2 = model.endOfFinalReaction

        XCTAssertEqual(mass.getY(at: 0), 0)
        XCTAssertEqual(mass.getY(at: t1), initialMass)
        XCTAssertEqual(mass.getY(at: t2), 2 * initialMass)

        let molarMass = model.reaction.unknownReactant.molarMass
        let expectedMoles = mass / CGFloat(molarMass)
        let moles = model.reactingUnknownReactantMoles
        XCTAssertEqual(moles.getY(at: 0), 0)
        XCTAssertEqual(moles.getY(at: t1), expectedMoles.getY(at: t1))
        XCTAssertEqual(moles.getY(at: t2), expectedMoles.getY(at: t2))
    }

    func testPrecipitateGrowsAfterFirstReaction() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)

        let initialRect = model.precipitate2.boundingRect(at: model.endOfInitialReaction)
        XCTAssertEqual(initialRect.width, 0)
        XCTAssertEqual(initialRect.height, 0)

        model.runReaction()

        let rect = model.precipitate2.boundingRect(at: model.endOfInitialReaction)
        XCTAssertGreaterThan(rect.width, 0)
        XCTAssertGreaterThan(rect.height, 0)
    }

    func testPrecipitateIsResetWhenGoingBackFromInitialReaction() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 20)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 10)
        model.goNextTo(phase: .runReaction)

        model.runReaction()
        model.goToPreviousPhase()

        let rect = model.precipitate2.boundingRect(at: 0)
        XCTAssertEqual(rect.width, 0)
        XCTAssertEqual(rect.height, 0)
    }

    func testMoreProductIsProducedDuringSecondReaction() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 50)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 25)
        model.goNextTo(phase: .runReaction)

        let initialCoords = model.coords(for: .product)

        model.goNextTo(phase: .addExtraUnknownReactant)
        model.add(reactant: .unknown, count: 20)
        model.goNextTo(phase: .runFinalReaction)

        let coords = model.coords(for: .product)

        let t1 = model.endOfInitialReaction
        let t2 = model.endOfFinalReaction

        XCTAssertEqual(coords.coords(at: t1), initialCoords.coords(at: t1))
        XCTAssertGreaterThan(
            coords.coords(at: t2).count,
            initialCoords.coords(at: t2).count
        )
    }

    func testRPMoleculesOfUnknownReactantIsSameAsKnownReactantAtStartOfFinalReactionForUnitCoefficient() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 34)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 15)
        model.goNextTo(phase: .runReaction)
        model.completeReaction()
        model.goNextTo(phase: .addExtraUnknownReactant)
        while (model.canAdd(reactant: .unknown)) {
            model.add(reactant: .unknown, count: 1)
        }

        let knownCount = model.reactionProgressModel.moleculeCounts(ofType: .knownReactant)
        let unknownCount = model.reactionProgressModel.moleculeCounts(ofType: .unknownReactant)

        XCTAssertEqual(unknownCount, knownCount)
    }

    func testRPMoleculesOfUnknownReactantIsDoubleKnownReactantAtStartOfFinalReactionForDoubleCoefficient() {
        let model = PrecipitationComponents(unknownReactantCoeff: 2)
        model.add(reactant: .known, count: 34)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 16)
        model.goNextTo(phase: .runReaction)
        model.completeReaction()
        model.goNextTo(phase: .addExtraUnknownReactant)
        while (model.canAdd(reactant: .unknown)) {
            model.add(reactant: .unknown, count: 1)
        }

        let knownCount = model.reactionProgressModel.moleculeCounts(ofType: .knownReactant)
        let unknownCount = model.reactionProgressModel.moleculeCounts(ofType: .unknownReactant)

        XCTAssertEqual(unknownCount, 2 * knownCount)
    }

    func testReactantsHaveNoReactionProgressMoleculesAtStartOfFinalReaction() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 39)
        model.goNextTo(phase: .addUnknownReactant)
        model.add(reactant: .unknown, count: 21)
        model.goNextTo(phase: .runReaction)
        model.completeReaction()
        model.goNextTo(phase: .addExtraUnknownReactant)
        while (model.canAdd(reactant: .unknown)) {
            model.add(reactant: .unknown, count: 1)
        }
        model.goNextTo(phase: .runFinalReaction)
        model.completeReaction()

        let knownCount = model.reactionProgressModel.moleculeCounts(ofType: .knownReactant)
        let unknownCount = model.reactionProgressModel.moleculeCounts(ofType: .unknownReactant)

        XCTAssertEqual(knownCount, 0)
        XCTAssertEqual(unknownCount, 0)
    }
}

private extension PrecipitationComponents {
    convenience init(unknownReactantCoeff: Int = 1) {
        self.init(
            reaction: .init(unknownReactantCoeff: unknownReactantCoeff),
            rows: 10,
            cols: 10,
            volume: 0.5,
            settings: .init(
                minConcentrationOfKnownReactantPostFirstReaction: 0,
                minConcentrationOfUnknownReactantToReact: 0
            )
        )
    }
}

private extension PrecipitationReaction {
    init(unknownReactantCoeff: Int) {
        let first = Self.availableReactionsWithRandomMetals().first!
        self.init(
            knownReactant: first.knownReactant,
            unknownReactant: .init(
                latterPart: first.unknownReactant.latterPart,
                state: first.unknownReactant.state,
                latterPartMolarMass: first.unknownReactant.latterPartMolarMass,
                metal: first.unknownReactant.metal,
                metalAtomCount: first.unknownReactant.metalAtomCount,
                coeff: unknownReactantCoeff
            ),
            product: first.product,
            secondaryProduct: first.secondaryProduct
        )
    }
}
