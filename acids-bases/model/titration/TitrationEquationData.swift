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
    let concentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat>
    let pValues: EnumMap<TitrationEquationTerm.PValue, CGFloat>
    let kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat>

    static let preview = TitrationEquationData(
        substance: .weakAcids.first!,
        titrant: "KOH",
        moles: .constant(0.01),
        volume: .constant(0.1),
        molarity: .constant(0.4),
        concentration: .constant(0.05),
        pValues: .constant(7),
        kValues: .constant(0.01)
    )
}
