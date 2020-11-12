//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class SpeechBubbleLineGeneratorTests: XCTestCase {

    func testMakingSimpleLine() {
        let content = generate("Hello, world")
        XCTAssertEqual(content, [segment("Hello, world", false)])
    }

    func testMakingLineWithEmphasis() {
        let content = generate("*Hello, world*")
        XCTAssertEqual(content, [segment("Hello, world", true)])
    }

    func testMakingAMixOfLines() {
        let content1 = generate("*Hello*, world")
        XCTAssertEqual(content1, [segment("Hello", true), segment(", world", false)])

        let content2 = generate("Hello,* world")
        XCTAssertEqual(content2, [segment("Hello,", false), segment(" world", true)])

        let content3 = generate("*Hello*, this *is* a t*est*")
        let expected3 = [
            segment("Hello", true),
            segment(", this ", false),
            segment("is", true),
            segment(" a t", false),
            segment("est", true)
        ]
        XCTAssertEqual(content3, expected3)
    }

    private func segment(_ str: String, _ emphasis: Bool) -> SpeechBubbleLineSegment {
        SpeechBubbleLineSegment(content: str, emphasised: emphasis)
    }

    private func generate(_ str: String) -> [SpeechBubbleLineSegment] {
        SpeechBubbleLineGenerator.makeLine(str: str).content
    }
    
}
