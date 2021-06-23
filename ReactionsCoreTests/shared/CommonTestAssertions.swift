//
// Reactions App
//


import XCTest

/// Asserts two values are equal, within a tolerance percentage of the `expected` value
func XCTAssertEqualWithTolerance<T : BinaryFloatingPoint>(
    _ value: T,
    _ expected: T,
    tolerancePercent: T = 0.01,
    message: () -> String = { "" },
    file: StaticString = #filePath,
    line: UInt = #line
) {
    precondition(tolerancePercent >= 0, "Tolerance must be at least zero")
    let accuracy = (tolerancePercent / 100) * expected
    XCTAssertEqual(value, expected, accuracy: accuracy, file: file, line: line)
}
