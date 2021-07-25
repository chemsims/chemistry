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

    func label(model: SolubilityViewModel) -> String {
        let products = model.selectedReaction.products
        let salt = products.salt
        let commonIon = products.commonSalt

        func reaction(_ type: SoluteType) -> String {
            type.reactionLabel(for: model.selectedReaction)
        }

        switch self {
        case .clear:
            return "Beaker of liquid"
        case .demo:
            return """
            Beaker of liquid, where \(salt) solute is falling into the beaker and dissolving, \
            causing positive and negative ions to be released and move around the beaker
            """
        case .addingSolute:
            return """
            Beaker of liquid. \(salt) solute being added to the beaker dissolves causing the reaction time \
            to progress forward and the color of the liquid to change
            """
        case .saturated:
            return "Beaker of saturated liquid"
        case .addingSaturatedSolute:
            return "Beaker of saturated liquid, where \(salt) solute being added sinks to the bottom and does not dissolve"
        case .superSaturated:
            return "Beaker of supersaturated liquid. There are \(salt) solute particles lying at the bottom of the beaker."
        case .addingCommonIon:
            return """
            Beaker of liquid, where \(commonIon) solute being added dissolves, causing the liquid color \
            to change and the concentration of \(products.second) to increase. Reaction definition is \(reaction(.commonIon))
            """
        case .addingAcid:
            return """
            Beaker of supersaturated liquid with \(salt) solute particles lying at the bottom of beaker. \
            H+ solute being added dissolves and causes the color of the liquid to change and concentration of \(products.second) to decrease. Reaction definition is \(reaction(.acid))
            """
        case .runningAcidReaction:
            return "Beaker of supersaturated liquid, where the solute particles at the bottom of the beaker are gradually dissolving while the reaction is running"
        }
    }

    func value(at time: CGFloat, model: SolubilityViewModel) -> String? {
        var emitted: Int {
            model.componentsWrapper.counts.count(of: .emitted)
        }
        let products = model.selectedReaction.products
        var concentrationB: CGFloat {
            model.components.equation.concentration.productB.getY(at: time)
        }
        var mg: String {
            "\(model.milligramsSoluteAdded.str(decimals: 0))mg"
        }
        var concentrationBString: String {
            "concentration of \(products.second) is \(concentrationB.str(decimals: 2))"
        }

        switch self {
        case .clear: return nil
        case .demo: return nil
        case .saturated: return nil
        case .superSaturated: return nil
        case .runningAcidReaction: return nil
        case .addingSolute:
            return "\(mg) of \(products.salt) added, reaction time \(model.currentTime.str(decimals: 1))"
        case .addingSaturatedSolute:
            return "\(emitted) \(products.salt) solute particles lying on bottom of beaker"
        case .addingCommonIon:
            return "\(mg) of \(products.commonSalt) added, \(concentrationBString)"
        case .addingAcid:
            return "\(emitted) H+ solute particles added, \(concentrationBString)"

        }
    }

    func action(model: SolubilityViewModel) -> (String, () -> Void)? {
        func add(_ type: SoluteType) {
            model.addVoiceOverParticle(soluteType: type)
        }
        let product = model.selectedReaction.products
        switch self {
        case .addingSolute:
            return ("Add \(product.salt) solute particle", { add(.primary) })
        case .addingSaturatedSolute:
            return ("Add \(product.salt) solute particle", { add(.primary) })
        case .addingCommonIon:
            return ("Add \(product.commonSalt) particle", { add(.commonIon) })
        case .addingAcid:
            return ("Add H+ solute particle", { add(.acid) })
        default: return nil
        }
    }
}
