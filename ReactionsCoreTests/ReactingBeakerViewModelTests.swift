//
// Reactions App
//

import XCTest
import SwiftUI
import ReactionsCore

class ReactingBeakerViewModelTests: XCTestCase {

    func testAddingToEmptyCoords() {
        let model = ReactingBeakerViewModel(
            initial: .init(
                builder: { beakerMolecules($0, []) }
            ),
            cols: 10,
            rows: 10
        )

        model.add(
            reactant: .A,
            reactingWith: .B,
            producing: .C,
            withDuration: 0
        )

        XCTAssertEqual(model.coordCount(.A), 1)
        XCTAssertEqual(model.coordCount(.B), 0)
        XCTAssertEqual(model.coordCount(.C), 0)

        model.add(
            reactant: .B,
            reactingWith: .C,
            producing: .A,
            withDuration: 0
        )
        XCTAssertEqual(model.coordCount(.A), 1)
        XCTAssertEqual(model.coordCount(.B), 1)
        XCTAssertEqual(model.coordCount(.C), 0)
    }

    func testCountsWhenAddingToNonEmptyCoords() {
        let initialA = [(0, 0), (0, 1), (0, 2)].map(coords)
        let initialB = [(1, 0), (1, 1), (1, 2)].map(coords)
        let initialC = [(2, 0), (2, 0), (2, 2)].map(coords)

        let initialCoords = EnumMap<TestMolecule, BeakerMolecules>(builder: {
            switch $0 {
            case .A: return beakerMolecules(.A, initialA)
            case .B: return beakerMolecules(.B, initialB)
            case .C: return beakerMolecules(.C, initialC)
            }
        })

        let model = ReactingBeakerViewModel(
            initial: initialCoords,
            cols: 10,
            rows: 10
        )

        model.add(
            reactant: .A,
            reactingWith: .B,
            producing: .C,
            withDuration: 0
        )

        XCTAssertEqual(model.coordCount(.A), 3)
        XCTAssertEqual(model.coordCount(.B), 2)
        XCTAssertEqual(model.coordCount(.C), 5)
    }

    func testCountsWhenAddingMultipleToNonEmptyCoords() {
        let initialA = [(0, 0), (0, 1), (0, 2)].map(coords)
        let initialB = [(1, 0), (1, 1), (1, 2)].map(coords)
        let initialC = [(2, 0), (2, 0), (2, 2)].map(coords)

        let initialCoords = EnumMap<TestMolecule, BeakerMolecules>(builder: {
            switch $0 {
            case .A: return beakerMolecules(.A, initialA)
            case .B: return beakerMolecules(.B, initialB)
            case .C: return beakerMolecules(.C, initialC)
            }
        })

        let model = ReactingBeakerViewModel(
            initial: initialCoords,
            cols: 10,
            rows: 10
        )

        model.add(
            reactant: .A,
            reactingWith: .B,
            producing: .C,
            withDuration: 0,
            count: 4
        )

        XCTAssertEqual(model.coordCount(.A), 4)
        XCTAssertEqual(model.coordCount(.B), 0)
        XCTAssertEqual(model.coordCount(.C), 9)
    }

    private func coords(fromTuple tuple: (Int, Int)) -> GridCoordinate {
        GridCoordinate(col: tuple.0, row: tuple.1)
    }

    private func beakerMolecules(
        _ molecule: TestMolecule,
        _ coords: [GridCoordinate]
    ) -> BeakerMolecules {
        BeakerMolecules(
            coords: coords,
            color: .purple,
            label: ""
        )
    }

    enum TestMolecule: CaseIterable {
        case A, B, C
    }
}

private extension ReactingBeakerViewModel {
    func molecules(_ molecule: Molecule) -> BeakerMolecules {
        self.consolidated.value(for: molecule)
    }

    func coordCount(_ molecule: Molecule) -> Int {
        molecules(molecule).coords.count
    }
}
