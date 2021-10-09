//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationComponentsReactantPreparationTests: XCTestCase {

//    func testInputLimitsOfKnownReactant() {
//        let minToAdd = PrecipitationComponents.KnownReactantPreparation.minToAdd(
//            unknownReactantCoeff: 2,
//            grid: .init(rows: 10, cols: 10),
//            settings: .init(
//                minConcentrationOfKnownReactantPostFirstReaction: 0.1,
//                minConcentrationOfUnknownReactantToReact: 0.2
//            )
//        )
//        XCTAssertEqual(minToAdd, 20)
//
//        let maxToAdd = PrecipitationComponents.KnownReactantPreparation.maxToAdd(
//            unknownReactantCoeff: 2,
//            grid: .init(rows: 10, cols: 10),
//            settings: .init(
//                minConcentrationOfKnownReactantPostFirstReaction: 0.1,
//                minConcentrationOfUnknownReactantToReact: 0.2
//            )
//        )
//
//        // After the reaction we want a maximum of 33 known coords, so that we
//        // can later add 66 unknown coords to consume everything.
//        // If we start with 55 known coords, then we can add
//        // 45 unknown, which will all react, consuming 22.5 (45/2) known
//        // coords. This leaves 32.5 known coords, which is below the
//        // final coords we want, even if we round up.
//        XCTAssertEqual(maxToAdd, 33)
//    }

//    func testMaxKnownReactantInputLimit() {
//        let maxToAdd = PrecipitationComponents.KnownReactantPreparation.maxToAdd(
//            unknownReactantCoeff: 2,
//            grid: .init(rows: 10, cols: 10),
//            settings: .init(
//                minConcentrationOfKnownReactantPostFirstReaction: 0.15,
//                minConcentrationOfUnknownReactantToReact: 0.18
//            )
//        )
//
//        // The maximum known reactant we can add is also a function of how much unknown
//        // reactant we add. This is because later, we'll need to add more unknown reactant
//        // to consume all the known reactant. In this case twice as much because the coefficient
//        // of the unknown reactant is 2.
//        //
//        // So the limiting case is when we add the minimum amount of unknown reactant we want
//        // to react, which in our settings we said is 18.
//        //
//        // We can derive a formula which shows the answer is 39 - the derivation of this is in
//        // core code. But we can also prove this, by first assuming a value of 39, and then
//        // figuring out the number of coordinates at the end. So, to start with we have 39 known
//        // coords and add 18 unknown coords. After the reaction, all unknown coords are consumed,
//        // and we consume 9 known coords (18 divided by the coeff, which is 2). We produce the
//        // same number of product coords, so in the beaker we have 39 known coords and 9 product
//        // coords. Now, we need to add enough additional unknown reactant to consume all the
//        // remaining product. Since every 2 unknown coords react with 1 known coord, we need to
//        // add 88 unknown coords.
//    }


    // TODO - this is failing
    func testAllInputLimitsDoNotExceedBeaker() {
        let grid = BeakerGrid(rows: 10, cols: 10)
        verifyInputLimits(grid: grid, unknownReactantCoeff: 1)
        verifyInputLimits(grid: grid, unknownReactantCoeff: 2)
    }

    private func verifyInputLimits(
        grid: BeakerGrid,
        unknownReactantCoeff: Int
    ) {
        let (min, max) = PrecipitationComponents.KnownReactantPreparation.inputLimits(
            unknownReactantCoeff: unknownReactantCoeff,
            grid: grid,
            settings: .init()
        )
        func doVerify(knownCoords: Int) {
            verifyInputLimits(
                grid: grid,
                knownCoords: knownCoords,
                unknownReactantCoeff: unknownReactantCoeff
            )
        }
        doVerify(knownCoords: min)
        doVerify(knownCoords: max)
    }

    private func verifyInputLimits(
        grid: BeakerGrid,
        knownCoords: Int,
        unknownReactantCoeff: Int
    ) {
        let (min, max) = PrecipitationComponents.UnknownReactantPreparation.inputLimits(
            unknownReactantCoeff: unknownReactantCoeff,
            knownReactantCount: knownCoords,
            grid: grid,
            settings: .init()
        )
        func doVerify(unknownCoords: Int) {
            verifyInputIsValid(
                gridSize: grid.size,
                knownCoords: knownCoords,
                unknownCoords: unknownCoords,
                unknownReactantCoeff: unknownReactantCoeff
            )
        }
        doVerify(unknownCoords: min)
        doVerify(unknownCoords: max)
    }

    private func verifyInputIsValid(
        gridSize: Int,
        knownCoords: Int,
        unknownCoords: Int,
        unknownReactantCoeff: Int
    ) {
        XCTAssertLessThanOrEqual(knownCoords + unknownCoords, gridSize)

        let knownConsumed = (Double(unknownCoords) / Double(unknownReactantCoeff)).roundedInt()

        let knownPostReaction = knownCoords - knownConsumed
        let initialProduct = knownConsumed

        let requiredExtra = unknownReactantCoeff * knownPostReaction

        let totalInBeaker = knownPostReaction + initialProduct + requiredExtra
        XCTAssertLessThan(totalInBeaker, gridSize)
    }

    func testInputLimitsOfUnknownReactant() {
        let minToAdd = PrecipitationComponents.UnknownReactantPreparation.minToAdd(
            grid: .init(rows: 10, cols: 10),
            settings: .init(
                minConcentrationOfUnknownReactantToReact: 0.3
            )
        )
        XCTAssertEqual(minToAdd, 30)


        let maxToAdd = PrecipitationComponents.UnknownReactantPreparation.maxToAdd(
            unknownReactantCoeff: 3,
            knownReactantCount: 30,
            grid: .init(rows: 10, cols: 10),
            settings: .init(
                minConcentrationOfKnownReactantPostFirstReaction: 0.2
            )
        )

        // We start with 30 known reactant coords and need at least 20
        // after the reaction. So, the reaction can consume a maximum of
        // 10 known reactant coords. With a coefficient of 3, this is
        // 30 unknown reactant coords
        XCTAssertEqual(maxToAdd, 30)
    }
}
