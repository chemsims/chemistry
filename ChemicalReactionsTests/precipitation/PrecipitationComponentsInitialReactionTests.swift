//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationComponentsInitialReactionTests: XCTestCase {

    func testAllUnknownReactantIsConsumed() {
        var firstModel = PrecipitationComponents.KnownReactantPreparation()
        firstModel.add(reactant: .known, count: 20)

        var secondModel = PrecipitationComponents.UnknownReactantPreparation(previous: firstModel)
        secondModel.add(reactant: .unknown, count: 10)

        let initialUnknownCoords = secondModel.initialCoords(for: .unknownReactant)
        XCTAssertGreaterThan(initialUnknownCoords.count, 0)

        let model = PrecipitationComponents.InitialReaction(
            unknownReactantCoeff: 1,
            previous: secondModel,
            grid: BeakerGrid(rows: 10, cols: 10)
        )

        XCTAssertEqual(model.initialCoords(for: .unknownReactant), initialUnknownCoords)
        XCTAssertEqual(model.finalCoords(for: .unknownReactant), [])
    }

    func testKnownReactantIsFirstConsumedFromOverlapWithProduct() {
        var firstModel = PrecipitationComponents.KnownReactantPreparation()
        firstModel.add(reactant: .known, count: 50)
        var secondModel = PrecipitationComponents.UnknownReactantPreparation(previous: firstModel)
        secondModel.add(reactant: .unknown, count: 30)
        XCTAssertEqual(secondModel.initialCoords(for: .unknownReactant).count, 30)

        let model = PrecipitationComponents.InitialReaction(
            unknownReactantCoeff: 1,
            previous: secondModel,
            grid: .init(rows: 10, cols: 10)
        )

        let initialKnownCoords = firstModel.initialCoords(for: .knownReactant)

        let modelInitialKnownCoords = model.initialCoords(for: .knownReactant)
        XCTAssertEqual(Set(modelInitialKnownCoords), Set(initialKnownCoords))
        XCTAssertEqual(modelInitialKnownCoords.count, initialKnownCoords.count)

        let modelFinalKnownCoords = model.finalCoords(for: .knownReactant)
        let expectedToConsume = secondModel.initialCoords(for: .unknownReactant).count
        XCTAssertEqual(modelFinalKnownCoords.count, initialKnownCoords.count - expectedToConsume)
        

        let finalProductCoords = model.finalCoords(for: .product)


        // We should consume all overlapping first, and then non-overlapping. If there aren't
        // enough non-overlapping coords, then some overlapping will have to remain
        let nonOverlappingKnownCoords = Set(initialKnownCoords).subtracting(finalProductCoords)
        let finalKnownCount = modelFinalKnownCoords.count
        let expectedOverlappingToRemain = max(0, finalKnownCount - nonOverlappingKnownCoords.count)

        let overlappingCoords = Set(finalProductCoords).intersection(Set(modelFinalKnownCoords))
        XCTAssertEqual(overlappingCoords.count, expectedOverlappingToRemain)
    }

    private func makeCoord(_ tuple: (Int, Int)) -> GridCoordinate {
        GridCoordinate(col: tuple.0, row: tuple.1)
    }
}

private extension PrecipitationComponents.KnownReactantPreparation {
    init() {
        self.init(
            unknownReactantCoeff: 1,
            grid: BeakerGrid(rows: 10, cols: 10),
            reactionProgressModel: PrecipitationComponents.initialReactionProgressModel(
                reaction: .availableReactionsWithRandomMetals().first!
            ),
            precipitate: GrowingPolygon(center: CGPoint(x: 0.5, y: 0.5)),
            settings: .init(
                minConcentrationOfKnownReactantPostFirstReaction: 0,
                minConcentrationOfUnknownReactantToReact: 0
            )
        )
    }
}

private extension PrecipitationComponents.UnknownReactantPreparation {
    init(previous: PrecipitationComponents.KnownReactantPreparation) {
        self.init(
            unknownReactantCoeff: 1,
            previous: previous,
            grid: BeakerGrid(rows: 10, cols: 10),
            settings: .init(
                minConcentrationOfKnownReactantPostFirstReaction: 0,
                minConcentrationOfUnknownReactantToReact: 0
            )
        )
    }
}
