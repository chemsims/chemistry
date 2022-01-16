//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ReactionRates

class LimitConstraintsTests: XCTestCase {

    func testAbsoluteBounds() {
        let axis = makeAxis(minPos: 0, maxPos: 10, minValue: 10, maxValue: 30)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 15, max: 25, smallerOtherValue: nil, largerOtherValue: nil),
            axis: axis,
            spacing: 0
        )
        XCTAssertEqual(updatedAxis.minValue, 15)
        XCTAssertEqual(updatedAxis.maxValue, 25)
        XCTAssertEqual(updatedAxis.minValuePosition, 2.5)
        XCTAssertEqual(updatedAxis.maxValuePosition, 7.5)
    }

    func testAddingMinSpacing1() {
        let axis = makeAxis(minPos: 0, maxPos: 50, minValue: 0, maxValue: 100)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 0, max: 100, smallerOtherValue: 50, largerOtherValue: nil),
            axis: axis,
            spacing: 5
        )

        XCTAssertEqual(updatedAxis.minValue, 60)
        XCTAssertEqual(updatedAxis.maxValue, 100)
        XCTAssertEqual(updatedAxis.minValuePosition, 30)
        XCTAssertEqual(updatedAxis.maxValuePosition, 50)
    }

    func testAddingMinSpacing1Reverse() {
        let axis = makeAxis(minPos: 50, maxPos: 0, minValue: 0, maxValue: 100)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 0, max: 100, smallerOtherValue: 50, largerOtherValue: nil),
            axis: axis,
            spacing: 5
        )

        XCTAssertEqual(updatedAxis.minValue, 60)
        XCTAssertEqual(updatedAxis.maxValue, 100)
        XCTAssertEqual(updatedAxis.minValuePosition, 20)
        XCTAssertEqual(updatedAxis.maxValuePosition, 0)
    }

    func testAddingMinSpacing2() {
        let axis = makeAxis(minPos: -50, maxPos: 0, minValue: 100, maxValue: 200)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 100, max: 200, smallerOtherValue: 120, largerOtherValue: nil),
            axis: axis,
            spacing: 10
        )

        XCTAssertEqual(updatedAxis.minValue, 140)
        XCTAssertEqual(updatedAxis.maxValue, 200)
        XCTAssertEqual(updatedAxis.minValuePosition, -30)
        XCTAssertEqual(updatedAxis.maxValuePosition, 0)
    }

    func testAddingMaxSpacing1() {
        let axis = makeAxis(minPos: 50, maxPos: 250, minValue: 0, maxValue: 100)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 0, max: 100, smallerOtherValue: nil, largerOtherValue: 50),
            axis: axis,
            spacing: 20
        )

        XCTAssertEqual(updatedAxis.minValue, 0)
        XCTAssertEqual(updatedAxis.maxValue, 40)
        XCTAssertEqual(updatedAxis.minValuePosition, 50)
        XCTAssertEqual(updatedAxis.maxValuePosition, 130)
    }

    func testAddingMaxSpacing1Reverse() {
        let axis = makeAxis(minPos: 250, maxPos: 50, minValue: 0, maxValue: 100)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 0, max: 100, smallerOtherValue: nil, largerOtherValue: 50),
            axis: axis,
            spacing: 20
        )
        XCTAssertEqual(updatedAxis.minValue, 0)
        XCTAssertEqual(updatedAxis.maxValue, 40)
        XCTAssertEqual(updatedAxis.minValuePosition, 250)
        XCTAssertEqual(updatedAxis.maxValuePosition, 170)
    }

    func testAddingMaxSpacing2() {
        let axis = makeAxis(minPos: -100, maxPos: -50, minValue: -200, maxValue: -100)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: -200, max: -100, smallerOtherValue: nil, largerOtherValue: -120),
            axis: axis,
            spacing: 10
        )

        XCTAssertEqual(updatedAxis.minValue, -200)
        XCTAssertEqual(updatedAxis.maxValue, -140)
        XCTAssertEqual(updatedAxis.minValuePosition, -100)
        XCTAssertEqual(updatedAxis.maxValuePosition, -70)
    }

    func testSpacingWithAbsoluteBounds() {
        let axis = makeAxis(minPos: 0, maxPos: 10, minValue: 0, maxValue: 10)
        let updatedAxis = LimitConstraints.constrain(
            limit: InputLimits(min: 5, max: 7, smallerOtherValue: 2, largerOtherValue: 10),
            axis: axis,
            spacing: 1
        )

        XCTAssertEqual(updatedAxis.minValue, 5)
        XCTAssertEqual(updatedAxis.maxValue, 7)
    }

    private func makeAxis(
        minPos: CGFloat,
        maxPos: CGFloat,
        minValue: CGFloat,
        maxValue: CGFloat
    ) -> LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: minPos,
            maxValuePosition: maxPos,
            minValue: minValue,
            maxValue: maxValue
        )
    }
}
