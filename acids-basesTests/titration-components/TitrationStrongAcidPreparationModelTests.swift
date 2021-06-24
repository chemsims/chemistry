//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationStrongAcidPreparationModelTests: XCTestCase {

    var increasingIon = PrimaryIon.hydrogen
    var substance = AcidOrBase.strongAcids.first!

    private var decreasingIon: PrimaryIon {
        increasingIon.complement
    }

    func testConcentration() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)

        XCTAssertEqual(model.concentration.value(for: .substance), 0)
        XCTAssertEqual(model.concentration.value(for: .hydrogen), 1e-7)
        XCTAssertEqual(model.concentration.value(for: .hydroxide), 1e-7)

        model.incrementSubstance(count: 20)

        let expectedIncreasing = expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20)
        let expectedDecreasing = PrimaryIonConcentration.complementConcentration(
            primaryConcentration: expectedIncreasing
        )

        XCTAssertEqualWithTolerance(
            model.concentration.value(for: increasingIon.concentration),
            expectedIncreasing
        )
        XCTAssertEqualWithTolerance(
            model.concentration.value(for: decreasingIon.concentration),
            expectedDecreasing
        )
        XCTAssertEqual(model.concentration.value(for: .substance), 0)
    }

    func testMolarity() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)

        XCTAssertEqual(model.molarity.value(for: .substance), 1e-7)
        XCTAssertEqual(model.molarity.value(for: .titrant), 0)

        model.incrementSubstance(count: 20)

        XCTAssertEqual(
            model.molarity.value(for: .substance),
            expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20),
            accuracy: 0.001
        )
        XCTAssertEqual(model.molarity.value(for: .titrant), 0)
    }

    func testMoles() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)

        XCTAssertEqual(model.moles.value(for: .substance), 1e-7 * model.currentVolume)
        XCTAssertEqual(model.moles.value(for: .titrant), 0)

        model.incrementSubstance(count: 20)

        XCTAssertEqual(
            model.moles.value(for: .substance),
            model.volume.value(for: .substance) * model.molarity.value(for: .substance)
        )
        XCTAssertEqual(model.moles.value(for: .titrant), 0)
    }


    func testPValues() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)
        XCTAssertEqual(model.pValues.value(for: .hydrogen), 7)
        XCTAssertEqual(model.pValues.value(for: .hydroxide), 7)
        XCTAssertEqual(model.pValues.value(for: .kA), model.substance.pKA)
        XCTAssertEqual(model.pValues.value(for: .kB), model.substance.pKB)

        model.incrementSubstance(count: 20)
        let expectedIncreasingConcentration = expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20)
        let expectedPIncreasingIon = -log10(expectedIncreasingConcentration)
        let expectedPDecreasingIon = 14 - expectedPIncreasingIon

        XCTAssertEqualWithTolerance(
            model.pValues.value(for: increasingIon.pValue),
            expectedPIncreasingIon
        )
        XCTAssertEqualWithTolerance(
            model.pValues.value(for: decreasingIon.pValue),
            expectedPDecreasingIon
        )
    }

    func testKValues() {
        let model = TitrationStrongSubstancePreparationModel(substance: substance)
        XCTAssertEqual(model.kValues.value(for: .kA), model.substance.kA)
        XCTAssertEqual(model.kValues.value(for: .kB), model.substance.kB)
    }

    func testVolume() {
        let model = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                beakerVolumeFromRows: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 1)
            )
        )

        XCTAssertEqual(model.currentVolume, 1)
        XCTAssertEqual(model.volume.value(for: .substance), 1)

        model.exactRows = 5

        XCTAssertEqual(model.currentVolume, 0.5)
        XCTAssertEqual(model.volume.value(for: .substance), 0.5)
    }

    func testBarChartData() {
        let model = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(neutralSubstanceBarChartHeight: 0.3)
        )

        var increasingBar: BarChartData {
            model.barChartDataMap.value(for: increasingIon)
        }
        var decreasingBar: BarChartData {
            model.barChartDataMap.value(for: decreasingIon)
        }

        XCTAssertEqual(increasingBar.equation.getY(at: 0), 0.3)
        XCTAssertEqual(decreasingBar.equation.getY(at: 0), 0.3)

        model.incrementSubstance(count: 20)
        let expectedIncreasingConcentration = expectedConcentrationOfIncreasingMolecule(afterIncrementing: 20)

        let expectedFinalIncreasingHeight = LinearEquation(
            x1: 1e-7,
            y1: 0.3,
            x2: 1,
            y2: 1
        ).getY(at: expectedIncreasingConcentration)
        XCTAssertEqualWithTolerance(
            increasingBar.equation.getY(at: 20),
            expectedFinalIncreasingHeight
        )

        let expectedMidIncreasingHeight = (0.3 + expectedFinalIncreasingHeight) / 2
        XCTAssertEqualWithTolerance(
            increasingBar.equation.getY(at: 10),
            expectedMidIncreasingHeight
        )

        let expectedFinalDecreasingHeight = LinearEquation(
            x1: 0,
            y1: 0.3,
            x2: CGFloat(model.maxSubstance),
            y2: 0
        ).getY(at: 20)
        XCTAssertEqualWithTolerance(
            decreasingBar.equation.getY(at: 20),
            expectedFinalDecreasingHeight
        )

        let expectedMidDecreasingHeight = (0.3 + expectedFinalDecreasingHeight) / 2
        XCTAssertEqual(
            decreasingBar.equation.getY(at: 10),
            expectedMidDecreasingHeight
        )
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
