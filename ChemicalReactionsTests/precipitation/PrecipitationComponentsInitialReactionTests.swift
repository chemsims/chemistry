//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationComponentsInitialReactionTests: XCTestCase {

    func testAllUnknownReactantIsConsumed() {
        let initialUnknownCoords = [(0, 0), (0, 1), (0, 2)].map(makeCoord)
        let prevModel = TestPreviousPhaseComponents(unknownReactantCoords: initialUnknownCoords)

        let model = PrecipitationComponents.InitialReaction(
            unknownReactantCoeff: 1,
            previous: prevModel,
            endOfReaction: 1,
            grid: .init(rows: 10, cols: 10)
        )

        let modelCoords = model.coords(for: .unknownReactant)
        XCTAssertEqual(modelCoords.coords(at: 0), initialUnknownCoords)
        XCTAssertEqual(modelCoords.coords(at: 1), [])
    }

    func testKnownReactantIsFirstConsumedFromOverlapWithProduct() {
        let initialKnownCoords = (0..<10).flatMap { col in
            (0..<10).map { row in
                GridCoordinate(col: col, row: row)
            }
        }
        let initialUnknownCoords = (0..<10).map { col in
            GridCoordinate(col: col, row: 10)
        }
        let prevModel = TestPreviousPhaseComponents(
            knownReactantCoords: initialKnownCoords,
            unknownReactantCoords: initialUnknownCoords
        )
        let model = PrecipitationComponents.InitialReaction(
            unknownReactantCoeff: 1,
            previous: prevModel,
            endOfReaction: 1,
            grid: .init(rows: 11, cols: 10)
        )

        let modelCoords = model.coords(for: .knownReactant)
        XCTAssertEqual(Set(modelCoords.coords(at: 0)), Set(initialKnownCoords))
        XCTAssertEqual(modelCoords.coords(at: 0).count, initialKnownCoords.count)

        let finalCoords = modelCoords.coords(at: 1)
        let expectedToConsume = initialUnknownCoords.count
        XCTAssertEqual(finalCoords.count, initialKnownCoords.count - expectedToConsume)

        let finalProductCoords = model.coords(for: .product).coords(at: 1)
        let finalOverlappingCoords = Set(finalProductCoords).intersection(Set(finalCoords))
        XCTAssertEqual(finalOverlappingCoords, Set())
    }

    private func makeCoord(_ tuple: (Int, Int)) -> GridCoordinate {
        GridCoordinate(col: tuple.0, row: tuple.1)
    }
}

private struct TestPreviousPhaseComponents: PhaseComponents {

    init(
        knownReactantCoords: [GridCoordinate] = [],
        unknownReactantCoords: [GridCoordinate] = []
    ) {
        self.knownReactantCoords = knownReactantCoords
        self.unknownReactantCoords = unknownReactantCoords
    }

    private let knownReactantCoords: [GridCoordinate]
    private let unknownReactantCoords: [GridCoordinate]

    let startOfReaction: CGFloat = 0
    let endOfReaction: CGFloat = 0
    let previouslyReactingUnknownReactantMoles: CGFloat = 0

    func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingCoordinates(for: molecule),
            fractionToDraw: ConstantEquation(value: 1)
        )
    }

    private func underlyingCoordinates(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate] {
        switch molecule {
        case .knownReactant: return knownReactantCoords
        case .unknownReactant: return unknownReactantCoords
        case .product: return []
        }
    }

    func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
        false
    }

    func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool {
        true
    }

    mutating func add(reactant: PrecipitationComponents.Reactant, count: Int) {
    }
}
