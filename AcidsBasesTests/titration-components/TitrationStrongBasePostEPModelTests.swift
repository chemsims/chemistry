//
// Reactions App
//

import XCTest
import CoreGraphics
@testable import AcidsBases

class TitrationStrongBasePostEPModelTests: TitrationStrongAcidPostEPModelTests {

    override func setUp() {
        self.substance = AcidOrBase.strongBases.first!
    }

    
}
