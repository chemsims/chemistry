//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class AcidSubstanceBeakerCoordsTests: XCTestCase {

    func testStrongAcidCoords() {
        var model = AcidSubstanceBeakerCoords(substance: .strongAcid())
        var coords: SubstanceValue<[GridCoordinate]> {
            model.coords
        }

        model.coords.all.forEach { coords in
            XCTAssert(coords.isEmpty)
        }

        model.update(substanceCount: 10, cols: 10, rows: 10)

        XCTAssert(coords.substance.isEmpty)
        let primaryIonFirstValue = coords.primaryIon
        let secondaryIonFirstValue = coords.secondaryIon
        checkCounts(primaryIonFirstValue, 10)
        checkCounts(secondaryIonFirstValue, 10)
        checkNoOverlap(coords)

        // Check no change when using same value
        model.update(substanceCount: 10, cols: 10, rows: 10)
        XCTAssert(coords.substance.isEmpty)
        XCTAssertEqual(coords.primaryIon, primaryIonFirstValue)
        XCTAssertEqual(coords.secondaryIon, secondaryIonFirstValue)

        model.update(substanceCount: 50, cols: 10, rows: 10)
        XCTAssert(coords.substance.isEmpty)
        checkCounts(coords.primaryIon, 50)
        checkCounts(coords.secondaryIon, 50)
        checkNoOverlap(coords)

        // Try adding too many
        model.update(substanceCount: 500, cols: 10, rows: 10)
        XCTAssert(coords.substance.isEmpty)
        checkCounts(coords.primaryIon, 50)
        checkCounts(coords.secondaryIon, 50)
        checkNoOverlap(coords)
    }

    func testWeakAcidCoords() {
        var model = AcidSubstanceBeakerCoords(
            substance: .weakAcid(substanceAddedPerIon: NonZeroPositiveInt(5)!)
        )
        var coords: SubstanceValue<[GridCoordinate]> {
            model.coords
        }

        model.update(substanceCount: 4, cols: 10, rows: 10)
        checkCounts(coords.substance, 4)
        checkCounts(coords.primaryIon, 0)
        checkCounts(coords.secondaryIon, 0)

        model.update(substanceCount: 5, cols: 10, rows: 10)
        checkCounts(coords.substance, 5)
        checkCounts(coords.primaryIon, 1)
        checkCounts(coords.secondaryIon, 1)
        checkNoOverlap(coords)

        model.update(substanceCount: 6, cols: 10, rows: 10)
        checkCounts(coords.substance, 6)
        checkCounts(coords.primaryIon, 1)
        checkCounts(coords.secondaryIon, 1)
        checkNoOverlap(coords)

        model.update(substanceCount: 20, cols: 10, rows: 10)
        checkCounts(coords.substance, 20)
        checkCounts(coords.primaryIon, 4)
        checkCounts(coords.secondaryIon, 4)
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
