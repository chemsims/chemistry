//
// Reactions App
//


import XCTest

/// Asserts two values are equal, within a tolerance percentage of the `expected` value
/// - Parameters:
///   - tolerancePercent: A percentage of the expected to allow as tolerance. Defaults to 0.01%
func XCTAssertEqualWithTolerance<T : BinaryFloatingPoint>(
    _ value: T,
    _ expected: T,
    _ message: @autoclosure () -> String = { "" }(),
    tolerancePercent: T = 0.01,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    precondition(tolerancePercent >= 0, "Tolerance must be at least zero")
    let accuracy = (tolerancePercent / 100) * expected
    XCTAssertEqual(value, expected, accuracy: accuracy, message(), file: file, line: line)
}

func XCTAssertArraysContainTheSameElements<Element : Equatable>(
    _ left: [Element],
    _ right: [Element],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(left.count, right.count)
    left.forEach { leftElement in
        XCTAssertArrayContainsElement(right, leftElement)
    }
    right.forEach { rightElement in
        XCTAssertArrayContainsElement(left, rightElement)
    }
}

func XCTAssertArrayContainsElement<Element: Equatable>(
    _ array: [Element],
    _ element: Element,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssert(array.contains(element), "\(array) did not contain \(element)")
}
