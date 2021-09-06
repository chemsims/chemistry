//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class BalancedReactionBeakerMoleculeLayoutTests: XCTestCase {

    func testPositionForBeakerWithOneMoleculeType() {
        let width: CGFloat = 100
        let height: CGFloat = 100
        let origin = CGPoint(x: 20, y: 20)
        let beakerSettings = BeakerSettings(width: width, hasLip: true)
        let model = BalancedReactionBeakerMoleculeLayout(
            firstMolecule: .ammonia,
            secondMolecule: nil,
            beakerRect: CGRect(origin: origin, size: CGSize(width: width, height: height)),
            beakerSettings: beakerSettings
        )

        let lipGap = beakerSettings.width - beakerSettings.innerBeakerWidth
        let beakerWithoutLip = CGRect(
            origin: CGPoint(x: origin.x + (lipGap / 2), y: origin.y),
            size: CGSize(width: beakerSettings.innerBeakerWidth, height: height)
        )

        let maxRows = BalancedReactionBeakerMoleculeLayout.rows
        let maxCols = BalancedReactionBeakerMoleculeLayout.cols

        let expectedFirstPosition = TableCellPosition.position(
            in: beakerWithoutLip,
            rows: maxRows,
            cols: maxCols,
            rowIndex: 0,
            colIndex: 0
        )

        XCTAssertEqual(model.position(of: .ammonia, currentCount: 0), expectedFirstPosition)

        let expectedFinalPosition = TableCellPosition.position(
            in: beakerWithoutLip,
            rows: maxRows,
            cols: maxCols,
            rowIndex: maxRows - 1,
            colIndex: maxCols - 1
        )

        let penultimateCount = (maxCols * maxRows) - 1
        XCTAssertEqual(model.position(of: .ammonia, currentCount: penultimateCount), expectedFinalPosition)
    }

    func testPositionForLeftMoleculeInBeakerWithTwoMoleculeTypes() {
        let width: CGFloat = 100
        let height: CGFloat = 100
        let origin = CGPoint(x: 20, y: 20)
        let beakerSettings = BeakerSettings(width: width, hasLip: true)
        let model = BalancedReactionBeakerMoleculeLayout(
            firstMolecule: .ammonia,
            secondMolecule: .carbonDioxide,
            beakerRect: CGRect(origin: origin, size: CGSize(width: width, height: height)),
            beakerSettings: beakerSettings
        )

        let lipGap = beakerSettings.width - beakerSettings.innerBeakerWidth
        let beakerWithoutLip = CGRect(
            origin: CGPoint(x: origin.x + (lipGap / 2), y: origin.y),
            size: CGSize(width: beakerSettings.innerBeakerWidth, height: height)
        )
        let leftRect = CGRect(
            origin: beakerWithoutLip.origin,
            size: CGSize(width: beakerWithoutLip.width / 2, height: beakerWithoutLip.height)
        )

        let maxRows = BalancedReactionBeakerMoleculeLayout.rows
        let maxCols = BalancedReactionBeakerMoleculeLayout.cols

        let expectedFirstPosition = TableCellPosition.position(
            in: leftRect,
            rows: maxRows,
            cols: maxCols,
            rowIndex: 0,
            colIndex: 0
        )

        XCTAssertEqual(model.position(of: .ammonia, currentCount: 0), expectedFirstPosition)

        let expectedFinalPosition = TableCellPosition.position(
            in: leftRect,
            rows: maxRows,
            cols: maxCols,
            rowIndex: maxRows - 1,
            colIndex: maxCols - 1
        )

        let penultimateCount = (maxCols * maxRows) - 1
        XCTAssertEqual(model.position(of: .ammonia, currentCount: penultimateCount), expectedFinalPosition)
    }

    func testPositionForRightMoleculeInBeakerWithTwoMoleculeTypes() {
        let width: CGFloat = 100
        let height: CGFloat = 100
        let origin = CGPoint(x: 20, y: 20)
        let beakerSettings = BeakerSettings(width: width, hasLip: true)
        let model = BalancedReactionBeakerMoleculeLayout(
            firstMolecule: .ammonia,
            secondMolecule: .carbonDioxide,
            beakerRect: CGRect(origin: origin, size: CGSize(width: width, height: height)),
            beakerSettings: beakerSettings
        )

        let lipGap = beakerSettings.width - beakerSettings.innerBeakerWidth
        let beakerWithoutLip = CGRect(
            origin: CGPoint(x: origin.x + (lipGap / 2), y: origin.y),
            size: CGSize(width: beakerSettings.innerBeakerWidth, height: height)
        )
        let rightRect = CGRect(
            origin: beakerWithoutLip.origin.offset(dx: beakerWithoutLip.width / 2, dy: 0),
            size: CGSize(width: beakerWithoutLip.width / 2, height: beakerWithoutLip.height)
        )

        let maxRows = BalancedReactionBeakerMoleculeLayout.rows
        let maxCols = BalancedReactionBeakerMoleculeLayout.cols

        let expectedFirstPosition = TableCellPosition.position(
            in: rightRect,
            rows: maxRows,
            cols: maxCols,
            rowIndex: 0,
            colIndex: 0
        )

        XCTAssertEqual(model.position(of: .carbonDioxide, currentCount: 0), expectedFirstPosition)

        let expectedFinalPosition = TableCellPosition.position(
            in: rightRect,
            rows: maxRows,
            cols: maxCols,
            rowIndex: maxRows - 1,
            colIndex: maxCols - 1
        )

        let penultimateCount = (maxCols * maxRows) - 1
        XCTAssertEqual(model.position(of: .carbonDioxide, currentCount: penultimateCount), expectedFinalPosition)
    }

    func testValidMoleculeNotAllowedBeyondLimits() {
        let model = BalancedReactionBeakerMoleculeLayout(
            firstMolecule: .ammonia,
            secondMolecule: nil,
            beakerRect: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            beakerSettings: .init(width: 100, hasLip: true)
        )

        let maxCount = BalancedReactionBeakerMoleculeLayout.cols * BalancedReactionBeakerMoleculeLayout.rows

        XCTAssertNil(model.position(of: .ammonia, currentCount: maxCount))
        XCTAssertNil(model.position(of: .carbonDioxide, currentCount: 0))
    }
}
