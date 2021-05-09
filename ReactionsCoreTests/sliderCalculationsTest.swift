//
// Reactions App
//

import XCTest
import ReactionsCore

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

    func testUpdatingTheMinimumPosition() {
        let model = AxisPositionCalculations(minValuePosition: 10, maxValuePosition: 110, minValue: 100, maxValue: 200)

        let updatedModel = model.updateMin(position: 60)
        XCTAssertEqual(updatedModel.minValuePosition, 60)
        XCTAssertEqual(updatedModel.minValue, 150)
        XCTAssertEqual(updatedModel.maxValue, 200)
        XCTAssertEqual(updatedModel.maxValuePosition, 110)

        let updatedModel2 = model.updateMin(position: 100)
        XCTAssertEqual(updatedModel2.minValuePosition, 100)
        XCTAssertEqual(updatedModel2.minValue, 190)
        XCTAssertEqual(updatedModel2.maxValue, 200)
        XCTAssertEqual(updatedModel2.maxValuePosition, 110)

        let updatedModel3 = model.updateMin(position: -90)
        XCTAssertEqual(updatedModel3.minValuePosition, -90)
        XCTAssertEqual(updatedModel3.minValue, 0)
        XCTAssertEqual(updatedModel3.maxValue, 200)
        XCTAssertEqual(updatedModel3.maxValuePosition, 110)
    }

    func testUpdatingTheMinimumValue() {
        let model = AxisPositionCalculations(minValuePosition: -20, maxValuePosition: 20, minValue: -100, maxValue: 100)

        let updatedModel = model.updateMin(value: 0)
        XCTAssertEqual(updatedModel.minValuePosition, 0)
        XCTAssertEqual(updatedModel.minValue, 0)
        XCTAssertEqual(updatedModel.maxValue, 100)
        XCTAssertEqual(updatedModel.maxValuePosition, 20)

        let updatedModel2 = model.updateMin(value: 50)
        XCTAssertEqual(updatedModel2.minValuePosition, 10)
        XCTAssertEqual(updatedModel2.minValue, 50)
        XCTAssertEqual(updatedModel2.maxValue, 100)
        XCTAssertEqual(updatedModel2.maxValuePosition, 20)
    }

    func testUpdatingTheMaximumPosition() {
        let model = AxisPositionCalculations(minValuePosition: 0, maxValuePosition: 100, minValue: 100, maxValue: 400)

        let updatedModel = model.updateMax(position: 50)
        XCTAssertEqual(updatedModel.minValuePosition, 0)
        XCTAssertEqual(updatedModel.minValue, 100)
        XCTAssertEqual(updatedModel.maxValue, 250)
        XCTAssertEqual(updatedModel.maxValuePosition, 50)

        let updatedModel2 = model.updateMax(position: 75)
        XCTAssertEqual(updatedModel2.minValuePosition, 0)
        XCTAssertEqual(updatedModel2.minValue, 100)
        XCTAssertEqual(updatedModel2.maxValue, 325)
        XCTAssertEqual(updatedModel2.maxValuePosition, 75)
    }

    func testUpdatingTheMaximumValue() {
        let model = AxisPositionCalculations(minValuePosition: 20, maxValuePosition: 30, minValue: 200, maxValue: 400)

        let updatedModel = model.updateMax(value: 300)
        XCTAssertEqual(updatedModel.minValuePosition, 20)
        XCTAssertEqual(updatedModel.minValue, 200)
        XCTAssertEqual(updatedModel.maxValue, 300)
        XCTAssertEqual(updatedModel.maxValuePosition, 25)

        let updatedModel2 = model.updateMax(value: 600)
        XCTAssertEqual(updatedModel2.minValuePosition, 20)
        XCTAssertEqual(updatedModel2.minValue, 200)
        XCTAssertEqual(updatedModel2.maxValue, 600)
        XCTAssertEqual(updatedModel2.maxValuePosition, 40)
    }

    func testGettingValueForDistance() {
        let model1 = AxisPositionCalculations(minValuePosition: 10, maxValuePosition: 20, minValue: 0, maxValue: 10)
        XCTAssertEqual(model1.valueForDistance(5), 5)

        let model2 = AxisPositionCalculations(minValuePosition: 10, maxValuePosition: 30, minValue: 0, maxValue: 10)
        XCTAssertEqual(model2.valueForDistance(10), 5)

        let model3 = AxisPositionCalculations(minValuePosition: 50, maxValuePosition: 0, minValue: 0, maxValue: 25)
        XCTAssertEqual(model3.valueForDistance(10), 5)
    }

    // Tests that getting the value returned for the given position is correct, and vice versa.
    private func testSlider(handlePosition: Double, value: Double, model: AxisPositionCalculations<Double>) {
        XCTAssertEqual(value, model.getValue(at: handlePosition), accuracy: 0.00001)
        XCTAssertEqual(handlePosition, model.getPosition(at: value), accuracy: 0.00001)
    }
}
