//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class IntroScreenComponentsTests: XCTestCase {

    func testStrongAcidSubstanceAdded() {
        let model = newModel(substance: .strongAcid())

        XCTAssertEqual(model.substanceAdded, 0)
        XCTAssertEqual(model.fractionSubstanceAdded, 0)
        model.increment(count: 1)

        XCTAssertEqual(model.substanceAdded, 1)
        XCTAssertEqual(model.fractionSubstanceAdded, 1 / CGFloat(model.maxSubstanceCount))

        model.increment(count: model.maxSubstanceCount * 2)
        XCTAssertEqual(model.substanceAdded, model.maxSubstanceCount)
        XCTAssertEqual(model.fractionSubstanceAdded, 1)
    }

    func testStrongAcidPrimaryIonsConcentration() {
        doTestAcidPrimaryIonConcentration(substance: .strongAcid())
    }

    func testStrongAcidCoords() {
        let model = newModel(substance: .strongAcid())

        model.coords.all.forEach { coord in
            XCTAssert(coord.coords.isEmpty)
        }

        model.increment(count: 1)
        XCTAssert(model.coords.substance.coords.isEmpty)
        XCTAssertEqual(model.coords.primaryIon.coords.count, 1)
        XCTAssertEqual(model.coords.secondaryIon.coords.count, 1)
    }

    func testWeakAcidPrimaryIonsConcentration() {
        let acid = AcidOrBase.weakAcid(substanceAddedPerIon: NonZeroPositiveInt(5)!)
        doTestAcidPrimaryIonConcentration(substance: acid)
    }

    func testWeakAcidCoords() {
        let acid = AcidOrBase.weakAcid(substanceAddedPerIon: NonZeroPositiveInt(5)!)
        let model = newModel(substance: acid)

        model.coords.all.forEach { coord in
            XCTAssert(coord.coords.isEmpty)
        }

        model.increment(count: 4)
        XCTAssertEqual(model.coords.substance.coords.count, 4)
        XCTAssert(model.coords.primaryIon.coords.isEmpty)
        XCTAssert(model.coords.secondaryIon.coords.isEmpty)

        model.increment(count: 1)
        XCTAssertEqual(model.coords.substance.coords.count, 5)
        XCTAssertEqual(model.coords.primaryIon.coords.count, 1)
        XCTAssertEqual(model.coords.secondaryIon.coords.count, 1)
    }

    func testStrongBasePrimaryIonsConcentration() {
        doTestAcidPrimaryIonConcentration(substance: .strongBase())
    }

    func testWeakBasePrimaryIonsConcentration() {
        let base = AcidOrBase.weakBase(substanceAddedPerIon: NonZeroPositiveInt(4)!)
        doTestAcidPrimaryIonConcentration(substance: base)
    }

    func testStrongAcidBarChart() {
        let acid = AcidOrBase.strongAcid()
        doTestBarChartData(substance: acid, finalSubstanceAmount: 0, finalIonAmount: 1)
    }

    func testStrongBaseBarChart() {
        let base = AcidOrBase.strongBase()
        doTestBarChartData(substance: base, finalSubstanceAmount: 0, finalIonAmount: 1)
    }

    func testWeakAcidBarChart() {
        let acid = AcidOrBase.weakAcid(substanceAddedPerIon: NonZeroPositiveInt(2)!)
        doTestBarChartData(substance: acid, finalSubstanceAmount: 1, finalIonAmount: 0.5)
    }

    func testWeakBaseBarChart() {
        let acid = AcidOrBase.weakAcid(substanceAddedPerIon: NonZeroPositiveInt(5)!)
        doTestBarChartData(substance: acid, finalSubstanceAmount: 1, finalIonAmount: 0.2)
    }

    private func doTestBarChartData(
        substance: AcidOrBase,
        finalSubstanceAmount: CGFloat,
        finalIonAmount: CGFloat
    ) {
        let model = newModel(substance: substance)
        model.barChart.all.forEach { data in
            XCTAssertEqual(data.equation.getValue(at: 0), 0)
        }

        XCTAssertEqual(model.barChart.substance.equation.getValue(at: 1), finalSubstanceAmount)
        XCTAssertEqual(model.barChart.primaryIon.equation.getValue(at: 1), finalIonAmount)
        XCTAssertEqual(model.barChart.secondaryIon.equation.getValue(at: 1), finalIonAmount)
    }

    private func doTestAcidPrimaryIonConcentration(
        substance: AcidOrBase
    ) {
        let model = newModel(substance: substance)
        var increasingIon: PrimaryIonConcentration {
            model.concentration(ofIon: substance.primary)
        }
        var decreasingIon: PrimaryIonConcentration {
            model.concentration(ofIon: substance.primary.complement)
        }

        XCTAssertEqual(increasingIon.concentration, 1e-7)
        XCTAssertEqual(increasingIon.p, 7)
        XCTAssertEqual(decreasingIon.concentration, 1e-7)
        XCTAssertEqual(decreasingIon.p, 7)

        let finalIncreasingConcentration = substance.concentrationAtMaxSubstance

        model.increment(count: model.maxSubstanceCount / 2)
        let expectedMidPointIncreasingConcentration: CGFloat = (1e-7 + finalIncreasingConcentration) / 2
        let expectedMidPointPIncreasing = -log10(expectedMidPointIncreasingConcentration)
        let expectedMidPointPDecreasing: CGFloat = 14 - expectedMidPointPIncreasing
        let expectedMidPointDecreasingConcentration = pow(10, -expectedMidPointPDecreasing)

        XCTAssertEqual(increasingIon.concentration, expectedMidPointIncreasingConcentration)
        XCTAssertEqual(increasingIon.p, expectedMidPointPIncreasing)
        XCTAssertEqual(decreasingIon.concentration, expectedMidPointDecreasingConcentration)
        XCTAssertEqual(decreasingIon.p, expectedMidPointPDecreasing)

        model.increment(count: model.maxSubstanceCount / 2)
        let expectedFinalPIncreasing = -log10(finalIncreasingConcentration)
        let expectedFinalPDecreasing = 14 - expectedFinalPIncreasing
        let expectedFinalIncreasingConcentration = pow(10, -expectedFinalPDecreasing)
        XCTAssertEqual(increasingIon.concentration, finalIncreasingConcentration)
        XCTAssertEqual(increasingIon.p, expectedFinalPIncreasing)
        XCTAssertEqual(decreasingIon.concentration, expectedFinalIncreasingConcentration)
        XCTAssertEqual(decreasingIon.p, expectedFinalPDecreasing)
    }

    private func newModel(substance: AcidOrBase) -> IntroScreenComponents {
        IntroScreenComponents(
            substance: substance,
            cols: 10,
            rows: 10,
            maxSubstanceCountDivisor: 2
        )
    }
}
