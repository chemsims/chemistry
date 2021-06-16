//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct BufferSharedComponents {
    private init() { }

    static func pHEquation(
        substance: AcidOrBase,
        substanceConcentration: Equation,
        secondaryConcentration: Equation
    ) -> Equation {
        if substance.type.isAcid {
            return pHEquationForAcid(
                pKa: substance.pKA,
                substanceConcentration: substanceConcentration,
                secondaryConcentration: secondaryConcentration
            )
        }
        return pHEquationForBase(
            pKb: substance.pKB,
            substanceConcentration: substanceConcentration,
            secondaryConcentration: secondaryConcentration
        )
    }

    private static func pHEquationForAcid(
        pKa: CGFloat,
        substanceConcentration: Equation,
        secondaryConcentration: Equation
    ) -> Equation {
        pKa + Log10Equation(underlying: secondaryConcentration / substanceConcentration)
    }

    private static func pHEquationForBase(
        pKb: CGFloat,
        substanceConcentration: Equation,
        secondaryConcentration: Equation
    ) -> Equation {
        let pOH = pKb + Log10Equation(underlying: secondaryConcentration / substanceConcentration)
        return 14 - pOH
    }

    struct SubstanceFractionFromPh: Equation {
        let substance: AcidOrBase

        func getY(at x: CGFloat) -> CGFloat {
            // This is derived from the equation p = pK + log(secondary/substance).
            // It can be rearranged to give an expression in terms of fraction of substance.
            func fractionInTermsOfP(p: CGFloat, pK: CGFloat) -> CGFloat {
                let denom = 1 + pow(10, p - pK)
                return denom == 0 ? 0 : 1 / denom
            }
            if substance.type.isAcid {
                return fractionInTermsOfP(p: x, pK: substance.pKA)
            }
            let pOh = 14 - x
            return fractionInTermsOfP(p: substance.pKB, pK: pOh)
        }
    }

    struct SecondaryIonFractionFromPh: Equation {
        let substance: AcidOrBase

        func getY(at x: CGFloat) -> CGFloat {
            // This is derived from the equation p = pK + log(secondary/substance).
            // It can be rearranged to give an expression in terms of fraction of substance.
            func fractionInTermsOfP(p: CGFloat, pK: CGFloat) -> CGFloat {
                let powerTerm = pow(10, p - pK)
                let denom = powerTerm + 1
                return denom == 0 ? 0 : powerTerm / denom
            }

            if substance.type.isAcid {
                return fractionInTermsOfP(p: x, pK: substance.pKA)
            }
            let pOh = 14 - x
            return fractionInTermsOfP(p: substance.pKB, pK: pOh)
        }
    }
}


// MARK: Reaction progress
extension BufferSharedComponents {
    static func initialReactionProgressModel(substance: AcidOrBase) -> ReactionProgressChartViewModel<SubstancePart> {
        .init(
            molecules: initialReactionProgressMolecules(substance: substance),
            settings: .init(maxMolecules: AcidAppSettings.maxReactionProgressMolecules),
            timing: .init()
        )
    }

    private static func initialReactionProgressMolecules(substance: AcidOrBase) -> EnumMap<SubstancePart, ReactionProgressChartViewModel<SubstancePart>.MoleculeDefinition> {
        let indices = EnumMap<SubstancePart, Int> {
            switch $0 {
            case .substance: return 0
            case .primaryIon: return 1
            case .secondaryIon: return 2
            }
        }
        return .init(builder: { part in
            .init(
                label: substance.chargedSymbol(ofPart: part).text,
                columnIndex: indices.value(for: part),
                initialCount: 0,
                color: substance.color(ofPart: part)
            )
        })
    }
}
