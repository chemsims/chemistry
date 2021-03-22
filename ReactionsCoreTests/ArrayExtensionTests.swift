//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class ArrayExtensionTests: XCTestCase {

    func testFlatteningArray() {
        XCTAssertEqual([[1], [2]].flatten, [1, 2])
        XCTAssertEqual([[1, 2], [3]].flatten, [1, 2, 3])
        XCTAssertEqual([[1, 2], [3, 4, 5]].flatten, [1, 2, 3, 4, 5])
        XCTAssertEqual([[1], [2], [], [3]].flatten, [1, 2, 3])
        XCTAssertEqual([[], [2], [3,4,5], [6]].flatten, [2, 3, 4, 5, 6])
        XCTAssert([[]].flatten.isEmpty)
    }

}
