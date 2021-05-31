//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class IntroScreenComponentsTests: XCTestCase {

    func testStrongAcidSubstanceAdded() {
        var model = newModel(substance: .strongAcid(secondaryIon: .A, color: .blue))

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
        let acid = AcidOrBase.strongAcid(secondaryIon: .A, color: .blue)
        doTestAcidPrimaryIonConcentration(substance: acid)
    }

    func testStrongAcidCoords() {
        var model = newModel(substance: .strongAcid(secondaryIon: .A, color: .blue))

        model.coords.all.forEach { coord in
            XCTAssert(coord.coords.isEmpty)
        }

        model.increment(count: 1)
        XCTAssert(model.coords.substanceValue.coords.isEmpty)
        XCTAssertEqual(model.coords.primaryIonValue.coords.count, 1)
        XCTAssertEqual(model.coords.secondaryIonValue.coords.count, 1)
    }

    func testWeakAcidPrimaryIonsConcentration() {
        let acid = AcidOrBase.weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(5)!,
            color: .blue
        )
        doTestAcidPrimaryIonConcentration(substance: acid)
    }

    func testWeakAcidCoords() {
        let acid = AcidOrBase.weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(5)!,
            color: .blue
        )
        var model = newModel(substance: acid)

        model.coords.all.forEach { coord in
            XCTAssert(coord.coords.isEmpty)
        }

        model.increment(count: 4)
        XCTAssertEqual(model.coords.substanceValue.coords.count, 4)
        XCTAssert(model.coords.primaryIonValue.coords.isEmpty)
        XCTAssert(model.coords.secondaryIonValue.coords.isEmpty)

        model.increment(count: 1)
        XCTAssertEqual(model.coords.substanceValue.coords.count, 5)
        XCTAssertEqual(model.coords.primaryIonValue.coords.count, 1)
        XCTAssertEqual(model.coords.secondaryIonValue.coords.count, 1)
    }

    func testStrongBasePrimaryIonsConcentration() {
        let base = AcidOrBase.strongBase(secondaryIon: .A, color: .blue)
        doTestAcidPrimaryIonConcentration(substance: base)
    }

    func testWeakBasePrimaryIonsConcentration() {
        let base = AcidOrBase.weakBase(
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(4)!,
            color: .blue
        )
        doTestAcidPrimaryIonConcentration(substance: base)
    }

    func testStrongAcidBarChart() {
        let acid = AcidOrBase.strongAcid(secondaryIon: .A, color: .blue)
        doTestBarChartData(substance: acid, finalSubstanceAmount: 0, finalIonAmount: 1)
    }

    func testStrongBaseBarChart() {
        let base = AcidOrBase.strongBase(secondaryIon: .A, color: .blue)
        doTestBarChartData(substance: base, finalSubstanceAmount: 0, finalIonAmount: 1)
    }

    func testWeakAcidBarChart() {
        let acid = AcidOrBase.weakAcid(secondaryIon: .A, substanceAddedPerIon: NonZeroPositiveInt(2)!, color: .red)
        doTestBarChartData(substance: acid, finalSubstanceAmount: 1, finalIonAmount: 0.5)
    }

    func testWeakBaseBarChart() {
        let acid = AcidOrBase.weakAcid(secondaryIon: .A, substanceAddedPerIon: NonZeroPositiveInt(5)!, color: .red)
        doTestBarChartData(substance: acid, finalSubstanceAmount: 1, finalIonAmount: 0.2)
    }

    private func doTestBarChartData(
        substance: AcidOrBase,
        finalSubstanceAmount: CGFloat,
        finalIonAmount: CGFloat
    ) {
        let model = newModel(substance: substance)
        model.barChart.all.forEach { data in
            XCTAssertEqual(data.equation.getY(at: 0), 0)
        }

        XCTAssertEqual(model.barChart.substanceValue.equation.getY(at: 1), finalSubstanceAmount)
        XCTAssertEqual(model.barChart.primaryIonValue.equation.getY(at: 1), finalIonAmount)
        XCTAssertEqual(model.barChart.secondaryIonValue.equation.getY(at: 1), finalIonAmount)
    }

    private func doTestAcidPrimaryIonConcentration(
        substance: AcidOrBase
    ) {
        var model = newModel(substance: substance)
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
        GeneralScreenComponents(
            substance: substance,
            cols: 10,
            rows: 10
        )
    }
}
