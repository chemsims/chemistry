//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePreEPModel: ObservableObject {

    init(previous: TitrationStrongSubstancePreparationModel) {
        self.previous = previous
        let maxTitrant = previous.primaryIonCoords.coords.count
        self.maxTitrant = maxTitrant
        self.primaryIonCoords = AnimatingBeakerMolecules(
            molecules: previous.primaryIonCoords,
            fractionToDraw: LinearEquation(
                x1: 0,
                y1: 1,
                x2: CGFloat(maxTitrant),
                y2: 0
            )
        )
        self.calculations = TitrationStrongSubstancePreEPModelCalculations(
            previous: previous,
            substance: previous.substance,
            titrantAdded: 0,
            maxTitrant: maxTitrant,
            settings: previous.settings
        )

        self.reactionProgress = previous.copyReactionProgress()

        let substance = previous.substance
        self.reactionProgressMoleculeCount = LinearEquation(
            x1: 0,
            y1: CGFloat(previous.reactionProgress.moleculeCounts(ofType: substance.primary)),
            x2: CGFloat(maxTitrant),
            y2: 0
        )
    }

    let previous: TitrationStrongSubstancePreparationModel
    @Published var titrantAdded: Int = 0
    @Published var reactionProgress: ReactionProgressChartViewModel<PrimaryIon>

    let primaryIonCoords: AnimatingBeakerMolecules

    private let reactionProgressMoleculeCount: Equation

    let maxTitrant: Int

    var substance: AcidOrBase {
        previous.substance
    }

    var settings: TitrationSettings {
        previous.settings
    }

    private var calculations: TitrationStrongSubstancePreEPModelCalculations

    var equationData: TitrationEquationData {
        calculations.equationData
    }

    var pH: Equation {
        equationData.pValues.value(for: .hydrogen)
    }

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        calculations.molarity
    }

    var barChartData: [BarChartData] {
        calculations.barChartData
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        calculations.currentMoles
    }

    var currentVolume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        calculations.currentVolume
    }

    var barChartDataMap: EnumMap<PrimaryIon, BarChartData> {
        calculations.barChartDataMap
    }

    func resetState() {
        titrantAdded = 0
        self.calculations = TitrationStrongSubstancePreEPModelCalculations(
            previous: previous,
            substance: previous.substance,
            titrantAdded: 0,
            maxTitrant: maxTitrant,
            settings: previous.settings
        )
        self.reactionProgress = previous.copyReactionProgress()
    }
}

// MARK: - Incrementing
extension TitrationStrongSubstancePreEPModel {
    func incrementTitrant(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        withAnimation(.linear(duration: 1)) {
            titrantAdded += maxToAdd
        }

        self.calculations = TitrationStrongSubstancePreEPModelCalculations(
            previous: previous,
            substance: previous.substance,
            titrantAdded: titrantAdded,
            maxTitrant: maxTitrant,
            settings: settings
        )
        updateReactionProgress()

        // See comment in weak substance pre ep increment method
        objectWillChange.send()
    }
}

// MARK: - Input limits
extension TitrationStrongSubstancePreEPModel {
    var canAddTitrant: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughTitrant: Bool {
        !canAddTitrant
    }

    private var remainingCountAvailable: Int {
        max(0, maxTitrant - titrantAdded)
    }
}

// MARK: Reaction progress chart
extension TitrationStrongSubstancePreEPModel {

    /// Returns a distinct instance of the reaction progress model.
    func copyReactionProgress() -> ReactionProgressChartViewModel<PrimaryIon> {
        // The reason we return the original, is so that any in-flight animations are maintained
        // in the instance we return. The instance we store in `reactionProgress` has the
        // correct molecule counts, but won't complete in-flight animations.
        let original = reactionProgress
        self.reactionProgress = reactionProgress.copy()
        return original
    }

    func updateReactionProgress() {
        let currentCount = reactionProgress.moleculeCounts(ofType: substance.primary)
        let desiredCount = reactionProgressMoleculeCount.getY(at: CGFloat(titrantAdded)).roundedInt()

        let toRemove = currentCount - desiredCount
        assert(toRemove >= 0, "Expected positive molecule count to remove")

        if toRemove > 0 {
            (0..<toRemove).forEach { _ in
                _ = reactionProgress.consume(substance.primary)
            }
        }
    }
}

// MARK: Calculations Wrapper
private class TitrationStrongSubstancePreEPModelCalculations {

    init(
        previous: TitrationStrongSubstancePreparationModel,
        substance: AcidOrBase,
        titrantAdded: Int,
        maxTitrant: Int,
        settings: TitrationSettings
    ) {
        self.previous = previous
        self.substance = substance
        self.titrantAdded = titrantAdded
        self.maxTitrant = maxTitrant
        self.settings = settings
    }

    let previous: TitrationStrongSubstancePreparationModel
    let substance: AcidOrBase
    let titrantAdded: Int
    let maxTitrant: Int
    let settings: TitrationSettings

    lazy var equationData: TitrationEquationData =
        TitrationEquationData(
            substance: previous.substance,
            titrant: previous.titrant.name,
            moles: moles,
            volume: volume,
            molarity: molarity.map { ConstantEquation(value: $0) },
            concentration: concentration
        )

    lazy var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation>  =
        .init {
            switch $0 {
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            }
        }


    // Note that we want the primary ion of the substance, to vary linearly to produce
    // the correct titration curve (the pH vs. substance added chart).
    private lazy var hydrogenConcentration: Equation = {
        if substance.type.isAcid {
            return LinearEquation(
                x1: 0,
                y1: previous.currentConcentration.value(for: .hydrogen),
                x2: CGFloat(maxTitrant),
                y2: 1e-7
            )
        }

        return hydroxideConcentration.map(PrimaryIonConcentration.complementConcentration)
    }()

    private lazy var hydroxideConcentration: Equation = {
        if substance.type.isAcid {
            return hydrogenConcentration.map(PrimaryIonConcentration.complementConcentration)
        }
        return LinearEquation(
            x1: 0,
            y1: previous.currentConcentration.value(for: .hydroxide),
            x2: CGFloat(maxTitrant),
            y2: 1e-7
        )
    }()


// MARK: - Bar chart data

    lazy var barChartData: [BarChartData] = {
        let map = barChartDataMap
        return [map.value(for: .hydroxide), map.value(for: .hydrogen)]
    }()

    lazy var barChartDataMap: EnumMap<PrimaryIon, BarChartData> =
        .init(builder: barChartData)

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        BarChartData(
            label: primaryIon.chargedSymbol.text,
            equation: barChartEquation(forIon: primaryIon),
            color: primaryIon.color,
            accessibilityLabel: primaryIon.accessibilityLabel
        )
    }

    private func barChartEquation(forIon primaryIon: PrimaryIon) -> Equation {
        LinearEquation(
            x1: 0,
            y1: previous.barChartHeightEquation.value(for: primaryIon).getY(at: CGFloat(previous.substanceAdded)),
            x2: CGFloat(maxTitrant),
            y2: settings.neutralSubstanceBarChartHeight
        )
    }

// MARK: - Moles

    lazy var moles: EnumMap<TitrationEquationTerm.Moles, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: initialSubstanceMoles)
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: initialSubstanceMoles)
            case .titrant:
                return titrantVolume * ConstantEquation(value: molarity.value(for: .titrant))
            }
        }


    lazy var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> =
        moles.map { $0.getY(at: CGFloat(titrantAdded)) }


    private lazy var initialSubstanceMoles: CGFloat =
        previous.currentMoles.value(for: .substance)


// MARK: - Volume
    lazy var volume: EnumMap<TitrationEquationTerm.Volume, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: previous.currentVolume)
            case .titrant: return titrantVolume
            case .initialSubstance: return ConstantEquation(value: previous.currentVolume)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .equivalencePoint: return ConstantEquation(value: 0)
            }
        }

    lazy var currentVolume: EnumMap<TitrationEquationTerm.Volume, CGFloat> =
        volume.map { $0.getY(at: CGFloat(titrantAdded)) }

    /// Titrant volume equation in terms of titrant molecules added
    private lazy var titrantVolume: Equation =
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxTitrant),
            y2: finalTitrantVolume
        )


    private lazy var finalTitrantVolume: CGFloat =
        initialSubstanceMoles / molarity.value(for: .titrant)

// MARK: - Molarity
    lazy var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> =
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return  initialSubstanceMolarity
            case .titrant: return previous.titrantMolarity
            }
        }
    

    private lazy var initialSubstanceMolarity: CGFloat = previous.currentMolarity.value(for: .substance)
}
