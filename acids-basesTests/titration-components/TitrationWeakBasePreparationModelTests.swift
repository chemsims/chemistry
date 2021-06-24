//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationWeakBasePreparationModelTests: TitrationWeakAcidPreparationModelTests {

    override func setUp() {
        self.substance = .weakBases.first!
    }

}
