//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationWeakSubstancePreparationModelTests: XCTestCase {

    func testConcentration() {
        let model = TitrationWeakSubstancePreparationModel()
        
        var initialConcentrations: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
            model.concentration.map { $0.getY(at: 0) }
        }

        XCTAssertEqual(initialConcentrations.value(for: .hydrogen), 0)
        XCTAssertEqual(initialConcentrations.value(for: .secondary), 0)
        XCTAssertEqual(initialConcentrations.value(for: .substance), 0)

        model.incrementSubstance(count: 20)
        XCTAssertEqual(initialConcentrations.value(for: .substance), 0.2)

        let finalConcentration = model.concentration.map { $0.getY(at: 1) }

        let finalHydrogen = finalConcentration.value(for: .hydrogen)
        let finalSecondary = finalConcentration.value(for: .secondary)
        let finalSubstance = finalConcentration.value(for: .substance)

        // The changes in concentration should be equal
        XCTAssertEqual(finalHydrogen, finalSecondary)
        XCTAssertEqualWithTolerance(0.2 - finalSubstance, finalHydrogen)

        // This equation should be satisfied: Ka = ([H][A]/[HA]):
        let resultingKa = (finalHydrogen * finalSecondary) / finalSubstance
        XCTAssertEqualWithTolerance(resultingKa, model.substance.kA)

        XCTAssertEqual(
            initialConcentrations.value(for: .initialSubstance),
            initialConcentrations.value(for: .substance)
        )
        XCTAssertEqual(
            finalConcentration.value(for: .initialSubstance),
            finalConcentration.value(for: .substance)
        )

        // Check hydroxide
        let expectedHydroxide = PrimaryIonConcentration.complementConcentration(
            primaryConcentration: finalHydrogen
        )
        XCTAssertEqualWithTolerance(finalConcentration.value(for: .hydroxide), expectedHydroxide)
    }

    func testVolume() {
        let model = TitrationWeakSubstancePreparationModel(
            settings: .withDefaults(
                beakerVolumeFromRows: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 1)
            )
        )

        XCTAssertEqual(model.volume.value(for: .substance), 1)
        model.rows = 5
        XCTAssertEqual(model.volume.value(for: .substance), 0.5)

        XCTAssertEqual(model.volume.value(for: .titrant), 0)
    }

    func testMoles() {
        let model = TitrationWeakSubstancePreparationModel()

        model.moles.all.forEach { mole in
            XCTAssertEqual(mole.getY(at: 0), 0)
            XCTAssertEqual(mole.getY(at: 1), 0)
        }

        model.incrementSubstance(count: 20)
        let substanceMoles = model.moles.value(for: .substance)
        let substanceVolume = model.volume.value(for: .substance)
        let initialSubstanceMoles = model.moles.value(for: .initialSubstance)
        XCTAssertEqual(substanceMoles.getY(at: 0), 0.2 * substanceVolume)
        XCTAssertEqual(
            substanceMoles.getY(at: 1),
            model.concentration.value(for: .substance).getY(at: 1) * substanceVolume
        )
        XCTAssertEqual(substanceMoles.getY(at: 0), initialSubstanceMoles.getY(at: 0))
        XCTAssertEqual(substanceMoles.getY(at: 1), initialSubstanceMoles.getY(at: 1))

        XCTAssertEqual(model.moles.value(for: .secondary).getY(at: 0), 0)

        let finalSecondaryConcentration = model.concentration.value(for: .secondary).getY(at: 1)
        let finalSecondaryMoles = model.moles.value(for: .secondary).getY(at: 1)
        let expectedFinalSecondaryMoles = substanceVolume * finalSecondaryConcentration
        XCTAssertEqual(finalSecondaryMoles, expectedFinalSecondaryMoles)
    }

    func testPValues() {
        let model = TitrationWeakSubstancePreparationModel()

        model.incrementSubstance(count: 20)

        let pKa = model.substance.pKA
        let finalSecondary = model.concentration.value(for: .secondary).getY(at: 1)
        let finalSubstance = model.concentration.value(for: .substance).getY(at: 1)

        let expectedPH = pKa + log10(finalSecondary / finalSubstance)

        XCTAssertEqual(model.pValues.value(for: .hydrogen), expectedPH)
        XCTAssertEqual(model.pValues.value(for: .hydroxide), 14 - expectedPH)
        XCTAssertEqual(model.pValues.value(for: .kA), model.substance.pKA)
        XCTAssertEqual(model.pValues.value(for: .kB), model.substance.pKB)
    }

    func testBarChart() {
        let model = TitrationWeakSubstancePreparationModel(
            settings: .withDefaults(
                weakIonChangeInBarHeightFraction: 0.25
            )
        )

        model.barChartDataMap.all.forEach { barChart in
            XCTAssertEqual(barChart.equation.getY(at: 0), 0)
            XCTAssertEqual(barChart.equation.getY(at: 1), 0)
        }

        model.incrementSubstance(count: 20)

        let substance = model.barChartDataMap.value(for: .substance).equation
        XCTAssertEqual(substance.getY(at: 0), 0.2)

        let changeInHeight: CGFloat = 0.05
        XCTAssertEqual(substance.getY(at: 1), 0.2 - changeInHeight)

        let hydrogen = model.barChartDataMap.value(for: .hydrogen).equation
        XCTAssertEqual(hydrogen.getY(at: 0), 0)
        XCTAssertEqual(hydrogen.getY(at: 1), changeInHeight)

        let secondary = model.barChartDataMap.value(for: .secondaryIon).equation
        XCTAssertEqual(secondary.getY(at: 0), 0)
        XCTAssertEqual(secondary.getY(at: 1), changeInHeight)
    }
}

