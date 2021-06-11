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
            settings: .init(
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
}

private extension BufferStrongSubstanceComponents {
    func barChart(_ part: SubstancePart) -> BarChartData {
        barChartMap.value(for: part)
    }
}
