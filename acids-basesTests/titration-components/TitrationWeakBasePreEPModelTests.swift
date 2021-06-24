//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationWeakBasePreEPModelTests: TitrationWeakAcidPreEPModelTests {

    override func setUp() {
        self.substance = .weakBases.first!
    }
    
}
