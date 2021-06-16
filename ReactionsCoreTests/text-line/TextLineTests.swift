//
// Reactions App
//

import XCTest
import ReactionsCore

class TextLineTests: XCTestCase {

    func testAsMarkdownProperty() {
        testMarkdown("Hello, world")
        testMarkdown("Hello^world^")
        testMarkdown("*Hello^world^*")
        testMarkdown("The equation $2^2^ = 4$ is *correct!*")
    }

    private func testMarkdown(
        _ string: String
    ) {
        let original = TextLine(string)
        let fromMarkdown = TextLine(original.asMarkdown)
        XCTAssertEqual(original, fromMarkdown)
    }
}
