//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

// TODO add tests that final concentration is correct
class BufferStrongComponentsTests: XCTestCase {

    func testBarChartData() {
        let weakModel = BufferWeakSubstanceComponents(
            substance: .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                changeInBarHeightAsFractionOfInitialSubstance: 0.1,
                fractionOfFinalIonMolecules: 0.1
            ),
            cols: 10,
            rows: 10
        )
        weakModel.incrementSubstance(count: 30)

        let saltModel = BufferSaltComponents(prev: weakModel)
        let strongModel = BufferStrongSubstanceComponents(prev: saltModel)

        func finalBarChartValue(_ part: SubstancePart) -> CGFloat {
            strongModel.barChart(part).equation.getY(at: CGFloat(strongModel.maxSubstance))
        }
        func finalConcentration(_ part: SubstancePart) -> CGFloat {
            strongModel.concentration.value(for: part).getY(at: CGFloat(strongModel.maxSubstance))
        }

        XCTAssertEqual(strongModel.barChart(.substance).equation.getY(at: 0), 0.3)
        XCTAssertEqual(strongModel.barChart(.primaryIon).equation.getY(at: 0), 0)
        XCTAssertEqual(strongModel.barChart(.secondaryIon).equation.getY(at: 0), 0.3, accuracy: 0.00001)

        XCTAssertEqual(finalBarChartValue(.substance), finalConcentration(.substance))
        XCTAssertEqual(finalBarChartValue(.primaryIon), 0)
        XCTAssertEqual(finalBarChartValue(.secondaryIon), finalConcentration(.secondaryIon))
    }

    func testCoords() {
        let weakModel = BufferWeakSubstanceComponents(
            substance: .weakBase(substanceAddedPerIon: 1),
            settings: .withDefaults(
                finalSecondaryIonCount: 5,
                minimumFinalPrimaryIonCount: 6
            ),
            cols: 10,
            rows: 10
        )

        // See parameter docs or weak model tests for explanation
        // of this number
        let expectedMaxSubstance = 33
        XCTAssertEqual(weakModel.maxSubstanceCount, expectedMaxSubstance)
        weakModel.incrementSubstance(count: weakModel.maxSubstanceCount)

        let saltModel = BufferSaltComponents(prev: weakModel)
        saltModel.incrementSalt(count: saltModel.maxSubstance)
        let model = BufferStrongSubstanceComponents(prev: saltModel)

        func molecules(_ part: SubstancePart) -> BeakerMolecules {
            model.reactingModel.consolidated.value(for: part)
        }

        XCTAssertEqual(molecules(.substance).coords.count, 33)
        XCTAssertEqual(molecules(.primaryIon).coords.count, 0)
        XCTAssertEqual(molecules(.secondaryIon).coords.count, 33)

        model.incrementStrongSubstance(count: 28) // 33 - 5
        XCTAssertEqual(molecules(.substance).coords.count, 89) // 33 + (2 * 28)
        XCTAssertEqual(molecules(.primaryIon).coords.count, 0)
        XCTAssertEqual(molecules(.secondaryIon).coords.count, 5)

        model.incrementStrongSubstance(count: 6)
        XCTAssertEqual(molecules(.substance).coords.count, 89)
        XCTAssertEqual(molecules(.primaryIon).coords.count, 6)
        XCTAssertEqual(molecules(.secondaryIon).coords.count, 5)
    }

    func testInputLimits() {
        let weakModel = BufferWeakSubstanceComponents(
            substance: .weakBase(substanceAddedPerIon: 1),
            settings: .withDefaults(
                finalSecondaryIonCount: 5,
                minimumFinalPrimaryIonCount: 10
            ),
            cols: 10,
            rows: 10
        )

        // See parameter docs or weak model tests for explanation
        // of the max substance count
        XCTAssertEqual(weakModel.maxSubstanceCount, 31)
        weakModel.incrementSubstance(count: weakModel.maxSubstanceCount)

        let saltModel = BufferSaltComponents(prev: weakModel)
        saltModel.incrementSalt(count: saltModel.maxSubstance)
        let model = BufferStrongSubstanceComponents(prev: saltModel)

        // at end of phase 3 we have 31 substance and 31 secondary ion molecules
        // we must add 26 molecules to leave 5 secondary ion molecules, and
        // then a further 10. So we should add 36 molecules
        let expectedMax = 36
        XCTAssertEqual(model.maxSubstance, expectedMax)

        XCTAssert(model.canAddSubstance)
        XCTAssertFalse(model.hasAddedEnoughSubstance)

        model.incrementStrongSubstance(count: 100)

        XCTAssertFalse(model.canAddSubstance)
        XCTAssert(model.hasAddedEnoughSubstance)
        XCTAssertEqual(model.substanceAdded, 36)
    }
}

private extension BufferStrongSubstanceComponents {
    func barChart(_ part: SubstancePart) -> BarChartData {
        barChartMap.value(for: part)
    }
}
