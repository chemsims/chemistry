//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationComponentsReactantPreparationTests: XCTestCase {

    func testInputLimitsOfKnownReactant() {
        let minToAdd = PrecipitationComponents.KnownReactantPreparation.minToAdd(
            unknownReactantCoeff: 2,
            grid: .init(rows: 10, cols: 10),
            settings: .init(
                minConcentrationOfKnownReactantPostFirstReaction: 0.1,
                minConcentrationOfUnknownReactantToReact: 0.2
            )
        )
        XCTAssertEqual(minToAdd, 20)


        let maxToAdd = PrecipitationComponents.KnownReactantPreparation.maxToAdd(
            unknownReactantCoeff: 2,
            grid: .init(rows: 10, cols: 10),
            settings: .init(
                minConcentrationOfKnownReactantPostFirstReaction: 0.1,
                minConcentrationOfUnknownReactantToReact: 0.2
            )
        )

        // After the reaction we want a maximum of 33 known coords, so that we
        // can later add 66 unknown coords to consume everything.
        // If we start with 55 known coords, then we can add
        // 45 unknown, which will all react, consuming 22.5 (45/2) known
        // coords. This leaves 32.5 known coords, which is below the
        // final coords we want, even if we round up.
        XCTAssertEqual(maxToAdd, 55)
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
