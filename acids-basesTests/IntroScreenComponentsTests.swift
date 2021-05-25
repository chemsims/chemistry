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

    func testStrongAcidHydrogenConcentration() {
        var model = newModel(substance: .strongAcid(name: "", secondaryIon: .A))
        var hydrogen: PrimaryIonConcentration {
            model.concentration(ofIon: .hydrogen)
        }

        XCTAssertEqual(hydrogen.concentration, 1e-7)
        XCTAssertEqual(hydrogen.p, 7)

        model.increment(count: model.maxSubstanceCount / 2)
        XCTAssertEqual(hydrogen.concentration, pow(10, -4))
        XCTAssertEqual(hydrogen.p, 4)

        model.increment(count: model.maxSubstanceCount / 2)
        XCTAssertEqual(hydrogen.concentration, 1e-1)
        XCTAssertEqual(hydrogen.p, 1)
    }

    func testStrongAcidHydroxideConcentration() {
        var model = newModel(substance: .strongAcid(name: "", secondaryIon: .A))
        var hydroxide: PrimaryIonConcentration {
            model.concentration(ofIon: .hydroxide)
        }

        XCTAssertEqual(hydroxide.concentration, 1e-7)
        XCTAssertEqual(hydroxide.p, 7)

        model.increment(count: model.maxSubstanceCount / 2)
        XCTAssertEqual(hydroxide.concentration, pow(10, -10))
        XCTAssertEqual(hydroxide.p, 10)

        model.increment(count: model.maxSubstanceCount)
        XCTAssertEqual(hydroxide.concentration, 1e-13)
        XCTAssertEqual(hydroxide.p, 13)
    }

    private func newModel(substance: Substance) -> IntroScreenComponents {
        GeneralScreenComponents(
            substance: substance,
            cols: 10,
            rows: 10
        )
    }
}
