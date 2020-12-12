//
// Reactions App
//

import XCTest
@testable import reactions_app

class BoundedSliderPositioningTest: XCTestCase {

    func testAbsoluteBounds() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: 0, maxValuePosition: 10, minValue: 10, maxValue: 30)
        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: 15,
            absoluteMax: 25,
            minPreSpacing: nil,
            maxPreSpacing: nil,
            spacing: 0
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 15)
        XCTAssertEqual(updatedAxis.maxValue, 25)
        XCTAssertEqual(updatedAxis.minValuePosition, 2.5)
        XCTAssertEqual(updatedAxis.maxValuePosition, 7.5)
    }

    func testAddingMinSpacing1() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: 0, maxValuePosition: 50, minValue: 0, maxValue: 100)

        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: 50,
            maxPreSpacing: nil,
            spacing: 5
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 60)
        XCTAssertEqual(updatedAxis.maxValue, 100)
        XCTAssertEqual(updatedAxis.minValuePosition, 30)
        XCTAssertEqual(updatedAxis.maxValuePosition, 50)
    }

    func testAddingMinSpacing1Reverse() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: 50, maxValuePosition: 0, minValue: 0, maxValue: 100)

        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: 50,
            maxPreSpacing: nil,
            spacing: 5
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 60)
        XCTAssertEqual(updatedAxis.maxValue, 100)
        XCTAssertEqual(updatedAxis.minValuePosition, 20)
        XCTAssertEqual(updatedAxis.maxValuePosition, 0)
    }

    func testAddingMinSpacing2() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: -50, maxValuePosition: 0, minValue: 100, maxValue: 200)
        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: 120,
            maxPreSpacing: nil,
            spacing: 10
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 140)
        XCTAssertEqual(updatedAxis.maxValue, 200)
        XCTAssertEqual(updatedAxis.minValuePosition, -30)
        XCTAssertEqual(updatedAxis.maxValuePosition, 0)
    }

    func testAddingMaxSpacing1() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: 50, maxValuePosition: 250, minValue: 0, maxValue: 100)
        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: nil,
            maxPreSpacing: 50,
            spacing: 20
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 0)
        XCTAssertEqual(updatedAxis.maxValue, 40)
        XCTAssertEqual(updatedAxis.minValuePosition, 50)
        XCTAssertEqual(updatedAxis.maxValuePosition, 130)
    }

    func testAddingMaxSpacing1Reverse() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: 250, maxValuePosition: 50, minValue: 0, maxValue: 100)
        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: nil,
            maxPreSpacing: 50,
            spacing: 20
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 0)
        XCTAssertEqual(updatedAxis.maxValue, 40)
        XCTAssertEqual(updatedAxis.minValuePosition, 250)
        XCTAssertEqual(updatedAxis.maxValuePosition, 170)
    }

    func testAddingMaxSpacing2() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: -100, maxValuePosition: -50, minValue: -200, maxValue: -100)

        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: nil,
            maxPreSpacing: -120,
            spacing: 10
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, -200)
        XCTAssertEqual(updatedAxis.maxValue, -140)
        XCTAssertEqual(updatedAxis.minValuePosition, -100)
        XCTAssertEqual(updatedAxis.maxValuePosition, -70)
    }

    func testSpacingWithAbosluteBounds() {
        let axis = AxisPositionCalculations<CGFloat>(minValuePosition: 0, maxValuePosition: 10, minValue: 0, maxValue: 10)
        let model = BoundedSliderPositioning(
            axis: axis,
            absoluteMin: 5,
            absoluteMax: 7,
            minPreSpacing: 2,
            maxPreSpacing: 10,
            spacing: 1
        )

        let updatedAxis = model.boundedAxis
        XCTAssertEqual(updatedAxis.minValue, 5)
        XCTAssertEqual(updatedAxis.maxValue, 7)
    }
}
