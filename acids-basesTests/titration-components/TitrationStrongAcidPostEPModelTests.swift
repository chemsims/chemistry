//
// Reactions App
//

import XCTest
import CoreGraphics
import ReactionsCore
@testable import acids_bases

class TitrationStrongAcidPostEPModelTests: XCTestCase {

    var substance = AcidOrBase.strongAcids.first!

    /// The ion which increases as substance is added to a solution
    private var increasingIon: PrimaryIon {
        substance.primary
    }

    /// The ion which decreases as substance is added to a solution
    private var decreasingIon: PrimaryIon {
        increasingIon.complement
    }

    func testConcentration() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqualWithTolerance(model.currentConcentration.value(for: .hydrogen), 1e-7)
        XCTAssertEqualWithTolerance(model.currentConcentration.value(for: .hydroxide), 1e-7)

        model.incrementTitrant(count: model.maxTitrant)

        let finalPIncreasingIon = firstModel.settings.finalMaxPValue
        let expectedIncreasingIonConcentration = PrimaryIonConcentration.concentration(
            forP: finalPIncreasingIon
        )
        let expectedDecreasingIonConcentration = PrimaryIonConcentration.complementConcentration(
            primaryConcentration: expectedIncreasingIonConcentration
        )

        XCTAssertEqualWithTolerance(
            model.currentConcentration.value(for: increasingIon.concentration),
            expectedIncreasingIonConcentration
        )
        XCTAssertEqualWithTolerance(
            model.currentConcentration.value(for: decreasingIon.concentration),
            expectedDecreasingIonConcentration
        )
    }

    func testMolarity() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.molarity, secondModel.molarity)
    }

    func testMoles() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(
            model.currentMoles.value(for: .substance),
            model.molarity.value(for: .substance) * model.currentVolumes.value(for: .substance)
        )
        XCTAssertEqual(
            model.currentMoles.value(for: .titrant),
            model.molarity.value(for: .titrant) * model.currentVolumes.value(for: .titrant)
        )

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqual(
            model.currentMoles.value(for: .substance),
            model.molarity.value(for: .substance) * model.currentVolumes.value(for: .substance)
        )
        XCTAssertEqual(
            model.currentMoles.value(for: .titrant),
            model.molarity.value(for: .titrant) * model.currentVolumes.value(for: .titrant)
        )
    }

    func testVolume() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.currentVolumes.value(for: .substance), secondModel.currentVolume.value(for: .substance))
        XCTAssertEqual(model.currentVolumes.value(for: .titrant), secondModel.currentVolume.value(for: .titrant))

        model.incrementTitrant(count: model.maxTitrant)

        let finalTitrantVolume = model.currentVolumes.value(for: .titrant)
        let substanceVolume = model.currentVolumes.value(for: .substance)
        let titrantMoles = model.currentMoles.value(for: .titrant)
        let substanceMoles = model.currentMoles.value(for: .substance)


        // If the volume & moles are correct, then this equation should be satisfied:
        // [OH] = (n-titrant - n-substance) / (V-titrant + V-substance)
        let resultingFinalDecreasingIonConcentration = (titrantMoles - substanceMoles) / (finalTitrantVolume + substanceVolume)
        XCTAssertEqualWithTolerance(
            resultingFinalDecreasingIonConcentration,
            model.currentConcentration.value(for: decreasingIon.concentration)
        )
    }

    func testPValues() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)


        XCTAssertEqualWithTolerance(model.currentPValues.value(for: .hydrogen), 7)
        XCTAssertEqualWithTolerance(model.currentPValues.value(for: .hydroxide), 7)
        XCTAssertEqual(model.currentPValues.value(for: .kA), secondModel.currentPValues.value(for: .kA))
        XCTAssertEqual(model.currentPValues.value(for: .kB), secondModel.currentPValues.value(for: .kB))

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqualWithTolerance(
            model.currentPValues.value(for: increasingIon.pValue), 12
        )
        XCTAssertEqualWithTolerance(model.currentPValues.value(for: decreasingIon.pValue), 2)
    }

    func testKValues() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(finalMaxPValue: 12)
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.equationData.kValues, secondModel.equationData.kValues)
    }

    func testBarChart() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                neutralSubstanceBarChartHeight: 0.4,
                finalMaxPValue: 12
            )
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        var decreasingIonBar: Equation {
            model.barChartDataMap.value(for: decreasingIon).equation

        }
        var increasingIonBar: Equation {
            model.barChartDataMap.value(for: increasingIon).equation
        }

        XCTAssertEqualWithTolerance(increasingIonBar.getY(at: 0), 0.4)
        XCTAssertEqualWithTolerance(decreasingIonBar.getY(at: 0), 0.4)

        XCTAssertEqualWithTolerance(increasingIonBar.getY(at: CGFloat(model.maxTitrant)), 0)

        let expectedDecreasingIonConcentration: CGFloat = 0.01
        let expectedDecreasingIonBarHeight = LinearEquation(
            x1: 1e-7,
            y1: 0.4,
            x2: 1,
            y2: 1
        ).getY(at: expectedDecreasingIonConcentration)

        XCTAssertEqualWithTolerance(
            decreasingIonBar.getY(at: CGFloat(model.maxTitrant)),
            expectedDecreasingIonBarHeight
        )
    }

    func testInputLimits() {
        let firstModel = TitrationStrongSubstancePreparationModel()
        firstModel.incrementSubstance(count: 15)
        let secondModel = TitrationStrongSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: 15)
        let model = TitrationStrongSubstancePostEPModel(previous: secondModel)

        XCTAssert(model.canAddTitrant)
        XCTAssertFalse(model.hasAddedEnoughTitrant)

        model.incrementTitrant(count: 50)
        XCTAssertFalse(model.canAddTitrant)
        XCTAssert(model.hasAddedEnoughTitrant)

        XCTAssertEqual(model.titrantAdded, 15)
    }
}
