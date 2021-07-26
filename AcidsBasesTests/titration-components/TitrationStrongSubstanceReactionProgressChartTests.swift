//
// Reactions App
//

import XCTest
@testable import AcidsBases

class TitrationStrongSubstanceReactionProgressChartTests: XCTestCase {

    func testStrongAcidReactionProgressModel() {
        doTestMoleculeCounts(forSubstance: .strongAcids.first!)
        doTestMoleculeCountsOfPreviousStatesAreMaintained(substance: .strongAcids.first!)
    }

    func testStrongBaseReactionProgressModel() {
        doTestMoleculeCounts(forSubstance: .strongBases.first!)
        doTestMoleculeCountsOfPreviousStatesAreMaintained(substance: .strongAcids.first!)
    }

    private func doTestMoleculeCounts(
        forSubstance substance: AcidOrBase
    ) {
        let prepModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(maxInitialStrongConcentration: 0.5),
            maxReactionProgressMolecules: 50
        )
        func count(ofIon ion: PrimaryIon) -> Int {
            prepModel.reactionProgress.moleculeCounts(ofType: ion)
        }

        XCTAssertEqual(prepModel.primaryIonCount, 0)
        XCTAssertEqual(prepModel.complementIonCount, 0)

        prepModel.incrementSubstance(count: prepModel.maxSubstance / 2)

        XCTAssertEqual(prepModel.primaryIonCount, 25)
        XCTAssertEqual(prepModel.complementIonCount, 0)

        prepModel.incrementSubstance(count: prepModel.maxSubstance / 2)
        XCTAssertEqual(prepModel.primaryIonCount, 50)
        XCTAssertEqual(prepModel.complementIonCount, 0)

        let preEPModel = TitrationStrongSubstancePreEPModel(previous: prepModel)
        XCTAssertEqual(preEPModel.primaryIonCount, 50)
        XCTAssertEqual(preEPModel.complementIonCount, 0)

        preEPModel.incrementTitrant(count: preEPModel.maxTitrant / 2)
        XCTAssertEqual(preEPModel.primaryIonCount, 25)
        XCTAssertEqual(preEPModel.complementIonCount, 0)

        preEPModel.incrementTitrant(count: preEPModel.maxTitrant / 2)
        XCTAssertEqual(preEPModel.primaryIonCount, 0)
        XCTAssertEqual(preEPModel.complementIonCount, 0)

        let postEPModel = TitrationStrongSubstancePostEPModel(previous: preEPModel)
        XCTAssertEqual(postEPModel.primaryIonCount, 0)
        XCTAssertEqual(postEPModel.complementIonCount, 0)

        postEPModel.incrementTitrant(count: postEPModel.maxTitrant / 2)
        XCTAssertEqual(postEPModel.primaryIonCount, 0)
        XCTAssertEqual(postEPModel.complementIonCount, 25)

        postEPModel.incrementTitrant(count: postEPModel.maxTitrant)
        XCTAssertEqual(postEPModel.primaryIonCount, 0)
        XCTAssertEqual(postEPModel.complementIonCount, 50)
    }

    private func doTestMoleculeCountsOfPreviousStatesAreMaintained(substance: AcidOrBase) {
        let prepModel = TitrationStrongSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(maxInitialStrongConcentration: 0.5),
            maxReactionProgressMolecules: 50
        )
        func count(ofIon ion: PrimaryIon) -> Int {
            prepModel.reactionProgress.moleculeCounts(ofType: ion)
        }

        prepModel.incrementSubstance(count: prepModel.maxSubstance)

        let preEPModel = TitrationStrongSubstancePreEPModel(previous: prepModel)

        XCTAssertEqual(prepModel.primaryIonCount, 50)
        XCTAssertEqual(prepModel.complementIonCount, 0)
        preEPModel.incrementTitrant(count: preEPModel.maxTitrant)
        XCTAssertEqual(prepModel.primaryIonCount, 50)
        XCTAssertEqual(prepModel.complementIonCount, 0)

        let postEPModel = TitrationStrongSubstancePostEPModel(previous: preEPModel)

        XCTAssertEqual(preEPModel.primaryIonCount, 0)
        XCTAssertEqual(preEPModel.complementIonCount, 0)
        postEPModel.incrementTitrant(count: postEPModel.maxTitrant)
        XCTAssertEqual(preEPModel.primaryIonCount, 0)
        XCTAssertEqual(preEPModel.complementIonCount, 0)
    }
}

private extension TitrationStrongSubstancePreparationModel {
    var primaryIonCount: Int {
        count(ofIon: substance.primary)
    }

    var complementIonCount: Int {
        count(ofIon: substance.primary.complement)
    }

    func count(ofIon ion: PrimaryIon) -> Int {
        reactionProgress.moleculeCounts(ofType: ion)
    }
}

private extension TitrationStrongSubstancePreEPModel {
    var primaryIonCount: Int {
        count(ofIon: substance.primary)
    }

    var complementIonCount: Int {
        count(ofIon: substance.primary.complement)
    }

    func count(ofIon ion: PrimaryIon) -> Int {
        reactionProgress.moleculeCounts(ofType: ion)
    }
}

private extension TitrationStrongSubstancePostEPModel {
    var primaryIonCount: Int {
        count(ofIon: substance.primary)
    }

    var complementIonCount: Int {
        count(ofIon: substance.primary.complement)
    }

    func count(ofIon ion: PrimaryIon) -> Int {
        reactionProgress.moleculeCounts(ofType: ion)
    }
}
