//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class TitrationStrongBasePreparationModelTests: TitrationStrongAcidPreparationModelTests {

    override func setUp() {
        self.substance = AcidOrBase.strongBases.first!
    }

}
