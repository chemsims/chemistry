//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class CsvParserTests: XCTestCase {

    func testParsingSimpleCsvContent() {
        let content = """
        A,B,C
        1,2,3,4
        """
        let expected = [
            ["A", "B", "C"],
            ["1", "2", "3", "4"]
        ]
        XCTAssertEqual(parse(content), expected)
    }

    func testParsingAQuotedCells() {
        let content = """
        A,B,C
        "Hello, world"
        """
        let expected = [
            ["A", "B", "C"],
            ["Hello, world"]
        ]
        XCTAssertEqual(parse(content), expected)
    }

    func testParsingMultipleQuotesInACell() {
        let content = """
        "Hello, ""world""\","these ""are""\",quotes
        """
        let expected = [[
            "Hello, \"world\"", "these \"are\"", "quotes"
        ]]

        XCTAssertEqual(parse(content), expected)
    }

    func testMultipleLinesInACell() {
        let content = """
        A,"B
        C",D
        1,2,3,4
        """
        let expected = [
            ["A", "B\nC", "D"],
            ["1", "2", "3", "4"]
        ]
        XCTAssertEqual(parse(content), expected)
    }

    func testAFinalCommaIsNotIncluded() {
        let content = """
        A,B,C,D
        1,,,
        """
        let expected = [
            ["A", "B", "C", "D"],
            ["1", "", "", ""]
        ]
        XCTAssertEqual(parse(content), expected)
    }


    private func parse(_ content: String) -> [[String]] {
        CsvParser.parse(content: content)
    }

}
