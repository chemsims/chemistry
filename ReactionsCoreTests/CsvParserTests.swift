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

    func testPerformance() {
        let cols = 100
        let rows = 100

        func makeRow(_ row: Int) -> String {
            let cells = (1...cols).map { col in
                "\(row) \(col)"
            }
            return cells.dropFirst().reduce(cells.first!) {
                $0 + ",\($1)"
            }
        }

        let lines = (1...rows).map(makeRow)
        let allContent = lines.dropFirst().reduce(lines.first!) {
            $0 + "\n\($1)"
        }

        measure {
            let _ = parse(allContent)
        }
    }

    private func parse(_ content: String) -> [[String]] {
        CsvParser.parse(content: content)
    }
}
