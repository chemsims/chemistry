//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationReactionDefinitionTests: XCTestCase {

    func testHClStrongAcidTitrationDefinition() {
        let acid = AcidOrBase.hydrogenChloride
        let reaction = acid.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HCl")
        XCTAssertEqual(reaction.leftTerms[1].name, "KOH")
        XCTAssertEqual(reaction.rightTerms[0].name, "KCl")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testHIStrongAcidTitrationDefinition() {
        let acid = AcidOrBase.hydrogenIodide
        let reaction = acid.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HI")
        XCTAssertEqual(reaction.leftTerms[1].name, "KOH")
        XCTAssertEqual(reaction.rightTerms[0].name, "KI")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testHBrStrongAcidTitrationDefinition() {
        let acid = AcidOrBase.hydrogenBromide
        let reaction = acid.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HBr")
        XCTAssertEqual(reaction.leftTerms[1].name, "KOH")
        XCTAssertEqual(reaction.rightTerms[0].name, "KBr")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testKOHStrongBaseTitrationDefinition() {
        let base = AcidOrBase.potassiumHydroxide
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "KOH")
        XCTAssertEqual(reaction.leftTerms[1].name, "HCl")
        XCTAssertEqual(reaction.rightTerms[0].name, "KCl")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testLiOHStrongBaseTitrationDefinition() {
        let base = AcidOrBase.lithiumHydroxide
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "LiOH")
        XCTAssertEqual(reaction.leftTerms[1].name, "HCl")
        XCTAssertEqual(reaction.rightTerms[0].name, "LiCl")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testNaOHStrongBaseTitrationDefinition() {
        let base = AcidOrBase.sodiumHydroxide
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "NaOH")
        XCTAssertEqual(reaction.leftTerms[1].name, "HCl")
        XCTAssertEqual(reaction.rightTerms[0].name, "NaCl")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testHAWeakAcidTitrationDefinition() {
        let base = AcidOrBase.weakAcidHA
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HA")
        XCTAssertEqual(reaction.leftTerms[1].name, "OH")
        XCTAssertEqual(reaction.rightTerms[0].name, "KA")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testHFWeakAcidTitrationDefinition() {
        let base = AcidOrBase.weakAcidHF
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HF")
        XCTAssertEqual(reaction.leftTerms[1].name, "OH")
        XCTAssertEqual(reaction.rightTerms[0].name, "KF")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testHCNWeakAcidTitrationDefinition() {
        let base = AcidOrBase.hydrogenCyanide
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HCN")
        XCTAssertEqual(reaction.leftTerms[1].name, "OH")
        XCTAssertEqual(reaction.rightTerms[0].name, "KCN")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testBWeakBaseTitrationDefinition() {
        let base = AcidOrBase.weakBaseB
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "B^-^")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_3_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "HB")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testFWeakBaseTitrationDefinition() {
        let base = AcidOrBase.weakBaseF
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "F^-^")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_3_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "HF")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

    func testHSWeakBaseTitrationDefinition() {
        let base = AcidOrBase.weakBaseHS
        let reaction = base.titrationReactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HS^-^")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_3_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "H_2_S")
        XCTAssertEqual(reaction.rightTerms[1].name, "H_2_O")
    }

}
