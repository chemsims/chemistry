//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class LabellingTests: XCTestCase {

    func testSimpleLabels() {
        let string = "1 M/s = -[ΔA]/Δt"
        let expected = "1 M slash s = minus delta A divide by delta t"
        XCTAssertEqual(getLabel(string), expected)
    }

    func testUnitsAreNotReplacedWithDivideBy() {
        let cases = [
            ("M/s", "M slash s"),
            ("M/h", "M slash h")
        ]
        cases.forEach { c in
            XCTAssertEqual(getLabel(c.0), c.1, c.0)
        }
    }

    func testSquaredIsLabelled() {
        let string = "k[A]^2^"
        let expected = "K times 'A' squared"
        XCTAssertEqual(getLabel(string), expected)
    }

    func testSuperscript() {
        let string = "k[A]^n - 1^ plus 3"
        let expected = "K times 'A' to the power of n minus 1, plus 3"
        XCTAssertEqual(getLabel(string), expected)
    }

    func testHalfLife() {
        let string = "t_1/2_"
        let expected = "t one half"
        XCTAssertEqual(getLabel(string), expected)
    }

    private func getLabel(_ str: String) -> String {
        let labelled = Labelling.stringToLabel(str)

        // Replace consecutive whitespace with a single whitespace
        let regex = try! NSRegularExpression(pattern: "\\s+", options: [])
        let nsString = NSMutableString(string: labelled)
        let range = NSRange(location: 0, length: nsString.length)
        regex.replaceMatches(in: nsString, options: [], range: range, withTemplate: " ")
        return String(nsString)
    }

}
