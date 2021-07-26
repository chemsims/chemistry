//
// Reactions App
//

import Foundation
import CoreGraphics

protocol TitrationInputPersistence {
    var input: TitrationScreenInput? { get set }
}

struct TitrationScreenInput {
    let weakBase: AcidOrBase
    let weakBaseBeakerRows: Int
    let weakBaseSubstanceAdded: Int
    let titrantMolarity: CGFloat
}

class InMemoryTitrationInputPersistence: TitrationInputPersistence {
    var input: TitrationScreenInput?
}
