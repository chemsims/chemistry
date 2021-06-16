//
// Reactions App
//

import SwiftUI
import ReactionsCore

// TODO accessibility labels
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
            label: ""
        )
        self.substance = substance
        self.settings = settings

        self.reactionProgress = Self.initialReactionProgressModel(substance: substance)
    }

    @Published var substanceCoords: BeakerMolecules
    @Published var progress: CGFloat = 0
    var ionCoords: [AnimatingBeakerMolecules] {
        [
            coordForIon(substance.primary.color, index: 0),
            coordForIon(substance.secondary.color, index: 1)
        ]
    }

    let cols: Int
    var rows: Int
    @Published var substance: AcidOrBase {
        didSet {
            reactionProgress = Self.initialReactionProgressModel(substance: substance)
        }
    }

    private(set) var reactionProgress: ReactionProgressChartViewModel<SubstancePart>

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
    }

    func molecules(for substance: SubstancePart) -> BeakerMolecules {
        switch substance {
        case .substance: return substanceCoords
        case .primaryIon: return ionCoords[0].molecules
        case .secondaryIon: return ionCoords[1].molecules
        }
    }

    private func coordForIon(_ color: Color, index: Int) -> AnimatingBeakerMolecules {
        let startCoordIndex = index * finalIonCoordCount
        let endCoordIndex = max(startCoordIndex, startCoordIndex + finalIonCoordCount - 1)

        var coords = [GridCoordinate]()
        if endCoordIndex < substanceCoords.coords.endIndex {
            coords = Array(substanceCoords.coords[startCoordIndex...endCoordIndex])
        }

        return AnimatingBeakerMolecules(
            molecules: BeakerMolecules(
                coords: coords,
                color: color,
                label: ""
            ),
            fractionToDraw: LinearEquation(m: 1, x1: 0, y1: 0)
        )
    }

    var finalIonCoordCount: Int {
        (settings.initialIonMoleculeFraction * CGFloat(substanceCoords.coords.count)).roundedInt()
    }

    var concentration: SubstanceValue<Equation> {
        let ionConcentration = LinearEquation(x1: 0, y1: 0, x2: 1, y2: changeInConcentration)
        return SubstanceValue(
            substance: LinearEquation(
                x1: 0,
                y1: initialSubstanceConcentration,
                x2: 1,
                y2: initialSubstanceConcentration - changeInConcentration
            ),
            primaryIon: ionConcentration,
            secondaryIon: ionConcentration
        )
    }

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

    // TODO - add a test for this
    var changeInConcentration: CGFloat {
        guard let roots = QuadraticEquation.roots(
            a: 1,
            b: substance.kA,
            c: -(substance.kA * initialSubstanceConcentration)
        ) else {
            return 0
        }

        guard let validRoot = [roots.0, roots.1].first(where: {
            $0 > 0 && $0 < (initialSubstanceConcentration / 2)
        }) else {
            return 0
        }

        return validRoot
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
        max(0, maxSubstanceCount - substanceCoords.coords.count)
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
            header: substance.symbol(ofPart: part),
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
            label: substance.symbol(ofPart: part),
            equation: equation,
            color: substance.color(ofPart: part),
            accessibilityLabel: "" // TODO
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

// MARK: Reaction progress initial data
extension BufferWeakSubstanceComponents {

    private static func initialReactionProgressModel(substance: AcidOrBase) -> ReactionProgressChartViewModel<SubstancePart> {
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
                name: substance.symbol(ofPart: part),
                columnIndex: indices.value(for: part),
                initialCount: 0,
                color: substance.color(ofPart: part)
            )
        })
    }
}

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

    static let standard = BufferComponentSettings(
        changeInBarHeightAsFractionOfInitialSubstance: 0.1,
        initialIonMoleculeFraction: 0.1,
        minimumInitialIonCount: 2,
        finalSecondaryIonCount: 3,
        minimumFinalPrimaryIonCount: 7,
        maxFinalBeakerConcentration: 0.65
    )
}
