//
// Reactions App
//

import XCTest
@testable import AcidsBases

class TitrantMolarityInputLimitsTests: XCTestCase {

    // The titration curve requires solving an equation with the denominator term:
    // Mt - [C], where Mt is the titrant molarity, and [C] is the concentration
    // of the the smaller primary ion at the end of the reaction. i.e., for an acid
    // titration, pH increases so [C] would be the concentration of OH
    func testTitrantMolarityInputLimits() {
        let standardSettings = TitrationSettings.standard
        let finalMinPValue = 14 - standardSettings.finalMaxPValue
        let finalMinConcentration = PrimaryIonConcentration.concentration(forP: finalMinPValue)

        let minDifference: CGFloat = 0.01

        let minInput = AcidAppSettings.minTitrantMolarity
        let maxInput = AcidAppSettings.maxTitrantMolarity
        XCTAssertGreaterThan(maxInput, minInput + minDifference)

        // Either both inputs should be above the limit, or both below
        if minInput < finalMinConcentration {
            XCTAssertLessThan(minInput + minDifference, finalMinConcentration)
            XCTAssertLessThan(maxInput + minDifference, finalMinConcentration)
        } else {
            XCTAssertGreaterThan(minInput, finalMinConcentration + minDifference)
            XCTAssertGreaterThan(maxInput, finalMinConcentration + minDifference)
        }
    }

}
