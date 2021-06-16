//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class AcidOrBaseTests: XCTestCase {
    func testSymbolNamesForStrongAcid() {
        let acid = AcidOrBase.strongAcid(secondaryIon: .A, color: .red, kA: 1)
        XCTAssertEqual(acid.symbol(ofPart: .substance), "HA")
        XCTAssertEqual(acid.symbol(ofPart: .primaryIon), "H")
        XCTAssertEqual(acid.symbol(ofPart: .secondaryIon), "A")
    }

    func testSymbolNamesForStrongBase() {
        let base = AcidOrBase.strongBase(secondaryIon: .K, color: .red, kB: 1)
        XCTAssertEqual(base.symbol(ofPart: .substance), "KOH")
        XCTAssertEqual(base.symbol(ofPart: .primaryIon), "OH")
        XCTAssertEqual(base.symbol(ofPart: .secondaryIon), "K")
    }

    func testSymbolNamesForWeakAcid() {
        let acid = AcidOrBase.weakAcid(secondaryIon: .A, substanceAddedPerIon: NonZeroPositiveInt(1)!, color: .red, kA: 1)
        XCTAssertEqual(acid.symbol(ofPart: .substance), "HA")
        XCTAssertEqual(acid.symbol(ofPart: .primaryIon), "H")
        XCTAssertEqual(acid.symbol(ofPart: .secondaryIon), "A")
    }

    func testSymbolNamesForWeakBase() {
        let base = AcidOrBase.weakBase(secondaryIon: .B, substanceAddedPerIon: NonZeroPositiveInt(1)!, color: .red, kB: 1)
        XCTAssertEqual(base.symbol(ofPart: .substance), "B")
        XCTAssertEqual(base.symbol(ofPart: .primaryIon), "OH")
        XCTAssertEqual(base.symbol(ofPart: .secondaryIon), "BH")
    }
}
