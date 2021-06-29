//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationStrongAcidPreparationModelTests: XCTestCase {

    var substance = AcidOrBase.strongAcids.first!

    /// The primary ion of the substance
    private var primaryIon: PrimaryIon {
        substance.primary
    }

    /// The complement to the primary ion
    private var complementIon: PrimaryIon {
        primaryIon.complement
    }

    func testConcentration() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)

        XCTAssertEqual(model.currentConcentration.value(for: .substance), 0)
        XCTAssertEqual(model.currentConcentration.value(for: .hydrogen), 1e-7)
        XCTAssertEqual(model.currentConcentration.value(for: .hydroxide), 1e-7)

        model.incrementSubstance(count: 20)

        let expectedPrimary = expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20)
        let expectedComplement = PrimaryIonConcentration.complementConcentration(
            primaryConcentration: expectedPrimary
        )

        XCTAssertEqualWithTolerance(
            model.currentConcentration.value(for: primaryIon.concentration),
            expectedPrimary
        )
        XCTAssertEqualWithTolerance(
            model.currentConcentration.value(for: complementIon.concentration),
            expectedComplement
        )
        XCTAssertEqual(model.currentConcentration.value(for: .substance), 0)
    }

    func testMolarity() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)

        XCTAssertEqual(model.currentMolarity.value(for: .substance), 1e-7)

        model.incrementSubstance(count: 20)

        XCTAssertEqual(
            model.currentMolarity.value(for: .substance),
            expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20),
            accuracy: 0.001
        )
    }

    func testMoles() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)

        XCTAssertEqual(model.currentMoles.value(for: .substance), 1e-7 * model.currentVolume)
        XCTAssertEqual(model.currentMoles.value(for: .titrant), 0)

        model.incrementSubstance(count: 20)

        XCTAssertEqual(
            model.currentMoles.value(for: .substance),
            model.currentVolumes.value(for: .substance) * model.currentMolarity.value(for: .substance)
        )
        XCTAssertEqual(model.currentMoles.value(for: .titrant), 0)
    }


    func testPValues() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)
        XCTAssertEqual(model.currentPValues.value(for: .hydrogen), 7)
        XCTAssertEqual(model.currentPValues.value(for: .hydroxide), 7)
        XCTAssertEqual(model.currentPValues.value(for: .kA), model.substance.pKA)
        XCTAssertEqual(model.currentPValues.value(for: .kB), model.substance.pKB)

        model.incrementSubstance(count: 20)
        let expectedPrimaryIonConcentration = expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20)
        let expectedPPrimaryIon = -log10(expectedPrimaryIonConcentration)
        let expectedPComplementIon = 14 - expectedPPrimaryIon

        XCTAssertEqualWithTolerance(
            model.currentPValues.value(for: primaryIon.pValue),
            expectedPPrimaryIon
        )
        XCTAssertEqualWithTolerance(
            model.currentPValues.value(for: complementIon.pValue),
            expectedPComplementIon
        )
    }

    func testKValues() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)
        XCTAssertEqual(model.equationData.kValues.value(for: .kA), model.substance.kA)
        XCTAssertEqual(model.equationData.kValues.value(for: .kB), model.substance.kB)
    }

    func testVolume() {
        let model = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                beakerVolumeFromRows: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 1)
            )
        )

        XCTAssertEqual(model.currentVolume, 1)
        XCTAssertEqual(model.currentVolumes.value(for: .substance), 1)

        model.exactRows = 5

        XCTAssertEqual(model.currentVolume, 0.5)
        XCTAssertEqual(model.currentVolumes.value(for: .substance), 0.5)
    }

    func testBarChartData() {
        let model = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(neutralSubstanceBarChartHeight: 0.3)
        )

        var primaryIonBar: BarChartData {
            model.barChartDataMap.value(for: primaryIon)
        }
        var complementIonBar: BarChartData {
            model.barChartDataMap.value(for: complementIon)
        }

        XCTAssertEqual(primaryIonBar.equation.getY(at: 0), 0.3)
        XCTAssertEqual(complementIonBar.equation.getY(at: 0), 0.3)

        model.incrementSubstance(count: 20)
        let expectedPrimaryIonConcentration = expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20)

        let expectedFinalPrimaryIonHeight = LinearEquation(
            x1: 1e-7,
            y1: 0.3,
            x2: 1,
            y2: 1
        ).getY(at: expectedPrimaryIonConcentration)
        XCTAssertEqualWithTolerance(
            primaryIonBar.equation.getY(at: 20),
            expectedFinalPrimaryIonHeight
        )

        let expectedMidPrimaryIonHeight = (0.3 + expectedFinalPrimaryIonHeight) / 2
        XCTAssertEqualWithTolerance(
            primaryIonBar.equation.getY(at: 10),
            expectedMidPrimaryIonHeight
        )

        let expectedFinalComplementIonHeight = LinearEquation(
            x1: 0,
            y1: 0.3,
            x2: CGFloat(model.maxSubstance),
            y2: 0
        ).getY(at: 20)
        XCTAssertEqualWithTolerance(
            complementIonBar.equation.getY(at: 20),
            expectedFinalComplementIonHeight
        )

        let expectedMidComplementIonHeight = (0.3 + expectedFinalComplementIonHeight) / 2
        XCTAssertEqual(
            complementIonBar.equation.getY(at: 10),
            expectedMidComplementIonHeight
        )
    }

    func testInputLimits() {
        let model = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(
                maxInitialStrongConcentration: 0.3,
                minInitialStrongConcentration: 0.2
            )
        )

        XCTAssert(model.canAddSubstance)
        XCTAssertFalse(model.hasAddedEnoughSubstance)

        model.incrementSubstance(count: 20)
        XCTAssert(model.canAddSubstance)
        XCTAssert(model.hasAddedEnoughSubstance)

        model.incrementSubstance(count: 20)

        // We should not exceed the max substance could when incrementing by a larger amount
        XCTAssertEqual(model.substanceAdded, 30)
    }

    private func expectedConcentrationOfIncreasingMolecule(
        afterIncrementing count: Int
    ) -> CGFloat {
        TitrationStrongSubstancePreparationModel.concentrationOfIncreasingMolecule(
            afterIncrementing: count,
            gridSize: 100
        )
    }
}

extension PrimaryIon {
    var concentration: TitrationEquationTerm.Concentration {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }

    var pValue: TitrationEquationTerm.PValue {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }
}
