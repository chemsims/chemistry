//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class MoleculeScalesGeometryTests: XCTestCase {

    func testRightHandMaxAngle() {
        let result = MoleculeScalesGeometry.maxRotationForRightHand(rotationY: 20, singleArmWidth: 40)
        XCTAssertEqual(result.degrees, 30, accuracy: 0.00001)
    }

    func testLeftHandMaxAngle() {
        let result = MoleculeScalesGeometry.maxRotationForLeftHand(maxHeight: 15, singleArmWidth: 10, basketHeight: 10)
        XCTAssertEqual(result.degrees, 30, accuracy: 0.00001)
    }
}
