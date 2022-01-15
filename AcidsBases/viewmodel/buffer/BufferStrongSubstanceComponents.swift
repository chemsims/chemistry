//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferStrongSubstanceComponents: ObservableObject {

    init(prev: BufferSaltComponents) {
        self.previous = prev
        let initialCoords = prev.reactingModel.consolidated
        self.reactingModel = ReactingBeakerViewModel(
            initial: initialCoords,
            cols: prev.previous.cols,
            rows: prev.previous.rows,
            accessibilityLabel: prev.reactingModel.accessibilityLabel
        )

        let initialSecondary = initialCoords.value(for: .secondaryIon).coords.count
        let finalSecondary = prev.settings.finalSecondaryIonCount
        let finalPrimary = prev.settings.minimumFinalPrimaryIonCount

        let maxSubstance = initialSecondary - finalSecondary + finalPrimary
        self.maxSubstance = maxSubstance

        let changeInConcentration = Self.changeInConcentration(
            substance: prev.substance,
            previous: prev
        )

        let substanceConcentration = LinearEquation(
            x1: 0,
            y1: prev.finalConcentration.substance,
            x2: CGFloat(maxSubstance),
            y2: prev.finalConcentration.substance + changeInConcentration
        )
        let secondaryConcentration = LinearEquation(
            x1: 0,
            y1: prev.finalConcentration.secondaryIon,
            x2: CGFloat(maxSubstance),
            y2: prev.finalConcentration.secondaryIon - changeInConcentration
        )

        let finalSubstanceConcentration = substanceConcentration.getValue(at: CGFloat(maxSubstance))
        let finalSecondaryConcentration = substanceConcentration.getValue(at: CGFloat(maxSubstance))
        let finalPrimaryConcentration = (prev.substance.kA * finalSubstanceConcentration) / finalSecondaryConcentration
        let primaryConcentration = LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxSubstance),
            y2: finalPrimaryConcentration
        )

        self.concentration = SubstanceValue(
            substance: substanceConcentration,
            primaryIon: primaryConcentration,
            secondaryIon: secondaryConcentration
        )

        let initialProgressCounts = SubstanceValue<Int>(builder: prev.reactionProgress.moleculeCounts)
        self.reactionProgress = BufferSharedComponents.reactionProgressModel(substance: prev.substance, counts: initialProgressCounts)
        self.initialProgressCounts = initialProgressCounts
    }

    @Published var substanceAdded = 0
    @Published private(set) var reactingModel: ReactingBeakerViewModel<SubstancePart>

    private let previous: BufferSaltComponents

    let maxSubstance: Int
    let concentration: SubstanceValue<Equation>

    @Published private(set) var reactionProgress: ReactionProgressChartViewModel<SubstancePart>
    let initialProgressCounts: SubstanceValue<Int>

    var settings: BufferComponentSettings {
        previous.settings
    }

    func incrementStrongSubstance(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }

        let primaryMoleculeFrequency = Int(Double(maxSubstance) / Double(settings.minimumFinalPrimaryIonCount))
        let newSubstanceAdded = substanceAdded + maxToAdd

        let currentPrimaryMolecules = Int(Double(substanceAdded) / Double(primaryMoleculeFrequency))
        let targetPrimaryMolecules = Int(Double(newSubstanceAdded) / Double(primaryMoleculeFrequency))

        let primaryToAdd = targetPrimaryMolecules - currentPrimaryMolecules
        let moleculesToReact = maxToAdd - primaryToAdd

        if primaryToAdd > 0 {
            reactingModel.addDirectly(molecule: .primaryIon, count: primaryToAdd)
        }

        if moleculesToReact > 0 {
            reactingModel.add(
                reactant: .primaryIon,
                reactingWith: .secondaryIon,
                producing: .substance,
                withDuration: 1,
                count: moleculesToReact
            )
        }

        withAnimation(.linear(duration: 1)) {
            substanceAdded = newSubstanceAdded
        }
        updateReactionProgress()
    }

    var substance: AcidOrBase {
        previous.substance
    }

    var substanceFractionInTermsOfPh: Equation {
        BufferSharedComponents.SubstanceFractionFromPh(substance: substance)
    }

    var secondaryIonFractionInTermsOfPh: Equation {
        BufferSharedComponents.SecondaryIonFractionFromPh(substance: substance)
    }

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            substance: substance,
            substanceConcentration: concentration.substance,
            secondaryConcentration: concentration.secondaryIon
        )
    }
}


// MARK: Input limits
extension BufferStrongSubstanceComponents {

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughSubstance: Bool {
        !canAddSubstance
    }

    var fractionSubstanceAdded: CGFloat {
        CGFloat(substanceAdded) / CGFloat(maxSubstance)
    }

    private var remainingCountAvailable: Int {
        max(0, maxSubstance - substanceAdded)
    }
}

// MARK: Equation data
extension BufferStrongSubstanceComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            substance: substance,
            concentration: concentration,
            pH: pH
        )
    }
}

// MARK: Bar chart data
extension BufferStrongSubstanceComponents {

    var barChartMap: SubstanceValue<BarChartData> {
        SubstanceValue(builder: { part in
            BarChartData(
                label: substance.chargedSymbol(ofPart: part).text,
                equation: concentration.value(for: part),
                color: substance.color(ofPart: part),
                accessibilityLabel: substance.chargedSymbol(ofPart: part).text.label,
                initialValue: nil,
                accessibilityValue: { self.concentration.value(for: part).getValue(at: $0).percentage }
            )
        })
    }

    var barChartData: [BarChartData] {
        barChartMap.all
    }
}

// MARK: Table data
extension BufferStrongSubstanceComponents {
    var tableData: [ICETableColumn] {
        [
            column(.substance),
            column(.primaryIon),
            column(.secondaryIon)
        ]
    }

    private func column(_ part: SubstancePart) -> ICETableColumn {
        ICETableColumn(
            header: substance.chargedSymbol(ofPart: part).text.asString,
            initialValue: ConstantEquation(value: concentration.value(for: part).getValue(at: 0)),
            finalValue: concentration.value(for: part)
        )
    }
}

extension BufferStrongSubstanceComponents {

    private static func changeInConcentration(
        substance: AcidOrBase,
        previous: BufferSaltComponents
    ) -> CGFloat {
        func getChange(targetP: CGFloat, pK: CGFloat) -> CGFloat {
            changeInConcentration(
                forTargetP: targetP,
                pK: pK,
                initialSubstanceConcentration: previous.finalConcentration.substance,
                initialSecondaryConcentration: previous.finalConcentration.secondaryIon
            )
        }

        if substance.type.isAcid {
            return getChange(
                targetP: previous.finalPH - 1.5,
                pK: substance.pKA
            )
        }

        let initialPOH = 14 - previous.finalPH
        return getChange(
            targetP: initialPOH - 1.5,
            pK: substance.pKB
        )
    }

    /// Returns a change in concentration to achieve a target `p`, for the given equation:
    ///
    /// p = pK + log(secondaryConcentration / substanceConcentration)
    ///
    /// The `substanceConcentration` is assumed to increase, while the `secondaryConcentration` is assumed
    /// to decrease by the same amount.
    ///
    /// i.e., we solve this equation for x: finalP = pK + log(secondaryConcentration - x / substanceConcentration + x)
    private static func changeInConcentration(
        forTargetP finalP: CGFloat,
        pK: CGFloat,
        initialSubstanceConcentration: CGFloat,
        initialSecondaryConcentration: CGFloat
    ) -> CGFloat {
        let powerTerm = pow(10, finalP - pK)
        let numer = initialSecondaryConcentration - (initialSubstanceConcentration * powerTerm)
        let denom = 1 + powerTerm
        return denom == 0 ? 0 : numer / denom
    }
}

// MARK: Reaction progress
extension BufferStrongSubstanceComponents {
    func updateReactionProgress() {
        let desiredSecondary = (secondaryIonReactionProgressCount.getValue(at: CGFloat(substanceAdded))).roundedInt()
        let desiredPrimary = (primaryIonReactionProgressCount.getValue(at: CGFloat(substanceAdded))).roundedInt()

        let currentSecondary = reactionProgress.moleculeCounts(ofType: .secondaryIon)
        let currentPrimary = reactionProgress.moleculeCounts(ofType: .primaryIon)

        let deltaSecondary = currentSecondary - desiredSecondary
        if deltaSecondary > 0 {
            for _ in 0..<deltaSecondary {
                _ = reactionProgress.startReaction(adding: .primaryIon, reactsWith: .secondaryIon, producing: .substance)
            }
        }

        let deltaPrimary = desiredPrimary - currentPrimary
        if deltaPrimary > 0 {
            for _ in 0..<deltaPrimary {
                _ = reactionProgress.addMolecule(.primaryIon)
            }
        }
    }

    private var secondaryIonReactionProgressCount: Equation {
        LinearEquation(
            x1: 0,
            y1: CGFloat(initialProgressCounts.value(for: .secondaryIon)),
            x2: CGFloat(maxSubstance),
            y2: CGFloat(settings.reactionProgress.finalSecondaryIonCount)
        )
    }

    private var primaryIonReactionProgressCount: Equation {
        LinearEquation(
            x1: 0,
            y1: CGFloat(initialProgressCounts.value(for: .primaryIon)),
            x2: CGFloat(maxSubstance),
            y2: CGFloat(settings.reactionProgress.finalPrimaryIonCount)
        )
    }
}

// MARK: Resetting state
extension BufferStrongSubstanceComponents {
    func reset() {
        reactingModel = ReactingBeakerViewModel(
            initial: previous.reactingModel.consolidated,
            cols: previous.previous.cols,
            rows: previous.previous.rows,
            accessibilityLabel: previous.reactingModel.accessibilityLabel
        )
        reactionProgress = BufferSharedComponents.reactionProgressModel(substance: substance, counts: initialProgressCounts)
        substanceAdded = 0
    }
}
