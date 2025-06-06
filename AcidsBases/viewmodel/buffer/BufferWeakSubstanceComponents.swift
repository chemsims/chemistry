//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferWeakSubstanceComponents: ObservableObject {

    init(
        substance: AcidOrBase,
        settings: BufferComponentSettings,
        cols: Int,
        rows: Int
    ) {
        self.cols = cols
        self.rows = rows
        self.substanceCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: substance.symbol.label
        )
        self.substance = substance
        self.settings = settings

        self.reactionProgress = BufferSharedComponents.initialReactionProgressModel(substance: substance)
    }

    @Published var substanceCoords: BeakerMolecules
    @Published var progress: CGFloat = 0
    var ionCoords: [AnimatingBeakerMolecules] {
        [
            coordForIon(part: .primaryIon, index: 0),
            coordForIon(part: .secondaryIon, index: 1)
        ]
    }

    let cols: Int
    var rows: Int
    @Published var substance: AcidOrBase {
        didSet {
            reactionProgress = BufferSharedComponents.initialReactionProgressModel(substance: substance)
            substanceCoords = BeakerMolecules(
                coords: [],
                color: substance.color,
                label: substance.symbol.label
            )
        }
    }

    @Published private(set) var reactionProgress: ReactionProgressChartViewModel<SubstancePart>

    let settings: BufferComponentSettings

    func incrementSubstance(count: Int) {
        let maxToAdd = min(remainingCountAvailable, count)
        guard maxToAdd > 0 else {
            return
        }
        substanceCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: substanceCoords.coords,
            count: count,
            cols: cols,
            rows: rows
        )
        incrementReactionProgressIfNeeded()
        concentration = AcidConcentrationEquations.concentrations(
            forPartsOf: substance,
            initialSubstanceConcentration: initialSubstanceConcentration
        )
    }

    func molecules(for substance: SubstancePart) -> BeakerMolecules {
        switch substance {
        case .substance: return substanceCoords
        case .primaryIon: return ionCoords[0].molecules
        case .secondaryIon: return ionCoords[1].molecules
        }
    }

    private func coordForIon(
        part: SubstancePart,
        index: Int
    ) -> AnimatingBeakerMolecules {
        let startCoordIndex = index * finalIonCoordCount
        let endCoordIndex = max(startCoordIndex, startCoordIndex + finalIonCoordCount - 1)

        var coords = [GridCoordinate]()
        if endCoordIndex < substanceCoords.coords.endIndex {
            coords = Array(substanceCoords.coords[startCoordIndex...endCoordIndex])
        }

        return AnimatingBeakerMolecules(
            molecules: BeakerMolecules(
                coords: coords,
                color: substance.color(ofPart: part),
                label: substance.chargedSymbol(ofPart: part).text.label
            ),
            fractionToDraw: LinearEquation(m: 1, x1: 0, y1: 0)
        )
    }

    var finalIonCoordCount: Int {
        Int(settings.initialIonMoleculeFraction * CGFloat(substanceCoords.coords.count))
    }

    private(set) var concentration: SubstanceValue<Equation> = .constant(ConstantEquation(value: 0))

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            substance: substance,
            substanceConcentration: concentration.substance,
            secondaryConcentration: concentration.secondaryIon
        )
    }

    var fractionOfSubstance: Equation {
        concentration.substance / (concentration.substance + concentration.secondaryIon)
    }

    var fractionOfSecondaryIon: Equation {
        concentration.secondaryIon / (concentration.substance + concentration.secondaryIon)
    }

    private var initialSubstanceConcentration: CGFloat {
        CGFloat(substanceCoords.coords.count) / CGFloat(cols * rows)
    }
}

// MARK: Input limits
extension BufferWeakSubstanceComponents {
    var minSubstanceCount: Int {
        let denom = settings.initialIonMoleculeFraction
        let numer = CGFloat(settings.minimumInitialIonCount)
        return denom == 0 ? 0 : Int(ceil(numer / denom))
    }

    /// Returns the maximum count of initial substance molecules
    ///
    /// #Derivation
    ///
    /// We start with N substance molecules. Some of these turn into ions at the end of
    /// phase 1. However, in phase 2 we turn all primary ions back into substance, by
    /// adding the same amount of secondary ions. So, we end up with the same
    /// amount of substance ions that we started with. We then add secondary ions
    /// until the number of secondary and substance molecules are the same. So, we
    /// now have 2N molecules in the beaker.
    ///
    /// In phase 3, we turn secondary ions into substance by adding primary ions, leaving
    /// `S` secondary ions behind. So, we have added `N - S` primary ions. Finally, we
    /// want to have at least `P` primary ions in the beaker, so we add a further `P` primary
    /// ions.
    ///
    /// The number of molecules in the beaker then is `2N + (N - S) + P`. This must be
    /// less than the available grid molecules, `G`, so we have:
    /// `3N - S + P < G`
    /// `N < (G - P + S) / 3`
    var maxSubstanceCount: Int {
        let gridSize = Int(settings.maxFinalBeakerConcentration * CGFloat(cols * rows))
        let numer = gridSize - settings.minimumFinalPrimaryIonCount + settings.finalSecondaryIonCount
        return numer / 3
    }

    var hasAddedEnoughSubstance: Bool {
        substanceCoords.coords.count >= minSubstanceCount
    }

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    /// Returns true if the minimum input is less than the the maximum input
    var limitsAreValid: Bool {
        minSubstanceCount < maxSubstanceCount
    }

    private var remainingCountAvailable: Int {
        max(0, maxSubstanceCount - initialSubstanceCount)
    }

    private var initialSubstanceCount: Int {
        substanceCoords.coords.count
    }
}

// MARK: Table data
extension BufferWeakSubstanceComponents {
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
            initialValue: ConstantEquation(value: 0),
            finalValue: concentration.value(for: part)
        )
    }
}

// MARK: Bar chart data
extension BufferWeakSubstanceComponents {

    var barChartMap: SubstanceValue<BarChartData> {
        SubstanceValue(
            substance: bar(.substance, equation: substanceBarEquation),
            primaryIon: bar(.primaryIon, equation: ionBarEquation),
            secondaryIon: bar(.secondaryIon, equation: ionBarEquation)
        )
    }

    var barChartData: [BarChartData] {
        barChartMap.all
    }

    var substanceBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: 1,
            y2: initialSubstanceConcentration - changeInBarHeight
        )
    }

    var ionBarEquation: Equation {
        LinearEquation(x1: 0, y1: 0, x2: 1, y2: changeInBarHeight)
    }

    private var changeInBarHeight: CGFloat {
        settings.changeInBarHeightAsFractionOfInitialSubstance * initialSubstanceConcentration
    }

    private func bar(_ part: SubstancePart, equation: Equation) -> BarChartData {
        BarChartData(
            label: substance.chargedSymbol(ofPart: part).text,
            equation: equation,
            color: substance.color(ofPart: part),
            accessibilityLabel: substance.chargedSymbol(ofPart: part).text.label,
            initialValue: nil,
            accessibilityValue: { equation.getValue(at: $0).percentage }
        )
    }
}

// MARK: Equation data
extension BufferWeakSubstanceComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            substance: substance,
            concentration: concentration,
            pH: pH
        )
    }
}

// MARK: Reaction progress
extension BufferWeakSubstanceComponents {

    func runReactionProgressReaction() {
        let numberOfMoleculesToReact = settings.reactionProgress.initialIonCount
        for _ in 0..<numberOfMoleculesToReact {
            _ = reactionProgress.startReactionFromExisting(
                consuming: .substance,
                producing: [.primaryIon, .secondaryIon]
            )
        }
    }

    private func incrementReactionProgressIfNeeded() {
        let currentMolecules = reactionProgress.moleculeCounts(ofType: .substance)
        let delta = initialSubstanceProgressCoords - currentMolecules
        if delta > 0 {
            for _ in 0..<delta {
                _ = reactionProgress.addMolecule(.substance)
            }
        }
    }

    private var substanceReactionProgressCoordCount: Equation {
        LinearEquationWithMinIntersection(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxSubstanceCount),
            y2: CGFloat(settings.reactionProgress.maxInitialSubstanceCount),
            minIntersection: CGPoint(
                x: CGFloat(minSubstanceCount),
                y: CGFloat(settings.reactionProgress.minInitialSubstanceCount)
            )
        )
    }

    private var initialSubstanceProgressCoords: Int {
        Int(substanceReactionProgressCoordCount.getValue(at: CGFloat(initialSubstanceCount)))
    }
}

// MARK: Resetting state
extension BufferWeakSubstanceComponents {

    func resetCoords() {
        substanceCoords.coords = []
        reactionProgress = BufferSharedComponents.initialReactionProgressModel(substance: substance)
        concentration = .constant(ConstantEquation(value: 0))
    }


    func resetReactionProgress() {
        progress = 0
        revertReactionProgressChartToStartOfReaction()
    } 

    /// Undoes the reaction progress
    private func revertReactionProgressChartToStartOfReaction() {
        let counts = EnumMap<SubstancePart, Int> {
            $0 == .substance ? initialSubstanceProgressCoords : 0
        }
        reactionProgress = BufferSharedComponents.reactionProgressModel(substance: substance, counts: counts)
    }
}

// TODO move this to a different file
// MARK: Settings
struct BufferComponentSettings {
    /// How much should each bar change over reaction, as a fraction of the initial substance concentration
    let changeInBarHeightAsFractionOfInitialSubstance: CGFloat

    /// The number of ion molecules after the phase 1 reaction, as a fraction of the number of substance molecules
    let initialIonMoleculeFraction: CGFloat

    /// Minimum number of ions which should be in the beaker after the phase 1 reaction has finished running
    let minimumInitialIonCount: Int

    /// Number of secondary ions which should be in the beaker at the end of the phase 3 reaction
    let finalSecondaryIonCount: Int

    /// Minimum number of primary ions which should be in the beaker at the end of the
    /// phase 3 reaction
    let minimumFinalPrimaryIonCount: Int

    /// Maximum concentration of all molecules combined at the end of phase 3
    let maxFinalBeakerConcentration: CGFloat

    let reactionProgress: ReactionProgress

    struct ReactionProgress {
        let minInitialSubstanceCount: Int
        let maxInitialSubstanceCount: Int
        let initialIonCount: Int
        let finalPrimaryIonCount: Int
        let finalSecondaryIonCount: Int
    }

    static let standard = BufferComponentSettings(
        changeInBarHeightAsFractionOfInitialSubstance: 0.1,
        initialIonMoleculeFraction: 0.1,
        minimumInitialIonCount: 2,
        finalSecondaryIonCount: 3,
        minimumFinalPrimaryIonCount: 7,
        maxFinalBeakerConcentration: 0.65,
        reactionProgress: ReactionProgress(
            minInitialSubstanceCount: 3,
            maxInitialSubstanceCount: 5,
            initialIonCount: 1,
            finalPrimaryIonCount: 2,
            finalSecondaryIonCount: 1
        )
    )

}
