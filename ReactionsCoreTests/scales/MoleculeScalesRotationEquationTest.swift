//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class MoleculeScalesRotationEquationTest: XCTestCase {

    func testRotationForEqualBasketWeights() {
        let rotation = MoleculeScales.rotationEquation(
            leftMolecules: .single(concentration: .init(fraction: LinearEquation(m: 1, x1: 0, y1: 0))),
            rightMolecules: .single(concentration: .init(fraction: LinearEquation(m: 1, x1: 0, y1: 0)))
        )
        XCTAssertEqual(rotation.getY(at: 0), 0)
        XCTAssertEqual(rotation.getY(at: 1), 0)
    }

    func testRotationForHeavyLeftBasket() {
        let rotation = MoleculeScales.rotationEquation(
            leftMolecules: .single(concentration: .init(fraction: ConstantEquation(value: 1))),
            rightMolecules: .single(concentration: .init(fraction: ConstantEquation(value: 0)))
        )
        XCTAssertEqual(rotation.getY(at: 0), -1)
    }

    func testRotationForHeavyLeftBasketWhileAddingToTheRightBasket() {
        let rotation = MoleculeScales.rotationEquation(
            leftMolecules: .single(fraction: ConstantEquation(value: 1)),
            rightMolecules: .single(fraction: LinearEquation(m: 1, x1: 0, y1: 0))
        )
        XCTAssertEqual(rotation.getY(at: 0), -1)
        XCTAssertEqual(rotation.getY(at: 1), 0)
    }

}

private extension MoleculeScales.Molecules {
    static func single(fraction: Equation) -> MoleculeScales.Molecules {
        .single(concentration: .init(fraction: fraction))
    }
}

private extension MoleculeScales.MoleculeEquation {
    init(fraction: Equation) {
        self.init(fractionToDraw: fraction, color: .red, label: "")
    }
}
