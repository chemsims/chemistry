//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationComponentsTests: XCTestCase {

    func testConcentration() {
        let acid = AcidOrBase.weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(1)!,
            color: .red,
            kA: 1e-5
        )
        let model = TitrationComponents(
            substance: acid,
            cols: 10,
            rows: 10,
            settings: .withDefaults(
                initialIonMoleculeFraction: 0.1,
                minInitialIonBeakerMolecules: 1
            )
        )
        model.incrementStrongAcid(count: 20)

        let substance = model.concentration.substance
        let primary = model.concentration.primaryIon
        let secondary = model.concentration.secondaryIon

        let changeInConcentration = primary.getY(at: 1)

        let kA = pow(changeInConcentration, 2) / (0.2 - changeInConcentration)
        XCTAssertEqual(kA, acid.kA, accuracy: 1e-10)

        XCTAssertEqual(substance.getY(at: 0), 0.2)
        XCTAssertEqual(substance.getY(at: 1), 0.2 - changeInConcentration)

        XCTAssertEqual(primary.getY(at: 0), 0)
        XCTAssertEqual(primary.getY(at: 1), changeInConcentration)
        XCTAssertEqual(secondary.getY(at: 0), 0)
        XCTAssertEqual(secondary.getY(at: 1), changeInConcentration)
    }

    func testCoordsWhenIncrementingStrongAcid() {
        let model = newModel()
        XCTAssert(model.substanceCoords.coords.isEmpty)
        model.incrementStrongAcid(count: 1)
        XCTAssertEqual(model.substanceCoords.coords.count, 1)
    }

    func testInputLimits() {
        let settings1 = TitrationSettings.withDefaults(
            initialIonMoleculeFraction: 0.1,
            minInitialIonBeakerMolecules: 1
        )
        XCTAssertEqual(settings1.minInitialSubstance, 10)

        let settings2 = TitrationSettings.withDefaults(
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
        TitrationComponents(
            substance: .weakAcids.first!,
            cols: 10,
            rows: 10,
            settings: settings
        )
    }
}
