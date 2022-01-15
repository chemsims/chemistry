//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import Equilibrium

class AqueousScalesRotationTests: XCTestCase {

    func testRotationForFirstTwoReactions() {
        let model = AqueousReactionViewModel()
        let nav = model.navigation!


        let gridCount = MoleculeGridSettings.cols * GridUtil.availableRows(for: model.rows)
        var equilibriumTime: CGFloat {
            model.components.equilibriumTime
        }
        var scalesRotation: Equation {
            model.scalesRotationFraction
        }
        var startTime: CGFloat {
            model.components.startTime
        }
        var startRotation: CGFloat {
            scalesRotation.getValue(at: model.components.startTime)
        }
        var endRotation: CGFloat {
            scalesRotation.getValue(at: model.components.equilibriumTime)
        }

        nav.nextUntil { $0.inputState == .addReactants }
        while(model.componentsWrapper.canIncrement(molecule: .A)) {
            model.increment(molecule: .A, count: 1)
        }
        XCTAssertEqual(startRotation, -0.5)
        XCTAssertEqual(endRotation, 0)

        let maxInitialC = AqueousReactionSettings.ConcentrationInput.maxInitial
        let countBToAdd = (CGFloat(gridCount) * 0.5 * maxInitialC).roundedInt()

        model.increment(molecule: .B, count: countBToAdd)

        let concentrationB = CGFloat(countBToAdd) / CGFloat(gridCount)

        let expectedRotation = (concentrationB + maxInitialC) / (2 * maxInitialC)
        XCTAssertEqual(startRotation, -expectedRotation)
        XCTAssertEqual(endRotation, 0)

        nav.nextUntil { $0.inputState == .addProducts }

        XCTAssertEqual(startRotation, 0)

        [AqueousMolecule.C, AqueousMolecule.D].forEach { molecule in
            while(model.componentsWrapper.canIncrement(molecule: molecule)) {
                model.increment(molecule: molecule, count: 1)
            }
        }

        XCTAssertEqual(startRotation, 1)
        XCTAssertEqual(endRotation, 0)
    }
}
