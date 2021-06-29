//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationWeakSubstanceReactionProgressChartTests: XCTestCase {

    func testWeakAcidReactionProgress() {
        doTestMoleculeCounts(substance: .weakAcids.first!)
    }

    func testWeakBaseReactionProgress() {
        doTestMoleculeCounts(substance: .weakBases.first!)
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
