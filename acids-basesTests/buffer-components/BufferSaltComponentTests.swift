//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class BufferSaltComponentsTests: XCTestCase {

    func testBarChartData() {
        let acid = AcidOrBase.weakAcid(substanceAddedPerIon: 1)
        let weakModelSettings = BufferComponentSettings.withDefaults(
            changeInBarHeightAsFractionOfInitialSubstance: 0.1,
            fractionOfFinalIonMolecules: 0.1
        )
        let weakModel = BufferWeakSubstanceComponents(substance: acid, settings: weakModelSettings, cols: 10, rows: 10)

        weakModel.incrementSubstance(count: 30)
        let saltModel = BufferSaltComponents(prev: weakModel)

        // Correct values before any substance added
        XCTAssertEqual(saltModel.barChartEquations.substance.getY(at: 0), 0.27)
        XCTAssertEqual(saltModel.barChartEquations.primaryIon.getY(at: 0), 0.03)
        XCTAssertEqual(saltModel.barChartEquations.secondaryIon.getY(at: 0), 0.03)

        // One molecule added
        XCTAssertEqual(saltModel.barChartEquations.substance.getY(at: 1), 0.28)
        XCTAssertEqual(saltModel.barChartEquations.primaryIon.getY(at: 1), 0.02, accuracy: 0.0001)
        XCTAssertEqual(saltModel.barChartEquations.secondaryIon.getY(at: 1), 0.03)

        // All of primary molecules gone
        XCTAssertEqual(saltModel.barChartEquations.substance.getY(at: 3), 0.3)
        XCTAssertEqual(saltModel.barChartEquations.primaryIon.getY(at: 3), 0)
        XCTAssertEqual(saltModel.barChartEquations.secondaryIon.getY(at: 3), 0.03)

        // End of adding substance
        XCTAssertEqual(saltModel.barChartEquations.substance.getY(at: CGFloat(saltModel.maxSubstance)), 0.3)
        XCTAssertEqual(saltModel.barChartEquations.primaryIon.getY(at: CGFloat(saltModel.maxSubstance)), 0)
        XCTAssertEqual(saltModel.barChartEquations.secondaryIon.getY(at: CGFloat(saltModel.maxSubstance)), 0.3)
    }

    func testCoords() {
        let weakModel = BufferWeakSubstanceComponents(
            substance: .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                fractionOfFinalIonMolecules: 0.1,
                finalSecondaryIonCount: 2,
                minimumFinalPrimaryIonCount: 12
            ),
            cols: 10,
            rows: 10
        )

        // See weak model property docs or the tests for explanation of
        // of this number
        let expectedMax = 30
        XCTAssertEqual(weakModel.maxSubstanceCount, expectedMax)
        weakModel.incrementSubstance(count: expectedMax)

        let model = BufferSaltComponents(prev: weakModel)
        func molecules(_ part: SubstancePart) -> BeakerMolecules {
            model.reactingModel.consolidated.value(for: part)
        }
        func coordCount(_ part: SubstancePart) -> Int {
            molecules(part).coords.count
        }

        XCTAssertEqual(coordCount(.substance), 24)
        XCTAssertEqual(coordCount(.primaryIon), 3)
        XCTAssertEqual(coordCount(.secondaryIon), 3)

        model.incrementSalt(count: 3)
        XCTAssertEqual(coordCount(.substance), 30)
        XCTAssertEqual(coordCount(.primaryIon), 0)
        XCTAssertEqual(coordCount(.secondaryIon), 3)

        model.incrementSalt(count: 27)
        XCTAssertEqual(coordCount(.substance), 30)
        XCTAssertEqual(coordCount(.primaryIon), 0)
        XCTAssertEqual(coordCount(.secondaryIon), 30)
    }

    func testInputLimits() {
        let weakModel = BufferWeakSubstanceComponents(
            substance: .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                fractionOfFinalIonMolecules: 0.1,
                finalSecondaryIonCount: 2,
                minimumFinalPrimaryIonCount: 12
            ),
            cols: 10,
            rows: 10
        )
        let expectedMax = 30
        XCTAssertEqual(weakModel.maxSubstanceCount, expectedMax)
        weakModel.incrementSubstance(count: weakModel.maxSubstanceCount)

        let model = BufferSaltComponents(prev: weakModel)
        XCTAssertEqual(model.maxSubstance, 30)

        XCTAssertFalse(model.hasAddedEnoughSubstance)
        XCTAssert(model.canAddSubstance)

        model.incrementSalt(count: 100)
        XCTAssert(model.hasAddedEnoughSubstance)
        XCTAssertFalse(model.canAddSubstance)
        XCTAssertEqual(model.substanceAdded, 30)
    }

    func testConcentration() {
        let weakModel = BufferWeakSubstanceComponents(
            substance: .weakAcid(
                secondaryIon: .A,
                substanceAddedPerIon: NonZeroPositiveInt(1)!,
                color: .red,
                kA: 1e-3
            ),
            settings: .withDefaults(
                fractionOfFinalIonMolecules: 0.1,
                finalSecondaryIonCount: 2,
                minimumFinalPrimaryIonCount: 12
            ),
            cols: 10,
            rows: 10
        )
        let expectedMax = 30
        XCTAssertEqual(weakModel.maxSubstanceCount, expectedMax)
        weakModel.incrementSubstance(count: weakModel.maxSubstanceCount)

        let model = BufferSaltComponents(prev: weakModel)
        let initialSubstanceConcentration = 0.3 - weakModel.changeInConcentration

        XCTAssertEqual(model.concentration.substance.getY(at: 0), initialSubstanceConcentration)
        XCTAssertEqual(model.concentration.primaryIon.getY(at: 0), weakModel.changeInConcentration)
        XCTAssertEqual(model.concentration.secondaryIon.getY(at: 0), weakModel.changeInConcentration)


        // All primary ion gone
        XCTAssertEqual(model.concentration.substance.getY(at: 3), 0.3)
        XCTAssertEqual(model.concentration.primaryIon.getY(at: 3), 0)
        XCTAssertEqual(model.concentration.secondaryIon.getY(at: 3), weakModel.changeInConcentration)

        // Equal concentrations
        XCTAssertEqual(model.finalConcentration.substance, 0.3)
        XCTAssertEqual(model.finalConcentration.secondaryIon, 0.3)
    }

    func testPhIncreasesWhenAcidIsAdded() {
        let weakModel = BufferWeakSubstanceComponents(substance: .weakAcids.first!, settings: .standard, cols: 10, rows: 10)
        weakModel.incrementSubstance(count: weakModel.maxSubstanceCount)

        let model = BufferSaltComponents(prev: weakModel)

        let initialPh = model.pH.getY(at: 0)
        let finalPh = model.pH.getY(at: CGFloat(model.maxSubstance))
        XCTAssertEqual(weakModel.pH.getY(at: 1), initialPh)

        XCTAssertGreaterThan(finalPh, initialPh)
    }

    func testPhDecreasesWhenBaseIsAdded() {
        let weakModel = BufferWeakSubstanceComponents(substance: .weakBases.first!, settings: .standard, cols: 10, rows: 10)
        weakModel.incrementSubstance(count: weakModel.maxSubstanceCount)

        let model = BufferSaltComponents(prev: weakModel)

        let initialPh = model.pH.getY(at: 0)
        let finalPh = model.pH.getY(at: CGFloat(model.maxSubstance))
        XCTAssertEqual(weakModel.pH.getY(at: 1), initialPh)

        XCTAssertLessThan(finalPh, initialPh)
    }
}

