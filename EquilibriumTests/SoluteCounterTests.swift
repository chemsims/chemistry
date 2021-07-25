//
// Reactions App
//


import XCTest
@testable import Equilibrium

class SoluteCounterTests: XCTestCase {

    func testCounter() throws {
        var counter = SoluteCounter(maxAllowed: 5)

        func testCounterIsEmpty() {
            XCTAssertEqual(counter.count(of: .emitted), 0)
            XCTAssertEqual(counter.count(of: .enteredWater), 0)
            XCTAssertEqual(counter.count(of: .dissolved), 0)

            XCTAssertEqual(counter.fraction(of: .emitted), 0)
            XCTAssertEqual(counter.fraction(of: .enteredWater), 0)
            XCTAssertEqual(counter.fraction(of: .dissolved), 0)

            XCTAssert(counter.canPerform(action: .emitted))
            XCTAssert(counter.canPerform(action: .enteredWater))
            XCTAssert(counter.canPerform(action: .dissolved))
        }

        testCounterIsEmpty()

        counter.didPerform(action: .emitted)
        XCTAssertEqual(counter.count(of: .emitted), 1)
        XCTAssertEqual(counter.fraction(of: .emitted), 0.2)

        (0..<4).forEach { _ in counter.didPerform(action: .emitted) }

        func testEmittedIsAtMax() {
            XCTAssertEqual(counter.count(of: .emitted), 5)
            XCTAssertEqual(counter.fraction(of: .emitted), 1)
            XCTAssertFalse(counter.canPerform(action: .emitted))
        }

        testEmittedIsAtMax()

        counter.didPerform(action: .emitted)
        testEmittedIsAtMax()

        counter.reset()
        testCounterIsEmpty()
    }


    func testIncrementingAnActionAlsoEnsuresPreviousActionsAreAtTheSameLevel() {
        var counter = SoluteCounter(maxAllowed: 5)
        XCTAssertEqual(counter.count(of: .emitted), 0)
        XCTAssertEqual(counter.count(of: .enteredWater), 0)
        XCTAssertEqual(counter.count(of: .dissolved), 0)

        counter.didPerform(action: .dissolved)
        XCTAssertEqual(counter.count(of: .emitted), 1)
        XCTAssertEqual(counter.count(of: .enteredWater), 1)
        XCTAssertEqual(counter.count(of: .dissolved), 1)

        counter.didPerform(action: .enteredWater)
        XCTAssertEqual(counter.count(of: .emitted), 2)
        XCTAssertEqual(counter.count(of: .enteredWater), 2)
        XCTAssertEqual(counter.count(of: .dissolved), 1)

        counter.didPerform(action: .emitted)
        XCTAssertEqual(counter.count(of: .emitted), 3)
        XCTAssertEqual(counter.count(of: .enteredWater), 2)
        XCTAssertEqual(counter.count(of: .dissolved), 1)
    }


}
