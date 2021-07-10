//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class AcidOrBaseTests: XCTestCase {
    
    func testSymbolNamesForStrongAcid() {
        let acid = AcidOrBase.strongAcid(secondaryIon: .Cl, color: .red, kA: 1)

        XCTAssertEqual(acid.charged(.substance), .init(symbol: "HCl", charge: nil))
        XCTAssertEqual(acid.charged(.primaryIon), .init(symbol: "H", charge: .positive))
        XCTAssertEqual(acid.charged(.secondaryIon), .init(symbol: "Cl", charge: .negative))
    }

    func testSymbolNamesForStrongBase() {
        let base = AcidOrBase.strongBase(secondaryIon: .K, color: .red, kB: 1)
        XCTAssertEqual(base.charged(.substance), .init(symbol: "KOH", charge: nil))
        XCTAssertEqual(base.charged(.primaryIon), .init(symbol: "OH", charge: .negative))
        XCTAssertEqual(base.charged(.secondaryIon), .init(symbol: "K", charge: .positive))
    }

    func testSymbolNamesForWeakAcid() {
        let acid = AcidOrBase.weakAcid(secondaryIon: .A, substanceAddedPerIon: NonZeroPositiveInt(1)!, color: .red, kA: 1)
        XCTAssertEqual(acid.charged(.substance), .init(symbol: "HA", charge: nil))
        XCTAssertEqual(acid.charged(.primaryIon), .init(symbol: "H", charge: .positive))
        XCTAssertEqual(acid.charged(.secondaryIon), .init(symbol: "A", charge: .negative))
    }

    func testSymbolNamesForWeakBase() {
        let base = AcidOrBase.weakBase(secondaryIon: .B, substanceAddedPerIon: NonZeroPositiveInt(1)!, color: .red, kB: 1)
        XCTAssertEqual(base.charged(.substance), .init(symbol: "B", charge: .negative))
        XCTAssertEqual(base.charged(.primaryIon), .init(symbol: "OH", charge: .negative))
        XCTAssertEqual(base.charged(.secondaryIon), .init(symbol: "BH", charge: nil))
    }

    func testSymbolNamesForWeakBaseProducingDoubleHydrogen() {
        let base = AcidOrBase.weakBaseHS
        XCTAssertEqual(base.charged(.substance), .init(symbol: "HS", charge: .negative))
        XCTAssertEqual(base.charged(.secondaryIon), .init(symbol: "H_2_S", charge: nil))
    }
}

private extension AcidOrBase {
    func charged(_ part: SubstancePart) -> ChargedSymbol {
        chargedSymbol(ofPart: part)
    }
}
