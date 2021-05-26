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

    func testStrongAcidHydrogenAndHydroxideConcentration() {
        var model = newModel(substance: .strongAcid(name: "", secondaryIon: .A))
        var hydrogen: PrimaryIonConcentration {
            model.concentration(ofIon: .hydrogen)
        }
        var hydroxide: PrimaryIonConcentration {
            model.concentration(ofIon: .hydroxide)
        }

        // MARK: Strong acid: initial ion concentrations
        XCTAssertEqual(hydrogen.concentration, 1e-7)
        XCTAssertEqual(hydrogen.p, 7)
        XCTAssertEqual(hydroxide.concentration, 1e-7)
        XCTAssertEqual(hydroxide.p, 7)

        // MARK: Strong acid: mid-point ion concentrations
        model.increment(count: model.maxSubstanceCount / 2)
        let expectedMidPointHConcentration: CGFloat = (1e-7 + 1e-1) / 2
        let expectedMidPointPH = -log10(expectedMidPointHConcentration)
        let expectedMidPointPOH: CGFloat = 14 - expectedMidPointPH
        let expectedMidPointOHConcentration = pow(10, -expectedMidPointPOH)

        XCTAssertEqual(hydrogen.concentration, expectedMidPointHConcentration)
        XCTAssertEqual(hydrogen.p, expectedMidPointPH)
        XCTAssertEqual(hydroxide.concentration, expectedMidPointOHConcentration)
        XCTAssertEqual(hydroxide.p, expectedMidPointPOH)

        // MARK: Strong acid: end ion concentrations
        model.increment(count: model.maxSubstanceCount / 2)
        XCTAssertEqual(hydrogen.concentration, 1e-1)
        XCTAssertEqual(hydrogen.p, 1)
        XCTAssertEqual(hydroxide.concentration, 1e-13)
        XCTAssertEqual(hydroxide.p, 13)
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

    private func newModel(substance: AcidSubstance) -> IntroScreenComponents {
        GeneralScreenComponents(
            substance: substance,
            cols: 10,
            rows: 10
        )
    }
}
