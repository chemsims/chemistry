//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class AcidSubstanceBeakerCoordsTests: XCTestCase {

    func testStrongAcidCoords() {
        var model = AcidSubstanceBeakerCoords(substance: .strongAcid(name: "", secondaryIon: .A, color: .blue))
        var coords: SubstanceValue<[GridCoordinate]> {
            model.coords
        }

        model.coords.all.forEach { coords in
            XCTAssert(coords.isEmpty)
        }

        model.update(substanceCount: 10, cols: 10, rows: 10)

        XCTAssert(coords.substanceValue.isEmpty)
        let primaryIonFirstValue = coords.primaryIonValue
        let secondaryIonFirstValue = coords.secondaryIonValue
        checkCounts(primaryIonFirstValue, 10)
        checkCounts(secondaryIonFirstValue, 10)
        checkNoOverlap(coords)

        // Check no change when using same value
        model.update(substanceCount: 10, cols: 10, rows: 10)
        XCTAssert(coords.substanceValue.isEmpty)
        XCTAssertEqual(coords.primaryIonValue, primaryIonFirstValue)
        XCTAssertEqual(coords.secondaryIonValue, secondaryIonFirstValue)

        model.update(substanceCount: 50, cols: 10, rows: 10)
        XCTAssert(coords.substanceValue.isEmpty)
        checkCounts(coords.primaryIonValue, 50)
        checkCounts(coords.secondaryIonValue, 50)
        checkNoOverlap(coords)

        // Try adding too many
        model.update(substanceCount: 500, cols: 10, rows: 10)
        XCTAssert(coords.substanceValue.isEmpty)
        checkCounts(coords.primaryIonValue, 50)
        checkCounts(coords.secondaryIonValue, 50)
        checkNoOverlap(coords)
    }

    func testWeakAcidCoords() {
        var model = AcidSubstanceBeakerCoords(
            substance: .weakAcid(
                name: "",
                secondaryIon: .A,
                substanceAddedPerIon: NonZeroPositiveInt(5)!,
                color: .blue
            )
        )
        var coords: SubstanceValue<[GridCoordinate]> {
            model.coords
        }

        model.update(substanceCount: 4, cols: 10, rows: 10)
        checkCounts(coords.substanceValue, 4)
        checkCounts(coords.primaryIonValue, 0)
        checkCounts(coords.secondaryIonValue, 0)

        model.update(substanceCount: 5, cols: 10, rows: 10)
        checkCounts(coords.substanceValue, 5)
        checkCounts(coords.primaryIonValue, 1)
        checkCounts(coords.secondaryIonValue, 1)
        checkNoOverlap(coords)

        model.update(substanceCount: 6, cols: 10, rows: 10)
        checkCounts(coords.substanceValue, 6)
        checkCounts(coords.primaryIonValue, 1)
        checkCounts(coords.secondaryIonValue, 1)
        checkNoOverlap(coords)

        model.update(substanceCount: 20, cols: 10, rows: 10)
        checkCounts(coords.substanceValue, 20)
        checkCounts(coords.primaryIonValue, 4)
        checkCounts(coords.secondaryIonValue, 4)
        checkNoOverlap(coords)
    }

    private func checkNoOverlap(
        _ coords: SubstanceValue<[GridCoordinate]>
    ) {
        let flatList = coords.all.flatten
        let setOfCoords = Set(flatList)
        XCTAssertEqual(flatList.count, setOfCoords.count)
    }

    private func checkCounts(
        _ coords: [GridCoordinate],
        _ count: Int
    ) {
        XCTAssertEqual(coords.count, count)
        XCTAssertEqual(Set(coords).count, count)
    }
}
