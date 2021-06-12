//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class BufferSaltComponentsTests: XCTestCase {

    func testBarChartData() {
        let acid = AcidOrBase.weakAcid(substanceAddedPerIon: 1)
        let weakModelSettings = BufferWeakSubstanceComponents.Settings.withDefaults(
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

        // All of primary molecules gone
        XCTAssertEqual(saltModel.barChartEquations.substance.getY(at: 3), 0.3)
        XCTAssertEqual(saltModel.barChartEquations.primaryIon.getY(at: 3), 0)
        XCTAssertEqual(saltModel.barChartEquations.secondaryIon.getY(at: 3), 0.03)

        // End of adding substance
        XCTAssertEqual(saltModel.barChartEquations.substance.getY(at: CGFloat(saltModel.maxSubstance)), 0.3)
        XCTAssertEqual(saltModel.barChartEquations.primaryIon.getY(at: CGFloat(saltModel.maxSubstance)), 0)
        XCTAssertEqual(saltModel.barChartEquations.secondaryIon.getY(at: CGFloat(saltModel.maxSubstance)), 0.3)
    }
}

