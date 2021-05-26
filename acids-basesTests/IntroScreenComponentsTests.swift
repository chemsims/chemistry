//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class IntroScreenComponentsTests: XCTestCase {

    func testStrongAcidSubstanceAdded() {
        var model = newModel(substance: .strongAcid(name: "", secondaryIon: .A))

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
        let acid = AcidOrBase.strongAcid(name: "", secondaryIon: .A)
        doTestAcidPrimaryIonConcentration(substance: acid)
    }

    func testStrongAcidCoords() {
        var model = newModel(substance: .strongAcid(name: "", secondaryIon: .A))

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
            name: "",
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(5)!
        )
        doTestAcidPrimaryIonConcentration(substance: acid)
    }

    func testWeakAcidCoords() {
        let acid = AcidOrBase.weakAcid(
            name: "",
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(5)!
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
        let base = AcidOrBase.strongBase(name: "", secondaryIon: .A)
        doTestAcidPrimaryIonConcentration(substance: base)
    }

    func testWeakBasePrimaryIonsConcentration() {
        let base = AcidOrBase.weakBase(
            name: "",
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(4)!
        )
        doTestAcidPrimaryIonConcentration(substance: base)
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
