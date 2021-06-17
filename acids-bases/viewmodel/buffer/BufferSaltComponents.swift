//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferSaltComponents: ObservableObject {

    init(
        prev: BufferWeakSubstanceComponents
    ) {
        reactingModel = Self.initialReactingBeakerModel(previous: prev)

        let initialSubstanceC = prev.concentration.substance.getY(at: 1)
        let finalSubstanceC = prev.concentration.substance.getY(at: 0)
        let initialSecondaryC = prev.concentration.secondaryIon.getY(at: 1)
        let initialPrimaryC = prev.concentration.primaryIon.getY(at: 1)

        self.previous = prev

        func initialCountInt(_ part: SubstancePart) -> Int {
            prev.molecules(for: part).coords.count
        }
        func initialCount(_ part: SubstancePart) -> CGFloat {
            CGFloat(initialCountInt(part))
        }

        let maxSubstance = (initialCountInt(.substance) + initialCountInt(.primaryIon)) - initialCountInt(.secondaryIon)
        self.maxSubstance = maxSubstance
        let substanceConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialSubstanceC,
                x2: initialCount(.primaryIon),
                y2: finalSubstanceC
            ),
            underlyingRight: ConstantEquation(value: finalSubstanceC)
        )
        let secondaryConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: ConstantEquation(value: initialSecondaryC),
            underlyingRight: LinearEquation(
                x1: initialCount(.primaryIon),
                y1: initialSecondaryC,
                x2: CGFloat(maxSubstance),
                y2: finalSubstanceC
            )
        )

        let primaryConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialPrimaryC,
                x2: initialCount(.primaryIon),
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )
        self.concentration = SubstanceValue(
            substance: substanceConcentration,
            primaryIon: primaryConcentration,
            secondaryIon: secondaryConcentration
        )

        
        self.haFractionInTermsOfPH = BufferSharedComponents.SubstanceFractionFromPh(substance: prev.substance)
        self.aFractionInTermsOfPH = BufferSharedComponents.SecondaryIonFractionFromPh(substance: prev.substance)

        let xThreshold = initialCount(.primaryIon)

        // TODO - how does this class know that prev equation reaches a max at 1?
        let substanceBarChartEquation = SwitchingEquation(
            thresholdX: xThreshold,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: prev.substanceBarEquation.getY(at: 1),
                x2: xThreshold,
                y2: finalSubstanceC
            ),
            underlyingRight: ConstantEquation(value: finalSubstanceC)
        )
        let initialIonBarHeight = prev.ionBarEquation.getY(at: 1)
        let primaryIonBarChartEquation = SwitchingEquation(
            thresholdX: xThreshold,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialIonBarHeight,
                x2: xThreshold,
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )
        let secondaryIonBarChartEquation = SwitchingEquation(
            thresholdX: xThreshold,
            underlyingLeft: ConstantEquation(value: initialIonBarHeight),
            underlyingRight: LinearEquation(
                x1: xThreshold,
                y1: initialIonBarHeight,
                x2: CGFloat(maxSubstance),
                y2: finalSubstanceC
            )
        )

        self.barChartEquations = SubstanceValue(
            substance: substanceBarChartEquation,
            primaryIon: primaryIonBarChartEquation,
            secondaryIon: secondaryIonBarChartEquation
        )

        // TODO - there should be a better way to access final pH from previous model
        self.initialPh = previous.pH.getY(at: 1)

        self.reactionProgress = prev.reactionProgress
        self.initialProgressCounts = .init(builder: { part in
            prev.reactionProgress.moleculeCounts(ofType: part)
        })
    }

    @Published var substanceAdded = 0
    @Published private(set) var reactingModel: ReactingBeakerViewModel<SubstancePart>
    @Published private(set) var reactionProgress: ReactionProgressChartViewModel<SubstancePart>

    private let initialProgressCounts: EnumMap<SubstancePart, Int>

    let previous: BufferWeakSubstanceComponents
    let maxSubstance: Int

    let initialPh: CGFloat

    var substance: AcidOrBase {
        previous.substance
    }

    var settings: BufferComponentSettings {
        previous.settings
    }

    let concentration: SubstanceValue<Equation>

    var finalConcentration: SubstanceValue<CGFloat> {
        concentration.map { $0.getY(at: CGFloat(maxSubstance)) }
    }

    func incrementSalt(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        reactingModel.add(
            reactant: .secondaryIon,
            reactingWith: .primaryIon,
            producing: .substance,
            withDuration: 1,
            count: maxToAdd
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += maxToAdd
        }
        updateReactionProgress()
    }

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            substance: substance,
            substanceConcentration: concentration.substance,
            secondaryConcentration: concentration.secondaryIon
        )
    }

    var finalPH: CGFloat {
        pH.getY(at: CGFloat(maxSubstance))
    }

    let haFractionInTermsOfPH: Equation
    let aFractionInTermsOfPH: Equation


    // MARK: Bar chart data
    let barChartEquations: SubstanceValue<Equation>
    var barChartMap: SubstanceValue<BarChartData> {
        SubstanceValue(builder: { part in
            BarChartData(
                label: substance.symbol(ofPart: part),
                equation: barChartEquations.value(for: part),
                color: substance.color(ofPart: part),
                accessibilityLabel: "" // TODO
            )
        })
    }

    var barChartData: [BarChartData] {
        barChartMap.all
    }

    private var initialPrimaryIonCoords: CGFloat {
        CGFloat(previous.molecules(for: .primaryIon).coords.count)
    }
}


// MARK: Input limits
extension BufferSaltComponents {

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughSubstance: Bool {
        !canAddSubstance
    }

    private var remainingCountAvailable: Int {
        max(0, maxSubstance - substanceAdded)
    }
}

// MARK: Equation data
extension BufferSaltComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            substance: previous.substance,
            concentration: concentration,
            pH: pH
        )
    }
}

// MARK: Table data
extension BufferSaltComponents {
    var tableData: [ICETableColumn] {
        [
            column(.substance),
            column(.primaryIon),
            column(.secondaryIon)
        ]
    }

    private func column(_ part: SubstancePart) -> ICETableColumn {
        ICETableColumn(
            header: substance.symbol(ofPart: part),
            initialValue: ConstantEquation(value: concentration.value(for: part).getY(at: 0)),
            finalValue: concentration.value(for: part)
        )
    }
}

// MARK: Reaction progress
extension BufferSaltComponents {

    private func updateReactionProgress() {
        let desiredPrimary = (primaryIonReactionProgressCounts.getY(at: CGFloat(substanceAdded))).roundedInt()
        let desiredSecondary = (secondarySubstanceReactionProgressCount.getY(at: CGFloat(substanceAdded))).roundedInt()

        let currentPrimary = reactionProgress.moleculeCounts(ofType: .primaryIon)
        let currentSecondary = reactionProgress.moleculeCounts(ofType: .secondaryIon)

        // We want primary to go down
        let deltaPrimary = currentPrimary - desiredPrimary
        if deltaPrimary > 0 {
            for _ in 0..<deltaPrimary {
                _ = reactionProgress.startReaction(adding: .secondaryIon, reactsWith: .primaryIon, producing: .substance)
            }
        }

        let deltaSecondary = desiredSecondary - currentSecondary
        if deltaSecondary > 0 {
            for _ in 0..<deltaSecondary {
                _ = reactionProgress.addMolecule(.secondaryIon)
            }
        }
    }

    private var primaryIonReactionProgressCounts: Equation {
        let initialPrimary = CGFloat(initialProgressCounts.value(for: .primaryIon))
        return LinearEquation(
            x1: 0,
            y1: initialPrimary,
            x2: initialPrimaryIonCoords,
            y2: 0
        ).within(min: 0, max: initialPrimary)
    }

    private var secondarySubstanceReactionProgressCount: Equation {
        let initialSecondary = CGFloat(initialProgressCounts.value(for: .secondaryIon))
        let initialPrimary = initialProgressCounts.value(for: .primaryIon)
        let initialSubstance = initialProgressCounts.value(for: .substance)
        let finalSecondary = CGFloat(initialSubstance + initialPrimary)
        return LinearEquation(
            x1: initialPrimaryIonCoords,
            y1: initialSecondary,
            x2: CGFloat(maxSubstance),
            y2: finalSecondary
        ).within(min: initialSecondary, max: finalSecondary)
    }
}

// MARK: Reset state
extension BufferSaltComponents {
    func reset() {
        substanceAdded = 0
        reactingModel = Self.initialReactingBeakerModel(previous: previous)
        reactionProgress = BufferSharedComponents.reactionProgressModel(substance: substance, counts: initialProgressCounts)
    }
}

extension BufferSaltComponents {
    static func initialReactingBeakerModel(previous: BufferWeakSubstanceComponents) -> ReactingBeakerViewModel<SubstancePart> {
        var prevSubstanceCoords = previous.substanceCoords
        let ionCoords = previous.ionCoords.flatMap { $0.molecules.coords }
        let visibleSubstanceCoords = prevSubstanceCoords.coords.filter { !ionCoords.contains($0) }
        prevSubstanceCoords.coords = visibleSubstanceCoords

        return ReactingBeakerViewModel(
            initial: SubstanceValue(
                substance: prevSubstanceCoords,
                primaryIon: previous.ionCoords[0].molecules,
                secondaryIon: previous.ionCoords[1].molecules
            ),
            cols: previous.cols,
            rows: previous.rows
        )
    }
}
