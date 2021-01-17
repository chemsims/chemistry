//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionInputModelTests: XCTestCase {

    func testZeroOrderInputAllPropertiesLimits() {
        var model = ReactionInputAllProperties(order: .Zero)

        let expected = InputLimits(
            min: minCInput,
            max: maxCInput,
            smallerOtherValue: minC2Input,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.c1Limits, expected)

        var c2Expected: InputLimits {
            InputLimits(
                min: minCInput,
                max: maxCInput,
                smallerOtherValue: nil,
                largerOtherValue: model.inputC1
            )
        }

        XCTAssertEqual(model.c2Limits, c2Expected)
        model.inputC1 = 0.2
        XCTAssertEqual(model.c2Limits, c2Expected)
    }

    func testZeroOrderReactionFixedT2Limits() {
        var model = ReactionInputWithoutT2(order: .Zero)

        model.inputC1 = 1
        model.inputT1 = 15

        let expectedC2 = InputLimits(
            min: model.concentrationA!.getConcentration(at: maxTInput),
            max: maxCInput,
            smallerOtherValue: nil,
            largerOtherValue: 1
        )

        XCTAssertEqual(model.c2Limits, expectedC2)
    }

    func testZeroOrderReactionFixedC2Limits() {
        var model = ReactionInputWithoutC2(order: .Zero)
        model.inputC1 = 0.2
        model.inputT1 = 0

        let expectedT2 = InputLimits(
            min: minTInput,
            max: model.concentrationA!.time(for: minCInput)!,
            smallerOtherValue: 0,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.t2Limits, expectedT2)
    }

    func testFirstOrderReactionInputAllPropertiesLimits() {
        let model = ReactionInputAllProperties(order: .First)
        let expectedT2 = InputLimits(
            min: ReactionSettings.minT2Input,
            max: maxTInput,
            smallerOtherValue: nil,
            largerOtherValue: nil
        )
        XCTAssertEqual(model.t2Limits, expectedT2)
    }

    private let minCInput = ReactionSettings.minCInput
    private let maxCInput = ReactionSettings.maxCInput
    private let minC2Input = ReactionSettings.minC2Input
    private let minTInput = ReactionSettings.minTime
    private let maxTInput = ReactionSettings.maxTInput

}
