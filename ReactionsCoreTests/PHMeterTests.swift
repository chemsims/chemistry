//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class PHMeterTests: XCTestCase {

    func testMeterFullyInArea() {
        XCTAssert(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 10, height: 10),
                meterCenterFromAreaCenter: .zero
            )
        )
    }

    func testMeterPartiallyOverlappingOnRightSide() {
        let geometry = PHMeterGeometry(width: 10, height: 10)
        XCTAssert(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(
                    width: 55 - geometry.stalkLeadingPadding - 1,
                    height: 0
                )
            )
        )

        XCTAssertFalse(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(
                    width: 55 - geometry.stalkLeadingPadding,
                    height: 0
                )
            )
        )
    }

    func testMeterPartiallyOverlappingOnLeftSide() {
        let geometry = PHMeterGeometry(width: 10, height: 10)
        let rightOfStalkToRightEdge = 10 - (geometry.stalkLeadingPadding + geometry.stalkWidth)
        XCTAssert(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(
                    width: -55 + rightOfStalkToRightEdge + 1,
                    height: 0
                )
            )
        )

        XCTAssertFalse(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(
                    width: -55 + rightOfStalkToRightEdge,
                    height: 0
                )
            )
        )
    }

    func testMeterPartiallyOverlappingOnTop() {
        XCTAssert(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(width: 0, height: -54)
            )
        )

        XCTAssertFalse(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(width: 0, height: -55)
            )
        )
    }

    func testMeterPartiallyOverlappingOnBottom() {
        let geometry = PHMeterGeometry(width: 10, height: 10)
        XCTAssert(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(width: 0, height: 55 - geometry.topOfCapY - 1)
            )
        )

        XCTAssertFalse(
            PHMeter.tipOverlapsArea(
                meterSize: CGSize(width: 10, height: 10),
                areaSize: CGSize(width: 100, height: 100),
                meterCenterFromAreaCenter: CGSize(width: 0, height: 55 - geometry.topOfCapY )
            )
        )
    }
}
