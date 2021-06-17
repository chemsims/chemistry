//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationComponentsTests: XCTestCase {

    func testCoordsWhenIncrementingStrongAcid() {
        let model = newModel()
        XCTAssert(model.substanceCoords.coords.isEmpty)
        model.incrementStrongAcid(count: 1)
        XCTAssertEqual(model.substanceCoords.coords.count, 1)
    }

    func testInputLimits() {
        let settings1 = TitrationSettings(
            initialIonMoleculeFraction: 0.1,
            minInitialIonBeakerMolecules: 1
        )
        XCTAssertEqual(settings1.minInitialSubstance, 10)

        let settings2 = TitrationSettings(
            initialIonMoleculeFraction: 0.11,
            minInitialIonBeakerMolecules: 2
        )
        XCTAssertEqual(settings2.minInitialSubstance, 19)
    }

    func testIonCoordsAreProducedAfterFirstReaction() {
        let model = newModel()
        model.incrementStrongAcid(count: model.settings.minInitialSubstance)

        let expectedCount = model.settings.minInitialIonBeakerMolecules
        model.ionCoords.forEach { molecules in
            XCTAssertEqual(molecules.molecules.coords.count, expectedCount)
        }
    }

    private func newModel(settings: TitrationSettings = .standard) -> TitrationComponents {
        TitrationComponents(cols: 10, rows: 10, settings: settings)
    }
}
