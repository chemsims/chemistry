//
// Reactions App
//

import XCTest
@testable import acids_bases

class AcidConcentrationEquationsTests: XCTestCase {

    func testChangeInConcentration() {
        let acid = AcidOrBase.strongAcid(secondaryIon: .A, color: .black, kA: 0.01)

        let zeroChangeInConcentration = AcidConcentrationEquations.changeInConcentration(
            substance: acid,
            initialSubstanceConcentration: 0
        )
        XCTAssertEqual(zeroChangeInConcentration, 0)

        let nonZeroChangeInConcentration = AcidConcentrationEquations.changeInConcentration(
            substance: acid,
            initialSubstanceConcentration: 0.5
        )

        let kA = pow(nonZeroChangeInConcentration, 2) / (0.5 - nonZeroChangeInConcentration)
        XCTAssertEqual(kA, acid.kA, accuracy: 1e-10)
    }

}
