//
// Reactions App
//

import XCTest
import CoreGraphics
import ReactionsCore
@testable import acids_bases

class TitrationStrongAcidPreEPModelTests: XCTestCase {

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
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        func checkZeroConcentrations() {
            XCTAssertEqual(model.currentConcentration.value(for: .substance), 0)
            XCTAssertEqual(model.currentConcentration.value(for: .initialSubstance), 0)
            XCTAssertEqual(model.currentConcentration.value(for: .secondary), 0)
            XCTAssertEqual(model.currentConcentration.value(for: .initialSecondary), 0)
        }
        checkZeroConcentrations()

        let expectedInitialIncreasing = expectedConcentration(afterIncrementing: 20)
        let expectedInitialDecreasing = PrimaryIonConcentration.complementConcentration(primaryConcentration: expectedInitialIncreasing)

        XCTAssertEqualWithTolerance(model.currentConcentration.value(for: increasingIon.concentration), expectedInitialIncreasing)
        XCTAssertEqualWithTolerance(
            model.currentConcentration.value(for: decreasingIon.concentration),
            expectedInitialDecreasing
        )

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqualWithTolerance(model.currentConcentration.value(for: .hydrogen), 1e-7)
        XCTAssertEqualWithTolerance(model.currentConcentration.value(for: .hydroxide), 1e-7)
        checkZeroConcentrations()
    }

    func testMolarity() {
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        XCTAssertEqualWithTolerance(
            model.molarity.value(for: .substance),
            firstModel.currentMolarity.value(for: .substance)
        )

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqualWithTolerance(
            model.molarity.value(for: .substance),
            firstModel.currentMolarity.value(for: .substance)
        )
    }

    func testMoles() {
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        XCTAssertEqualWithTolerance(
            model.currentMoles.value(for: .substance),
            firstModel.currentMoles.value(for: .substance)
        )

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqualWithTolerance(
            model.currentMoles.value(for: .substance),
            firstModel.currentMoles.value(for: .substance)
        )

        XCTAssertEqualWithTolerance(
            model.currentMoles.value(for: .titrant),
            model.currentVolume.value(for: .titrant) * model.molarity.value(for: .titrant)
        )

        // Titrant moles should be the same as substance moles
        XCTAssertEqualWithTolerance(
            model.currentMoles.value(for: .titrant),
            firstModel.currentMoles.value(for: .substance)
        )
    }

    func testVolume() {
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        XCTAssertEqual(model.currentVolume.value(for: .titrant), 0)

        model.incrementTitrant(count: model.maxTitrant)

        let titrantMolarity = model.molarity.value(for: .titrant)
        let substanceMoles = model.currentMoles.value(for: .substance)
        let expectedVolume = substanceMoles / titrantMolarity

        XCTAssertEqual(model.currentVolume.value(for: .titrant), expectedVolume)
    }

    func testPValues() {
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        func checkSamePValues(_ pValue: TitrationEquationTerm.PValue) {
            let firstPValue = firstModel.currentPValues.value(for: pValue)
            let modelPValue = model.currentPValues.value(for: pValue)
            XCTAssertEqualWithTolerance(modelPValue, firstPValue)
        }
        checkSamePValues(.hydrogen)
        checkSamePValues(.hydroxide)

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqualWithTolerance(model.currentPValues.value(for: .hydrogen), 7)
        XCTAssertEqualWithTolerance(model.currentPValues.value(for: .hydroxide), 7)
    }

    func testKValues() {
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)
        XCTAssertEqual(firstModel.equationData.kValues, model.equationData.kValues)
    }

    func testBarChartData() {
        let firstModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults( neutralSubstanceBarChartHeight: 0.3)
        )
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        let firstDecresingBar = firstModel.barChartDataMap.value(for: decreasingIon)
        let firstIncreasingBar = firstModel.barChartDataMap.value(for: increasingIon)
        var modelDecreasingBar: BarChartData {
            model.barChartDataMap.value(for: decreasingIon)

        }
        var modelHydrogenBar: BarChartData {
            model.barChartDataMap.value(for: increasingIon)
        }

        // Initial heights
        XCTAssertEqualWithTolerance(
            modelHydrogenBar.equation.getY(at: 0),
            firstIncreasingBar.equation.getY(at: 20)
        )
        XCTAssertEqualWithTolerance(
            modelDecreasingBar.equation.getY(at: 0),
            firstDecresingBar.equation.getY(at: 20)
        )

        // Mid heights
        let expectedMidHHeight = (firstIncreasingBar.equation.getY(at: 20) + 0.3) / 2
        let expectedMidOHHEight = (firstDecresingBar.equation.getY(at: 20) + 0.3) / 2

        XCTAssertEqualWithTolerance(
            modelHydrogenBar.equation.getY(at: CGFloat(model.maxTitrant) / 2),
            expectedMidHHeight
        )
        XCTAssertEqualWithTolerance(
            modelDecreasingBar.equation.getY(at: CGFloat(model.maxTitrant) / 2),
            expectedMidOHHEight
        )

        // Final heights
        XCTAssertEqualWithTolerance(modelHydrogenBar.equation.getY(at: CGFloat(model.maxTitrant)), 0.3)
        XCTAssertEqualWithTolerance(modelDecreasingBar.equation.getY(at: CGFloat(model.maxTitrant)), 0.3)
    }

    func testCoords() {
        let firstModel = TitrationStrongSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        XCTAssertEqual(model.primaryIonCoords.molecules.coords, firstModel.primaryIonCoords.coords)

        XCTAssertEqual(model.primaryIonCoords.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(model.primaryIonCoords.fractionToDraw.getY(at: CGFloat(model.maxTitrant)), 0)
    }

    func testInputLimits() {
        let firstModel = TitrationStrongSubstancePreparationModel()
        firstModel.incrementSubstance(count: 15)
        let model = TitrationStrongSubstancePreEPModel(previous: firstModel)

        XCTAssert(model.canAddTitrant)
        XCTAssertFalse(model.hasAddedEnoughTitrant)

        model.incrementTitrant(count: 50)

        XCTAssertFalse(model.canAddTitrant)
        XCTAssert(model.hasAddedEnoughTitrant)
        XCTAssertEqual(model.titrantAdded, 15)
    }

    private func expectedConcentration(afterIncrementing count: Int) -> CGFloat {
        TitrationStrongSubstancePreparationModel.concentrationOfIncreasingMolecule(
            afterIncrementing: count,
            gridSize: 100
        )
    }
}
