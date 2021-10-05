//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class PrecipitationComponentsTests: XCTestCase {

    func testMolarityOfKnownReactantIncreasesAfterAddingMolecule() {
        let model = PrecipitationComponents()
        model.add(reactant: .known, count: 10)

        XCTAssertEqual(model.knownReactantMolarity, 0.1)
        XCTAssertEqual(model.knownReactantMoles, 0.05)
    }

    func testMassOfUnknownReactantIncreasesAfterAddingMolecule() {
        let model = PrecipitationComponents()
        while(!model.hasAddedEnough(of: .known)) {
            model.add(reactant: .known, count: 1)
        }
        model.phase = .addUnknownReactant
        model.add(reactant: .unknown, count: 10)

        let expectedMoles = 0.5 * 0.1
        XCTAssertEqual(model.unknownReactantMoles, expectedMoles)

        let expectedMass = expectedMoles * CGFloat(model.reaction.unknownReactant.molarMass)
        XCTAssertEqual(model.unknownReactantMass, expectedMass)
    }
}

private extension PrecipitationComponents {
    convenience init() {
        self.init(
            reaction: .availableReactionsWithRandomMetals().first!,
            rows: 10,
            cols: 10,
            volume: 0.5
        )
    }
}
