//
// Reactions App
//


import XCTest

class EquilibriumAppCanBeOpenedByUrlTests: XCTestCase {

    func testUrlCanBeOpened() {
        let url = URL(string: "equilibriumapp://app")!
        XCTAssert(UIApplication.shared.canOpenURL(url))
    }


}
