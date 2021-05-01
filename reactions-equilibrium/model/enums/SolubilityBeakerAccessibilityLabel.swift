//
// Reactions App
//

import CoreGraphics

enum SolubilityBeakerAccessibilityLabel {
    case clear,
         demo,
         addingSolute,
         saturated,
         addingSaturatedSolute,
         superSaturated,
         addingCommonIon,
         addingAcid,
         runningAcidReaction

    var label: String {
        switch self {
        case .clear:
            return "Beaker of liquid"
        case .demo:
            return "Beaker of liquid, where solute is falling into the beaker and dissolving, causing positive and negative ions to be released and move around the beaker"
        case .addingSolute:
            return "Beaker of liquid, where solute being added dissolves and causes reaction to progress forward"
        case .saturated:
            return "Beaker of saturated liquid"
        case .addingSaturatedSolute:
            return "Beaker of saturated liquid, where solute being added sinks to the bottom and does not dissolve"
        case .superSaturated:
            return "Beaker of supersaturated liquid. There are solute particles lying at the bottom of the beaker."
        case .addingCommonIon:
            return "Beaker of liquid, where common ion solute being added dissolves, causing the color to change and concentration of secondary ion to increase"
        case .addingAcid:
            return "Beaker of supersaturated liquid with solute particles lying at the bottom of beaker, where acid being added dissolves and causes color the liquid to change"
        case .runningAcidReaction:
            return "Beaker of supersaturated liquid, where the solute particles at the bottom of the beaker are gradually dissolving while the reaction is running"
        }
    }

    func value(at time: CGFloat, model: SolubilityViewModel) -> String? {
        var emitted: Int {
            model.componentsWrapper.counts.count(of: .emitted)
        }

        switch self {
        case .clear: return nil
        case .demo: return nil
        case .saturated: return nil
        case .superSaturated: return nil
        case .runningAcidReaction: return nil
        case .addingSolute:
            return "\(model.milligramsSoluteAdded.str(decimals: 0))mg of solute added"
        case .addingSaturatedSolute:
            return "\(emitted) solute particles lying on bottom of beaker"
        case .addingCommonIon:
            return "\(emitted) common ion solute particles added"
        case .addingAcid:
            return "\(emitted) acid solute particles added"

        }
    }
}
