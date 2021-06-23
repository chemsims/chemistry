//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationStrongSubstancePreparationModelTests: XCTestCase {

    func testConcentration() {
        let model = TitrationStrongSubstancePreparationModel()

        XCTAssertEqual(model.concentration.value(for: .hydrogen), 1e-7)
        XCTAssertEqual(model.concentration.value(for: .substance), 0)

        model.incrementSubstance(count: 20)
        XCTAssertEqual(
            model.concentration.value(for: .hydrogen),
            expectedConcentration(afterIncrementing: 20),
            accuracy: 0.001
        )
        XCTAssertEqual(model.concentration.value(for: .substance), 0)
    }

    func testMolarity() {
        let model = TitrationStrongSubstancePreparationModel()

        XCTAssertEqual(model.molarity.value(for: .substance), 1e-7)
        XCTAssertEqual(model.molarity.value(for: .titrant), 0)

        model.incrementSubstance(count: 20)

        XCTAssertEqual(
            model.molarity.value(for: .substance),
            expectedConcentration(afterIncrementing: 20),
            accuracy: 0.001
        )
        XCTAssertEqual(model.molarity.value(for: .titrant), 0)
    }

    func testMoles() {
        let model = TitrationStrongSubstancePreparationModel()

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
        let model = TitrationStrongSubstancePreparationModel()
        XCTAssertEqual(model.pValues.value(for: .hydrogen), 7)
        XCTAssertEqual(model.pValues.value(for: .hydroxide), 7)
        XCTAssertEqual(model.pValues.value(for: .kA), model.substance.pKA)
        XCTAssertEqual(model.pValues.value(for: .kB), model.substance.pKB)

        model.incrementSubstance(count: 20)
        let expectedHydrogenConcentration = expectedConcentration(afterIncrementing: 20)
        let expectedPH = -log10(expectedHydrogenConcentration)
        let expectedPOH = 14 - expectedPH

        XCTAssertEqual(model.pValues.value(for: .hydrogen), expectedPH, accuracy: 0.001)
        XCTAssertEqual(model.pValues.value(for: .hydroxide), expectedPOH, accuracy: 0.001)
    }

    func testKValues() {
        let model = TitrationStrongSubstancePreparationModel()
        XCTAssertEqual(model.kValues.value(for: .kA), model.substance.kA)
        XCTAssertEqual(model.kValues.value(for: .kB), model.substance.kB)
    }

    func testVolume() {
        let model = TitrationStrongSubstancePreparationModel(
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
            settings: .withDefaults(neutralSubstanceBarChartHeight: 0.3)
        )

        var hydrogenBar: BarChartData {
            model.barChartData[1]
        }
        var hydroxideBar: BarChartData {
            model.barChartData[0]
        }

        XCTAssertEqual(hydrogenBar.equation.getY(at: 0), 0.3)
        XCTAssertEqual(hydroxideBar.equation.getY(at: 0), 0.3)

        model.incrementSubstance(count: 20)
        let expectedHydrogenConcentration = expectedConcentration(afterIncrementing: 20)
        let expectedPH = -log10(expectedHydrogenConcentration)
        let expectedPOH = 14 - expectedPH
        let expectedHydroxideConcentration = PrimaryIonConcentration.concentration(forP: expectedPOH)


        let expectedFinalHHeight = LinearEquation(
            x1: 1e-7,
            y1: 0.3,
            x2: 1,
            y2: 1
        ).getY(at: expectedHydrogenConcentration)
        XCTAssertEqual(
            hydrogenBar.equation.getY(at: 20),
            expectedFinalHHeight,
            accuracy: 0.01
        )

        let expectedMidHHeight = (0.3 + expectedFinalHHeight) / 2
        XCTAssertEqual(
            hydrogenBar.equation.getY(at: 10),
            expectedMidHHeight,
            accuracy: 0.01
        )

        let expectedFinalOHHeight = LinearEquation(
            x1: 0,
            y1: 0,
            x2: 1e-7,
            y2: 0.3
        ).getY(at: expectedHydroxideConcentration)
        XCTAssertEqual(
            hydroxideBar.equation.getY(at: 20),
            expectedFinalOHHeight,
            accuracy: 0.01
        )

        let expectedMidOHHeight = (0.3 + expectedFinalOHHeight) / 2
        XCTAssertEqual(
            hydroxideBar.equation.getY(at: 10),
            expectedMidOHHeight,
            accuracy: 0.01
        )
    }

    private func expectedConcentration(afterIncrementing count: Int) -> CGFloat {
        LinearEquation(x1: 0, y1: 1e-7, x2: 100, y2: 1).getY(at: CGFloat(count))
    }
}

private extension TitrationStrongSubstancePreparationModel {

    // Returns an instance using default arguments, and a 10x10 grid
    convenience init(
        substance: AcidOrBase = .strongAcids.first!,
        settings: TitrationSettings = .standard
    ) {
        self.init(
            substance: substance,
            titrant: "KOH",
            cols: 10,
            rows: 10,
            settings: settings
        )
    }
}
