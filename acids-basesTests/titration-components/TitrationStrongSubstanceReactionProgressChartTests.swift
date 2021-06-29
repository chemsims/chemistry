//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationStrongSubstanceReactionProgressChartTests: XCTestCase {

    func testStrongAcidReactionProgressModel() {
        doTest(forSubstance: .strongAcids.first!)
    }

    func testStrongBaseReactionProgressModel() {
        doTest(forSubstance: .strongBases.first!)
    }

    private func doTest(
        forSubstance substance: AcidOrBase
    ) {
        let primaryIon = substance.primary
        let complementIon = primaryIon.complement

        let prepModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(maxInitialStrongConcentration: 0.5),
            maxReactionProgressMolecules: 50
        )
        func count(ofIon ion: PrimaryIon) -> Int {
            prepModel.reactionModel.moleculeCounts(ofType: ion)
        }
        var primaryIonCount: Int { count(ofIon: primaryIon) }
        var complementIonCount: Int { count(ofIon: complementIon) }

        XCTAssertEqual(primaryIonCount, 0)
        XCTAssertEqual(complementIonCount, 0)

        prepModel.incrementSubstance(count: prepModel.maxSubstance / 2)

        XCTAssertEqual(primaryIonCount, 25)
        XCTAssertEqual(complementIonCount, 0)

        prepModel.incrementSubstance(count: prepModel.maxSubstance / 2)
        XCTAssertEqual(primaryIonCount, 50)
        XCTAssertEqual(complementIonCount, 0)
    }
}
