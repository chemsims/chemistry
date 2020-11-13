//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class AxisPositionCalculationsTests: XCTestCase {

    func testSimpleSliderPositionAtCenter() {
        let model1 = AxisPositionCalculations(minValuePosition: 0, maxValuePosition: 1, minValue: 0, maxValue: 1)
        testSlider(handlePosition: 0.5, value: 0.5, model: model1)

        let model2 = AxisPositionCalculations(minValuePosition: 1, maxValuePosition: 2, minValue: 0, maxValue: 1)
        testSlider(handlePosition: 1.5, value: 0.5, model: model2)

        let model3 = AxisPositionCalculations(minValuePosition: -1, maxValuePosition: 1, minValue: 0, maxValue: 1)
        testSlider(handlePosition: 0, value: 0.5, model: model3)
    }

    func testSliderPositionOffCenter() {
        let model1 = AxisPositionCalculations(minValuePosition: 0, maxValuePosition: 1, minValue: 0, maxValue: 1)
        testSlider(handlePosition: 0, value: 0, model: model1)
        testSlider(handlePosition: 0.2, value: 0.2, model: model1)
        testSlider(handlePosition: 1, value: 1, model: model1)

        testSlider(handlePosition: 0, value: 0, model: model1)
        testSlider(handlePosition: 0.2, value: 0.2, model: model1)
        testSlider(handlePosition: 1, value: 1, model: model1)

        let model2 = AxisPositionCalculations(minValuePosition: 1, maxValuePosition: 3, minValue: 0, maxValue: 1)
        testSlider(handlePosition: 1, value: 0, model: model2)
        testSlider(handlePosition: 1.4, value: 0.2, model: model2)
        testSlider(handlePosition: 3, value: 1, model: model2)

        let model3 = AxisPositionCalculations(minValuePosition: -1, maxValuePosition: 1, minValue: 0, maxValue: 1)
        testSlider(handlePosition: -1, value: 0, model: model3)
        testSlider(handlePosition: -0.6, value: 0.2, model: model3)
        testSlider(handlePosition: 1, value: 1, model: model3)
    }

    func testSliderPositionForReverseAxis() {
        let model = AxisPositionCalculations(minValuePosition: 1, maxValuePosition: 0, minValue: 0, maxValue: 1)
        testSlider(handlePosition: 0.5, value: 0.5, model: model)
        testSlider(handlePosition: 1, value: 0, model: model)
        testSlider(handlePosition: 0, value: 1, model: model)
    }

    func testSliderPositionForOffzeroValues() {
        let model = AxisPositionCalculations(minValuePosition: 10, maxValuePosition: 20, minValue: 100, maxValue: 200)
        testSlider(handlePosition: 10, value: 100, model: model)
    }

    func testSliderPositionForNegativeValues() {
        let model = AxisPositionCalculations(minValuePosition: 10, maxValuePosition: 20, minValue: -100, maxValue: -50)
        testSlider(handlePosition: 10, value: -100, model: model)
        testSlider(handlePosition: 20, value: -50, model: model)
        testSlider(handlePosition: 15, value: -75, model: model)
        testSlider(handlePosition: 12, value: -90, model: model)
    }

    // Tests that getting the value returned for the given position is correct, and vice versa.
    private func testSlider(handlePosition: Double, value: Double, model: AxisPositionCalculations<Double>) {
        XCTAssertEqual(value, model.getValue(at: handlePosition), accuracy: 0.00001)
        XCTAssertEqual(handlePosition, model.getPosition(at: value), accuracy: 0.00001)
    }
}
