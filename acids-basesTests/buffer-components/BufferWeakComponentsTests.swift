//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class BufferWeakComponentsTests: XCTestCase {
    
    func testBarChartData() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                changeInBarHeightAsFractionOfInitialSubstance: 0.1,
                fractionOfFinalIonMolecules: 0.1
            )
        )

        // Test before any substance has been added
        model.barChartData.forEach { bar in
            XCTAssertEqual(bar.equation.getY(at: 0), 0)
            XCTAssertEqual(bar.equation.getY(at: 1), 0)
        }

        model.incrementSubstance(count: 50)
        XCTAssertEqual(model.barChart(.substance).equation.getY(at: 0), 0.5)
        XCTAssertEqual(model.barChart(.primaryIon).equation.getY(at: 0), 0)
        XCTAssertEqual(model.barChart(.secondaryIon).equation.getY(at: 0), 0)

        XCTAssertEqual(model.barChart(.substance).equation.getY(at: 1), 0.45)
        XCTAssertEqual(model.barChart(.primaryIon).equation.getY(at: 1), 0.05)
        XCTAssertEqual(model.barChart(.secondaryIon).equation.getY(at: 1), 0.05)
    }

    func testBeakerCoords() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                changeInBarHeightAsFractionOfInitialSubstance: 0.1,
                fractionOfFinalIonMolecules: 0.1
            )
        )

        XCTAssert(model.molecules(for: .substance).coords.isEmpty)
        XCTAssert(model.molecules(for: .primaryIon).coords.isEmpty)
        XCTAssert(model.molecules(for: .secondaryIon).coords.isEmpty)

        model.incrementSubstance(count: 40)
        XCTAssertEqual(model.molecules(for: .substance).coords.count, 40)
        XCTAssertEqual(model.molecules(for: .primaryIon).coords.count, 4)
        XCTAssertEqual(model.molecules(for: .secondaryIon).coords.count, 4)

        let primaryMolecules = model.molecules(for: .primaryIon)
        let secondaryMolecules = model.molecules(for: .secondaryIon)

        let intersection = Set(primaryMolecules.coords).intersection(secondaryMolecules.coords)
        XCTAssert(intersection.isEmpty)
    }

    func testInputLimits() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                fractionOfFinalIonMolecules: 0.25,
                minimumInitialIonCount: 6,
                finalSecondaryIonCount: 4,
                minimumFinalPrimaryIonCount: 5
            )
        )

        XCTAssertEqual(model.minSubstanceCount, 24)

        // Proof of this max (see also the docs of the property):
        // Say we start with 33 HA molecules
        // At the end of phase 2, we have 33 HA and 33 A molecules
        // We must remove 29 HA molecules, to end up with 4.
        // We now have 33 + 33 + 29 = 95 molecules in the beaker.
        //
        // We then must add an extra 5 to satisfy the min final
        // primary ion count, which takes us to 99.
        //
        // If we had started with 34 HA molecules, then we would have
        // 34 + 34 + 30 + 5 = 103 molecules, which exceeds the grid size
        let expectedMax = 33
        XCTAssertEqual(model.maxSubstanceCount, expectedMax)
    }

    // Tests input limits where there the fractions produce floating points
    func testInputLimitsWithRounding() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                fractionOfFinalIonMolecules: 0.15,
                minimumInitialIonCount: 4,
                finalSecondaryIonCount: 8,
                minimumFinalPrimaryIonCount: 20
            )
        )

        XCTAssertEqual(model.minSubstanceCount, 27)

        let expectedMax = 29
        XCTAssertEqual(model.maxSubstanceCount, expectedMax)
    }

    func testInputLimitsAreEnforced() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                fractionOfFinalIonMolecules: 0.25,
                minimumInitialIonCount: 6,
                finalSecondaryIonCount: 4,
                minimumFinalPrimaryIonCount: 5
            )
        )

        // Same limits as a previous test
        let expectedMin = 24
        let expectedMax = 33

        XCTAssertFalse(model.hasAddedEnoughSubstance)
        model.incrementSubstance(count: expectedMin)
        XCTAssert(model.hasAddedEnoughSubstance)

        XCTAssert(model.canAddSubstance)
        model.incrementSubstance(count: expectedMax - expectedMin)
        XCTAssertFalse(model.canAddSubstance)

        model.incrementSubstance(count: 10)
        XCTAssertEqual(model.substanceCoords.coords.count, expectedMax)
    }

    func testInputLimitsForFinalConcentrationBelow1() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .withDefaults(
                finalSecondaryIonCount: 5,
                minimumFinalPrimaryIonCount: 5,
                maxFinalBeakerConcentration: 0.5
            )
        )

        XCTAssertEqual(model.maxSubstanceCount, 16)
    }

    func testPhDecreasesWhenAcidIsAdded() {
        let model = newModel(.weakAcids.first!, settings: .standard)
        model.incrementSubstance(count: 10)

        let initial = model.pH.getY(at: 0)
        let final = model.pH.getY(at: 1)
        XCTAssertLessThan(final, initial)
    }

    func testPhIncreasesWhenBaseIsAdded() {
        let model = newModel(.weakBases.first!, settings: .standard)
        model.incrementSubstance(count: 10)

        let initial = model.pH.getY(at: 0)
        let final = model.pH.getY(at: 1)
        XCTAssertGreaterThan(final, initial)
    }

    func testConcentration() {
        let acid = AcidOrBase.weakAcids.first!
        let model = newModel(acid, settings: .standard)

        model.incrementSubstance(count: 20)

        let substance = model.concentration.substance
        let primary = model.concentration.primaryIon
        let secondary = model.concentration.secondaryIon

        let changeInConcentration = primary.getY(at: 1)

        let kA = pow(changeInConcentration, 2) / (0.2 - changeInConcentration)
        XCTAssertEqual(kA, acid.kA, accuracy: 1e-10)

        XCTAssertEqual(substance.getY(at: 0), 0.2)
        XCTAssertEqual(substance.getY(at: 1), 0.2 - changeInConcentration)

        XCTAssertEqual(primary.getY(at: 0), 0)
        XCTAssertEqual(primary.getY(at: 1), changeInConcentration)

        XCTAssertEqual(secondary.getY(at: 0), 0)
        XCTAssertEqual(secondary.getY(at: 1), changeInConcentration)
    }

    private func newModel(
        _ substance: AcidOrBase,
        settings: BufferComponentSettings
    ) -> BufferWeakSubstanceComponents {
        BufferWeakSubstanceComponents(
            substance: substance,
            settings: settings,
            cols: 10,
            rows: 10
        )
    }
}

private extension BufferWeakSubstanceComponents {
    func barChart(_ substance: SubstancePart) -> BarChartData {
        barChartMap.value(for: substance)
    }
}
