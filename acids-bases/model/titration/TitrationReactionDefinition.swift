//
// Reactions App
//

import ReactionsCore

struct TitrationReactionDefinition {
    let substance: AcidOrBase
    let titrant: Titrant

    var leftTerms: [ReactionDefinitionView.Term] {
        [leftTerm1, leftTerm2]
    }

    var rightTerms: [ReactionDefinitionView.Term] {
        [rightTerm1, rightTerm2]
    }

    private var leftTerm1: ReactionDefinitionView.Term {
        term(ofPart: .substance)
    }

    private var leftTerm2: ReactionDefinitionView.Term {
        titrantTerm
    }

    private var rightTerm1: ReactionDefinitionView.Term {
        if substance.type.isStrong {
            return .init(name: "KCl", color: Styling.beakerLiquid)
        } else {
            return waterTerm
        }
    }

    private var rightTerm2: ReactionDefinitionView.Term {
        if substance.type.isStrong {
            return waterTerm
        }
        if substance.type.isAcid {
            let line = substance.chargedSymbol(ofPart: .secondaryIon).text
            return .init(name: line, color: substance.color(ofPart: .secondaryIon))
        }
        let line = "H\(substance.chargedSymbol(ofPart: .secondaryIon).text)"
        return .init(name: TextLine(line), color: .purple)
    }

    private var waterTerm: ReactionDefinitionView.Term {
        .init(name: "H_2_O", color: Styling.beakerLiquid)
    }

    private var titrantTerm: ReactionDefinitionView.Term {
        .init(name: TextLine(titrant.name), color: titrant.maximumMolarityColor.color)
    }

    private func term(ofPart part: SubstancePart) -> ReactionDefinitionView.Term {
        .init(name: substance.chargedSymbol(ofPart: part).text, color: substance.color(ofPart: part))
    }

    // strong acid: HCL (substance) + KOH (titrant) -> KCl + water
    // strong base: HCL (titrant) + KOH (substance) -> KCl + water
    // weak acid: HA (substance) + KOH (titrant) -> water + KA
    // weak base: A (substance) + H3O -> water + HA
}
