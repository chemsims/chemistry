//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationStrongBasePreparationModelTests: TitrationStrongAcidPreparationModelTests {

    override func setUp() {
        self.substance = AcidOrBase.strongBases.first!
    }

}
