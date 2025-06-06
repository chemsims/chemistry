//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class TitrationWeakAcidPreparationModelTests: XCTestCase {

    var substance = AcidOrBase.weakAcids.first!

    /// The ion which increases as substance is added to a solution
    private var increasingIon: PrimaryIon {
        substance.primary
    }

    /// The ion which decreases as substance is added to a solution
    private var decreasingIon: PrimaryIon {
        increasingIon.complement
    }

    func testConcentration() {
        let model = TitrationWeakSubstancePreparationModel(
            substance: substance
        )
        
        var initialConcentrations: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
            model.concentration.map { $0.getValue(at: 0) }
        }

        XCTAssertEqual(initialConcentrations.value(for: increasingIon.concentration), 0)
        XCTAssertEqual(initialConcentrations.value(for: .secondary), 0)
        XCTAssertEqual(initialConcentrations.value(for: .substance), 0)

        model.incrementSubstance(count: 20)
        XCTAssertEqual(initialConcentrations.value(for: .substance), 0.2)

        let finalConcentration = model.concentration.map { $0.getValue(at: 1) }

        let finalIncreasingIon = finalConcentration.value(for: increasingIon.concentration)
        let finalSecondary = finalConcentration.value(for: .secondary)
        let finalSubstance = finalConcentration.value(for: .substance)

        // The changes in concentration should be equal
        XCTAssertEqual(finalIncreasingIon, finalSecondary)
        XCTAssertEqualWithTolerance(0.2 - finalSubstance, finalIncreasingIon)

        // This equation should be satisfied: (for acids) Ka = ([H][A]/[HA])
        let resultingK = (finalIncreasingIon * finalSecondary) / finalSubstance
        let expectedK = substance.type.isAcid ? substance.kA : substance.kB
        XCTAssertEqualWithTolerance(resultingK, expectedK)

        // Check initial substance
        XCTAssertEqual(
            initialConcentrations.value(for: .initialSubstance),
            initialConcentrations.value(for: .substance)
        )
        XCTAssertEqualWithTolerance(
            finalConcentration.value(for: .initialSubstance),
            initialConcentrations.value(for: .substance)
        )
        XCTAssertEqualWithTolerance(
            initialConcentrations.value(for: .initialSubstance),
            finalConcentration.value(for: .initialSubstance)
        )

        // Check decreasing ion
        let expectedDecreasingIon = PrimaryIonConcentration.complementConcentration(
            primaryConcentration: finalIncreasingIon
        )
        XCTAssertEqualWithTolerance(
            finalConcentration.value(for: decreasingIon.concentration),
            expectedDecreasingIon
        )
    }

    func testVolume() {
        let model = TitrationWeakSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                beakerVolumeFromRows: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 1)
            )
        )

        XCTAssertEqual(model.volume.value(for: .substance), 1)
        model.exactRows = 5
        XCTAssertEqual(model.volume.value(for: .substance), 0.5)

        XCTAssertEqual(model.volume.value(for: .titrant), 0)
    }

    func testMoles() {
        let model = TitrationWeakSubstancePreparationModel(substance: substance)

        model.moles.all.forEach { mole in
            XCTAssertEqual(mole.getValue(at: 0), 0)
            XCTAssertEqual(mole.getValue(at: 1), 0)
        }

        model.incrementSubstance(count: 20)
        let substanceMoles = model.moles.value(for: .substance)
        let substanceVolume = model.volume.value(for: .substance)
        let initialSubstanceMoles = model.moles.value(for: .initialSubstance)
        XCTAssertEqual(substanceMoles.getValue(at: 0), 0.2 * substanceVolume)
        XCTAssertEqual(
            substanceMoles.getValue(at: 1),
            model.concentration.value(for: .substance).getValue(at: 1) * substanceVolume
        )
        XCTAssertEqual(
            initialSubstanceMoles.getValue(at: 0),
            model.concentration.value(for: .initialSubstance).getValue(at:0) * substanceVolume
        )
        XCTAssertEqual(initialSubstanceMoles.getValue(at: 0), initialSubstanceMoles.getValue(at: 1))

        XCTAssertEqual(model.moles.value(for: .secondary).getValue(at: 0), 0)

        let finalSecondaryConcentration = model.concentration.value(for: .secondary).getValue(at: 1)
        let finalSecondaryMoles = model.moles.value(for: .secondary).getValue(at: 1)
        let expectedFinalSecondaryMoles = substanceVolume * finalSecondaryConcentration
        XCTAssertEqual(finalSecondaryMoles, expectedFinalSecondaryMoles)
    }

    func testPValues() {
        let model = TitrationWeakSubstancePreparationModel(substance: substance)

        model.incrementSubstance(count: 20)

        let finalSecondary = model.concentration.value(for: .secondary).getValue(at: 1)
        let finalSubstance = model.concentration.value(for: .substance).getValue(at: 1)

        // Check we satisfy the equation pH = pKa + log(secondary / substance)
        // For bases, this is pOH = pKb + log(secondary / substance)
        let pK = substance.type.isAcid ? substance.pKA : substance.pKB
        let expectedPIncreasingIon = pK + log10(finalSecondary / finalSubstance)

        model.reactionProgress = 1

        XCTAssertEqualWithTolerance(
            model.currentPValues.value(for: increasingIon.pValue), expectedPIncreasingIon
        )
        XCTAssertEqualWithTolerance(
            model.currentPValues.value(for: decreasingIon.pValue), 14 - expectedPIncreasingIon
        )
        XCTAssertEqual(model.currentPValues.value(for: .kA), model.substance.pKA)
        XCTAssertEqual(model.currentPValues.value(for: .kB), model.substance.pKB)
    }

    func testBarChart() {
        let model = TitrationWeakSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                weakIonChangeInBarHeightFraction: 0.25
            )
        )

        model.barChartDataMap.all.forEach { barChart in
            XCTAssertEqual(barChart.equation.getValue(at: 0), 0)
            XCTAssertEqual(barChart.equation.getValue(at: 1), 0)
        }

        model.incrementSubstance(count: 20)

        let substance = model.barChartDataMap.value(for: .substance).equation
        XCTAssertEqual(substance.getValue(at: 0), 0.2)

        let changeInHeight: CGFloat = 0.05
        XCTAssertEqual(substance.getValue(at: 1), 0.2 - changeInHeight)

        let increasingIonBar = model.barChartDataMap.value(
            for: increasingIon.extendedSubstancePart
        ).equation
        XCTAssertEqual(increasingIonBar.getValue(at: 0), 0)
        XCTAssertEqual(increasingIonBar.getValue(at: 1), changeInHeight)

        let secondary = model.barChartDataMap.value(for: .secondaryIon).equation
        XCTAssertEqual(secondary.getValue(at: 0), 0)
        XCTAssertEqual(secondary.getValue(at: 1), changeInHeight)
    }

    func testInputLimits() {
        let model = TitrationWeakSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                minInitialWeakConcentration: 0.111
            )
        )

        XCTAssert(model.canAddSubstance)
        XCTAssertFalse(model.hasAddedEnoughSubstance)

        // Concentration must be at least 0.111, so expect 12 min molecules
        XCTAssertEqual(model.minSubstance, 12)

        // We end up with 4 times the original substance molecules,
        // so must not add more than 25
        XCTAssertEqual(model.maxSubstance, 25)

        model.incrementSubstance(count: 20)
        XCTAssert(model.canAddSubstance)
        XCTAssert(model.hasAddedEnoughSubstance)

        model.incrementSubstance(count: 50)
        XCTAssertFalse(model.canAddSubstance)
        XCTAssert(model.hasAddedEnoughSubstance)

        XCTAssertEqual(model.substanceAdded, 25)
    }
}


