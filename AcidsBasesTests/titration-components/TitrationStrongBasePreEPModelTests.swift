//
// Reactions App
//

import XCTest
@testable import AcidsBases

class TitrationStrongBasePreEPModelTests: TitrationStrongAcidPreEPModelTests {

    override func setUp() {
        self.substance = .strongBases.first!
    }

}
