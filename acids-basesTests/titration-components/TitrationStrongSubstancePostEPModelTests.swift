//
// Reactions App
//

import XCTest
import CoreGraphics
import ReactionsCore
@testable import acids_bases

class TitrationStrongSubstancePostEPModelTests: XCTestCase {

    func testConcentration() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqualWithTolerance(model.concentration.value(for: .hydrogen), 1e-7)
        XCTAssertEqualWithTolerance(model.concentration.value(for: .hydroxide), 1e-7)

        model.incrementTitrant(count: model.maxTitrant)

        let finalPH = firstModel.settings.finalMaxPValue
        let expectedHConcentration = PrimaryIonConcentration.concentration(forP: finalPH)
        let expectedOHConcentration = PrimaryIonConcentration.complementConcentration(
            primaryConcentration: expectedHConcentration
        )

        XCTAssertEqualWithTolerance(model.concentration.value(for: .hydrogen), expectedHConcentration)
        XCTAssertEqualWithTolerance(model.concentration.value(for: .hydroxide), expectedOHConcentration)
    }

    func testMolarity() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.molarity, secondModel.molarity)
    }

    func testMoles() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(
            model.moles.value(for: .substance),
            model.molarity.value(for: .substance) * model.volume.value(for: .substance)
        )
        XCTAssertEqual(
            model.moles.value(for: .titrant),
            model.molarity.value(for: .titrant) * model.volume.value(for: .titrant)
        )

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqual(
            model.moles.value(for: .substance),
            model.molarity.value(for: .substance) * model.volume.value(for: .substance)
        )
        XCTAssertEqual(
            model.moles.value(for: .titrant),
            model.molarity.value(for: .titrant) * model.volume.value(for: .titrant)
        )
    }

    func testVolume() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.volume.value(for: .substance), secondModel.volume.value(for: .substance))
        XCTAssertEqual(model.volume.value(for: .titrant), secondModel.volume.value(for: .titrant))

        model.incrementTitrant(count: model.maxTitrant)

        let finalTitrantVolume = model.volume.value(for: .titrant)
        let substanceVolume = model.volume.value(for: .substance)
        let titrantMoles = model.moles.value(for: .titrant)
        let substanceMoles = model.moles.value(for: .substance)


        // If the volume & moles are correct, then this equation should be satisfied:
        // [OH] = (n-titrant - n-substance) / (V-titrant + V-substance)
        let resultingFinalOHConcentration = (titrantMoles - substanceMoles) / (finalTitrantVolume + substanceVolume)
        XCTAssertEqualWithTolerance(resultingFinalOHConcentration, model.concentration.value(for: .hydroxide))
    }

    func testPValues() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)


        XCTAssertEqualWithTolerance(model.pValues.value(for: .hydrogen), 7)
        XCTAssertEqualWithTolerance(model.pValues.value(for: .hydroxide), 7)
        XCTAssertEqual(model.pValues.value(for: .kA), secondModel.pValues.value(for: .kA))
        XCTAssertEqual(model.pValues.value(for: .kB), secondModel.pValues.value(for: .kB))

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqualWithTolerance(model.pValues.value(for: .hydrogen), 12)
        XCTAssertEqualWithTolerance(model.pValues.value(for: .hydroxide), 2)
    }

    func testKValues() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.kValues, secondModel.kValues)
    }
}
