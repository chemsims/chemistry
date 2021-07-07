//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationWeakSubstanceReactionProgressChartTests: XCTestCase {

    func testWeakAcidReactionProgress() {
        doTestMoleculeCounts(substance: .weakAcids.first!)
        doTestMoleculeCountsAtMaxBufferCapacity(substance: .weakAcids.first!)
    }

    func testWeakBaseReactionProgress() {
        doTestMoleculeCounts(substance: .weakBases.first!)
        doTestMoleculeCountsAtMaxBufferCapacity(substance: .weakBases.first!)
    }

    private func doTestMoleculeCounts(substance: AcidOrBase) {
        let prepModel = TitrationWeakSubstancePreparationModel(
            substance: substance,
            maxReactionProgressMolecules: 50
        )

        XCTAssertEqual(prepModel.primaryIonCount, 0)
        XCTAssertEqual(prepModel.complementIonCount, 0)

        // We must have an even number of molecules at all times
        prepModel.incrementSubstance(count: 1)
        print("Ion count is: \(prepModel.substanceIonCount)")
        while(prepModel.canAddSubstance) {
            prepModel.incrementSubstance(count: 1)
            XCTAssertEqual(prepModel.substanceIonCount % 2, 0, "Substance added: \(prepModel.substanceAdded)")
        }

        XCTAssertEqual(prepModel.substanceIonCount, 50)
        XCTAssertEqual(prepModel.secondaryIonCount, 0)
        XCTAssertEqual(prepModel.primaryIonCount, 0)
        XCTAssertEqual(prepModel.complementIonCount, 0)

        let preEPModel = TitrationWeakSubstancePreEPModel(previous: prepModel)
        XCTAssertEqual(preEPModel.substanceIonCount, 50)
        XCTAssertEqual(preEPModel.secondaryIonCount, 0)
        XCTAssertEqual(preEPModel.primaryIonCount, 0)
        XCTAssertEqual(preEPModel.complementIonCount, 0)

        preEPModel.titrantLimit = .equivalencePoint
        preEPModel.incrementTitrant(count: preEPModel.maxTitrant)
        XCTAssertEqual(preEPModel.substanceIonCount, 0)
        XCTAssertEqual(preEPModel.secondaryIonCount, 50)
        XCTAssertEqual(preEPModel.primaryIonCount, 0)
        XCTAssertEqual(preEPModel.complementIonCount, 0)

        let postEPModel = TitrationWeakSubstancePostEPModel(previous: preEPModel)
        XCTAssertEqual(postEPModel.substanceIonCount, 0)
        XCTAssertEqual(postEPModel.secondaryIonCount, 50)
        XCTAssertEqual(postEPModel.primaryIonCount, 0)
        XCTAssertEqual(postEPModel.complementIonCount, 0)

        postEPModel.incrementTitrant(count: postEPModel.maxTitrant)
        XCTAssertEqual(postEPModel.substanceIonCount, 0)
        XCTAssertEqual(postEPModel.secondaryIonCount, 50)
        XCTAssertEqual(postEPModel.primaryIonCount, 0)
        XCTAssertEqual(postEPModel.complementIonCount, 50)
    }

    private func doTestMoleculeCountsAtMaxBufferCapacity(substance: AcidOrBase) {
        let prepModel = TitrationWeakSubstancePreparationModel(substance: substance)
        prepModel.incrementSubstance(count: prepModel.maxSubstance)

        let preEPModel = TitrationWeakSubstancePreEPModel(previous: prepModel)

        let initialCount = preEPModel.substanceIonCount
        XCTAssertEqual(initialCount % 2, 0)
        let expectedMidCount = initialCount / 2

        preEPModel.incrementTitrant(count: preEPModel.titrantAtMaxBufferCapacity)

        XCTAssertEqual(preEPModel.substanceIonCount, expectedMidCount)
        XCTAssertEqual(preEPModel.secondaryIonCount, expectedMidCount)
    }

    private func doTestResettingMaxBufferCapacityMolecules(substance: AcidOrBase) {
        let prepModel = TitrationWeakSubstancePreparationModel(substance: substance)
        prepModel.incrementSubstance(count: prepModel.maxSubstance)

        let preEPModel = TitrationWeakSubstancePreEPModel(previous: prepModel)

        let initialCount = preEPModel.substanceIonCount


        preEPModel.titrantLimit = .equivalencePoint
        preEPModel.incrementTitrant(count: preEPModel.maxTitrant)

        XCTAssertEqual(preEPModel.secondaryIonCount, initialCount)
        XCTAssertEqual(preEPModel.substanceIonCount, 0)

        preEPModel.resetReactionProgressToMaxBufferCapacity()

        let expectedMidCount = initialCount / 2
        XCTAssertEqual(preEPModel.secondaryIonCount, expectedMidCount)
        XCTAssertEqual(preEPModel.substanceIonCount, expectedMidCount)

        // 127,713.96
    }
}

private extension TitrationWeakSubstancePreparationModel {
    var primaryIonCount: Int {
        count(ofPart: substance.primary.extendedSubstancePart)
    }

    var complementIonCount: Int {
        count(ofPart: substance.primary.complement.extendedSubstancePart)
    }

    var substanceIonCount: Int {
        count(ofPart: .substance)
    }

    var secondaryIonCount: Int {
        count(ofPart: .secondaryIon)
    }

    func count(ofPart part: ExtendedSubstancePart) -> Int {
        reactionProgressModel.moleculeCounts(ofType: part)
    }
}

private extension TitrationWeakSubstancePreEPModel {
    var primaryIonCount: Int {
        count(ofPart: substance.primary.extendedSubstancePart)
    }

    var complementIonCount: Int {
        count(ofPart: substance.primary.complement.extendedSubstancePart)
    }

    var substanceIonCount: Int {
        count(ofPart: .substance)
    }

    var secondaryIonCount: Int {
        count(ofPart: .secondaryIon)
    }

    func count(ofPart part: ExtendedSubstancePart) -> Int {
        reactionProgress.moleculeCounts(ofType: part)
    }
}

private extension TitrationWeakSubstancePostEPModel {
    var primaryIonCount: Int {
        count(ofPart: substance.primary.extendedSubstancePart)
    }

    var complementIonCount: Int {
        count(ofPart: substance.primary.complement.extendedSubstancePart)
    }

    var substanceIonCount: Int {
        count(ofPart: .substance)
    }

    var secondaryIonCount: Int {
        count(ofPart: .secondaryIon)
    }

    func count(ofPart part: ExtendedSubstancePart) -> Int {
        reactionProgress.moleculeCounts(ofType: part)
    }
}
