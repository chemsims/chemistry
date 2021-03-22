//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class ScalesRotationEquationTests: XCTestCase {

    func testForwardReactionRotation() {
        var reaction = BalancedReactionEquation(
            coefficients: .unit,
            equilibriumConstant: 1,
            initialConcentrations: MoleculeValue(builder: { _ in 0 }),
            startTime: 0,
            equilibriumTime: 10,
            previous: nil
        )
        var model: ScalesRotationEquation {
            ScalesRotationEquation(reaction: reaction, maxAngle: 50)
        }

        func expectedInitial(_ concentrationSum: CGFloat) -> CGFloat {
            -50 * (concentrationSum / AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation)
        }

        func expectedFor(quotient: CGFloat) -> CGFloat {
            -50 + (quotient * 50)
        }

        XCTAssertEqual(model.getY(at: 0), 0)

        reaction = reaction.withA0(0.1)
        XCTAssertEqual(model.getY(at: 0), expectedInitial(0.1))

        reaction = reaction.withB0(0.2)
        XCTAssertEqual(model.getY(at: 0), expectedInitial(0.3), accuracy: 0.000001)

        reaction = reaction.withA0(2 * AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation)
        XCTAssertEqual(model.getY(at: 0), -50)

        reaction = reaction.withA0(AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation / 2)
        reaction = reaction.withB0(AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation / 2)
        XCTAssertEqual(model.getY(at: 0), -50)
        XCTAssertEqual(model.getY(at: 10), 0)
    }

    func testReverseReactionRotation() {
        let forward = BalancedReactionEquation(
            coefficients: .unit,
            equilibriumConstant: 1,
            initialConcentrations: MoleculeValue(
                reactantA: 0.3,
                reactantB: 0.3,
                productC: 0,
                productD: 0
            ),
            startTime: 0,
            equilibriumTime: 10,
            previous: nil
        )
        let tAddProd = AqueousReactionSettings.timeToAddProduct
        let tFinal = AqueousReactionSettings.endOfReverseReaction

        func makeReverse(c0: CGFloat, d0: CGFloat) -> BalancedReactionEquation {
            BalancedReactionEquation(
                coefficients: .unit,
                equilibriumConstant: 1,
                initialConcentrations: MoleculeValue(
                    reactantA: forward.equilibriumConcentrations.reactantA,
                    reactantB: forward.equilibriumConcentrations.reactantB,
                    productC: c0,
                    productD: d0
                ),
                startTime: tAddProd,
                equilibriumTime: tFinal,
                previous: forward
            )
        }
        var reverse = makeReverse(c0: 0.15, d0: 0.15)
        var model: ScalesRotationEquation {
            ScalesRotationEquation(reaction: reverse, maxAngle: 50)
        }

        func expectedInitial(_ concentrationSum: CGFloat) -> CGFloat {
            50 * (concentrationSum / AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation)
        }

        XCTAssertEqual(model.getY(at: 10), 0, accuracy: 0.01)
        XCTAssertEqual(model.getY(at: 11), 0, accuracy: 0.01)

        reverse = makeReverse(c0: 0.25, d0: 0.15)
        XCTAssertEqual(model.getY(at: tAddProd), expectedInitial(0.4))

        reverse = makeReverse(c0: 0.25, d0: 0.3)
        XCTAssertEqual(model.getY(at: tAddProd), expectedInitial(0.55))

        let maxSum = AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation
        reverse = makeReverse(c0: maxSum, d0: maxSum)
        XCTAssertEqual(model.getY(at: tAddProd), 50)

        reverse = makeReverse(c0: maxSum / 2, d0: maxSum / 2)
        XCTAssertEqual(model.getY(at: tAddProd), 50)
        XCTAssertEqual(model.getY(at: tFinal), 0)

        let quotient = ReactionQuotientEquation(equations: reverse)
        let maxQuotient = quotient.getY(at: tAddProd)

        func expectedFor(quotient: CGFloat) -> CGFloat {
            50 * ((quotient - 1) / (maxQuotient - 1))
        }

        XCTAssertEqual(model.getY(at: tAddProd + 1), expectedFor(quotient: quotient.getY(at: tAddProd + 1)))
        XCTAssertEqual(model.getY(at: tAddProd + 2), expectedFor(quotient: quotient.getY(at: tAddProd + 2)))
        XCTAssertEqual(model.getY(at: tAddProd + 10), expectedFor(quotient: quotient.getY(at: tAddProd + 10)))
    }
}
