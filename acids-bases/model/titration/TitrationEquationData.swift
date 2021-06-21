//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct TitrationEquationData {

    let substance: AcidOrBase
    let titrant: String

    let moles: EnumMap<TitrationEquationTerm.Moles, CGFloat>
    let volume: EnumMap<TitrationEquationTerm.Volume, CGFloat>
    let molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat>
}
