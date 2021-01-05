//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class TextLineGeneratorTests: XCTestCase {

    func testMakingSimpleLine() {
        let content = generate("Hello, world")
        XCTAssertEqual(content, [segment("Hello, world")])
    }

    func testMakingLineWithEmphasis() {
        let content = generate("*Hello, world*")
        XCTAssertEqual(content, [segment("Hello, world", emphasis: true)])
    }

    func testMakingAMixOfLines() {
        let content1 = generate("*Hello*, world")
        XCTAssertEqual(content1, [segment("Hello", emphasis: true), segment(", world")])

        let content2 = generate("Hello,* world*")
        XCTAssertEqual(content2, [segment("Hello,"), segment(" world", emphasis: true)])

        let content3 = generate("*Hello*, this *is* a t*est*")
        let expected3 = [
            segment("Hello", emphasis: true),
            segment(", this "),
            segment("is", emphasis: true),
            segment(" a t"),
            segment("est", emphasis: true)
        ]
        XCTAssertEqual(content3, expected3)
    }

    func testSubscripts() {
        let content1 = generate("Hello_world_")
        XCTAssertEqual(
            content1,
            [segment("Hello"), segment("world", scriptType: .subScript)]
        )

        let content2 = generate("A_0_")
        XCTAssertEqual(content2, [segment("A"), segment("0", scriptType: .subScript)])

        let content3 = generate("*A_0_*")
        XCTAssertEqual(content3, [segment("A", emphasis: true), segment("0", emphasis: true, scriptType: .subScript)])

        let content4 = generate("*A_0_* foo")
        XCTAssertEqual(
            content4,
            [segment("A", emphasis: true), segment("0", emphasis: true, scriptType: .subScript), segment(" foo")]
        )

        let content5 = generate("*A_0_ foo*")
        XCTAssertEqual(
            content5,
            [segment("A", emphasis: true), segment("0", emphasis: true, scriptType: .subScript), segment(" foo", emphasis: true)]
        )

        let content6 = generate("*A_t_*=*A^0^*")
        XCTAssertEqual(
            content6,
            [
                segment("A", emphasis: true),
                segment("t", emphasis: true, scriptType: .subScript),
                segment("="),
                segment("A", emphasis: true),
                segment("0", emphasis: true, scriptType: .superScript)
            ]
        )
    }

    func testStringsWithNoBreaks() {
        let content1 = generate("$A = B + C$")
        XCTAssertEqual(content1, [segment("A = B + C", allowBreaks: false)])

        let content2 = generate("The equation is $*A = B + C*$")
        XCTAssertEqual(
            content2,
            [
                segment("The equation is "),
                segment("A = B + C", emphasis: true, allowBreaks: false)
            ]
        )

        let content3         = generate("The equation $*t_1/2_ = ln(2) / k*$ gives the half life")
        let content3Variant1 = generate("The equation *$t_1/2_ = ln(2) / k$* gives the half life")
        let content3Variant2 = generate("The equation *$t_1/2_ = ln(2) / k*$ gives the half life")
        let expected3 = [
            segment("The equation "),
            segment("t", emphasis: true, allowBreaks: false),
            segment("1/2", emphasis: true, scriptType: .subScript, allowBreaks: false),
            segment(" = ln(2) / k", emphasis: true, allowBreaks: false),
            segment(" gives the half life")
        ]

        XCTAssertEqual(content3, expected3)
        XCTAssertEqual(content3Variant1, expected3)
        XCTAssertEqual(content3Variant2, expected3)
    }

    func testEscapingAControlCharacter() {
        let content = generate("A \\* B")
        XCTAssertEqual(content, [segment("A * B")])
    }

    private func segment(_ str: String, emphasis: Bool = false, scriptType: ScriptType? = nil, allowBreaks: Bool = true) -> TextSegment {
        TextSegment(content: str, emphasised: emphasis, scriptType: scriptType, allowBreaks: allowBreaks)
    }

    private func generate(_ str: String) -> [TextSegment] {
        TextLineGenerator.makeLine(str).content
    }
    
}
