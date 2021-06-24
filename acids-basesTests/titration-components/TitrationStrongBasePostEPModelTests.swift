//
// Reactions App
//

import XCTest
import CoreGraphics
@testable import acids_bases

class TitrationStrongBasePostEPModelTests: TitrationStrongAcidPostEPModelTests {

    override func setUp() {
        self.increasingIon = .hydroxide
        self.substance = AcidOrBase.strongBases.first!
    }

    
}
