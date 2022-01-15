//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import Equilibrium

class GaseousScalesRotationTests: XCTestCase {

    func testScalesRotationFraction() {
        let model = GaseousReactionViewModel()
        let nav = model.navigation!

        var scalesRotation: Equation {
            model.scalesRotationFraction
        }
        var startRotation: CGFloat {
            scalesRotation.getValue(at: model.components.startTime)
        }
        var endRotation: CGFloat {
            scalesRotation.getValue(at: model.components.equilibriumTime)
        }

        nav.nextUntil { $0.inputState == .addReactants }

        XCTAssertEqual(startRotation, 0)

        while(model.componentWrapper.canIncrement(molecule: .A)) {
            model.pumpModel.onDownPump()
        }

        XCTAssertEqual(startRotation, -0.5)
        XCTAssertEqual(endRotation, 0)

        model.selectedPumpReactant =  .B
        while(model.componentWrapper.canIncrement(molecule: .B)) {
            model.pumpModel.onDownPump()
        }
        XCTAssertEqual(startRotation, -1)
        XCTAssertEqual(endRotation, 0)

        nav.nextUntil { $0.inputState == .setBeakerVolume }
        XCTAssertEqual(startRotation, 0)
        XCTAssertEqual(endRotation, 0)

        model.rows = CGFloat(GaseousReactionSettings.maxRows)
        XCTAssertEqual(startRotation, 1)
        XCTAssertEqual(endRotation, 0)

        model.rows = CGFloat(GaseousReactionSettings.minRows)
        XCTAssertEqual(startRotation, -1)
        XCTAssertEqual(endRotation, 0)

        nav.nextUntil { $0.inputState == .setTemperature }
        XCTAssertEqual(startRotation, 0)
        XCTAssertEqual(endRotation, 0)

        model.extraHeatFactor = 1
        XCTAssertEqual(startRotation, 1)
        XCTAssertEqual(endRotation, 0)

        model.selectedReaction = .B
        XCTAssertEqual(startRotation, -1)
        XCTAssertEqual(endRotation, 0)
    }

}
