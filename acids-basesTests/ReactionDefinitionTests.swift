//
// Reactions App
//

import XCTest
@testable import acids_bases

class ReactionDefinitionTests: XCTestCase {
    func testHClStrongAcidReactionDefinition() {
        let acid = AcidOrBase.hydrogenChloride
        let reaction = acid.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 1)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HCl")
        XCTAssertEqual(reaction.rightTerms[0].name, "H^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "Cl^-^")
    }

    func testHIStrongAcidReactionDefinition() {
        let acid = AcidOrBase.hydrogenIodide
        let reaction = acid.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 1)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HI")
        XCTAssertEqual(reaction.rightTerms[0].name, "H^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "I^-^")
    }

    func testHBrStrongAcidReactionDefinition() {
        let acid = AcidOrBase.hydrogenBromide
        let reaction = acid.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 1)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HBr")
        XCTAssertEqual(reaction.rightTerms[0].name, "H^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "Br^-^")
    }

    func testKOHStrongBaseReactionDefinition() {
        let base = AcidOrBase.potassiumHydroxide
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 1)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "KOH")
        XCTAssertEqual(reaction.rightTerms[0].name, "K^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "OH^-^")
    }

    func testLiOHStrongBaseReactionDefinition() {
        let base = AcidOrBase.lithiumHydroxide
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 1)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "LiOH")
        XCTAssertEqual(reaction.rightTerms[0].name, "Li^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "OH^-^")
    }

    func testNaOHStrongBaseReactionDefinition() {
        let base = AcidOrBase.sodiumHydroxide
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 1)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "NaOH")
        XCTAssertEqual(reaction.rightTerms[0].name, "Na^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "OH^-^")
    }

    func testHAWeakAcidReactionDefinition() {
        let base = AcidOrBase.weakAcidHA
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HA")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_2_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "H_3_O^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "A^-^")
    }

    func testHFWeakAcidReactionDefinition() {
        let base = AcidOrBase.weakAcidHF
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HF")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_2_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "H_3_O^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "F^-^")
    }

    func testHCNWeakAcidReactionDefinition() {
        let base = AcidOrBase.hydrogenCyanide
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HCN")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_2_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "H_3_O^+^")
        XCTAssertEqual(reaction.rightTerms[1].name, "CN^-^")
    }

    func testBWeakBaseReactionDefinition() {
        let base = AcidOrBase.weakBaseB
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "B^-^")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_2_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "HB")
        XCTAssertEqual(reaction.rightTerms[1].name, "OH^-^")
    }

    func testFWeakBaseReactionDefinition() {
        let base = AcidOrBase.weakBaseF
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "F^-^")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_2_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "HF")
        XCTAssertEqual(reaction.rightTerms[1].name, "OH^-^")
    }

    func testHSWeakBaseReactionDefinition() {
        let base = AcidOrBase.weakBaseHS
        let reaction = base.reactionDefinition

        XCTAssertEqual(reaction.leftTerms.count, 2)
        XCTAssertEqual(reaction.rightTerms.count, 2)

        XCTAssertEqual(reaction.leftTerms[0].name, "HS^-^")
        XCTAssertEqual(reaction.leftTerms[1].name, "H_2_O")
        XCTAssertEqual(reaction.rightTerms[0].name, "H_2_S")
        XCTAssertEqual(reaction.rightTerms[1].name, "OH^-^")
    }
}
