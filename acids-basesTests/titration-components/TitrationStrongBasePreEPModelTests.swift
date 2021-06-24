//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationStrongBasePreEPModelTests: TitrationStrongAcidPreEPModelTests {

    override func setUp() {
        self.substance = .strongBases.first!
    }

}
