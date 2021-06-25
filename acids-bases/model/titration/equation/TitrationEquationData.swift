//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct TitrationEquationData {

    init(
        substance: AcidOrBase,
        titrant: String,
        moles: EnumMap<TitrationEquationTerm.Moles, Equation>,
        volume: EnumMap<TitrationEquationTerm.Volume, Equation>,
        molarity: EnumMap<TitrationEquationTerm.Molarity, Equation>,
        concentration: EnumMap<TitrationEquationTerm.Concentration, Equation>
    ) {
        self.substance = substance
        self.titrant = titrant
        self.moles = moles
        self.volume = volume
        self.molarity = molarity
        self.concentration = concentration
        self.pValues = .init {
            switch $0 {
            case .hydrogen:
                return -1 * Log10Equation(underlying: concentration.value(for: .hydrogen))
            case .hydroxide:
                return -1 * Log10Equation(underlying: concentration.value(for: .hydroxide))
            case .kA: return ConstantEquation(value: substance.pKA)
            case .kB: return ConstantEquation(value: substance.pKB)
            }
        }
        self.kValues = .init {
            switch $0 {
            case .kA: return substance.kA
            case .kB: return substance.kB
            }
        }
    }

    let substance: AcidOrBase
    let titrant: String

    let moles: EnumMap<TitrationEquationTerm.Moles, Equation>
    let volume: EnumMap<TitrationEquationTerm.Volume, Equation>
    let molarity: EnumMap<TitrationEquationTerm.Molarity, Equation>
    let concentration: EnumMap<TitrationEquationTerm.Concentration, Equation>
    let pValues: EnumMap<TitrationEquationTerm.PValue, Equation>
    let kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat>

    static let preview = TitrationEquationData(
        substance: .weakAcids.first!,
        titrant: "KOH",
        moles: .constant(ConstantEquation(value: 0.1)),
        volume: .constant(ConstantEquation(value: 0.1)),
        molarity: .constant(ConstantEquation(value: 0.1)),
        concentration: .constant(ConstantEquation(value: 0.1))
    )
}
