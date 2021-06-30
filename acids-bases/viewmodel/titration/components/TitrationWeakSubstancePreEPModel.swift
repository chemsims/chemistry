//
// Reactions App
//

import SwiftUI
import ReactionsCore

/// Models the titration of a weak substance before the equivalence point
///
/// # Equivalence point concentration
///
/// Say we are titrating a weak acid, then at the equivalence point we would
/// like to find the concentration of hydroxide, the substance, and the
/// secondary ion. For a concrete example, let's use KOH as the titrant
/// and HA for the substance - A would be the secondary ion in this case.
///
/// 1. Titrant volume found from n_koh_ = v_koh_ x M_koh_. We know
/// M_koh_ here, and at the EP we want n_koh_ to equal  the initial
/// moles of HA (n_hai_), which we also know.
///
/// 2. [A] is then found from [A] = n_A_ / (V_hai_ + V_koh_). The value
/// for n_A_ at the EP, is also equal to n_hai_.
///
/// 3. We find the change in concentration needed to fulfil the Kb equation,
/// assuming the initial concentrations of OH and HA are 0, and using the
/// initial concentration for A we just found:
///   `Kb =  [OH][HA]/[A]`
///   `Kb =  X^2/([A] - X)`
///
/// It is common to assume [A] - X = [A] since X is small, but in our case
/// we will say the final concentration of A is [A]_interim_ - X. Notice
/// the A marked in step 2 has been marked as _interim_ to distinguish
/// it from the final [A] which is the result of the equation in step 3.
class TitrationWeakSubstancePreEPModel: ObservableObject {
    init(previous: TitrationWeakSubstancePreparationModel) {
        let maxTitrant = previous.substanceAdded
        self.previous = previous
        self.beakerReactionModel = Self.initialReactingBeakerModel(previous: previous)
        self.maxTitrant = maxTitrant
        self.calculations = .init(
            substance: previous.substance,
            previous: previous,
            maxTitrant: maxTitrant,
            titrantAdded: 0
        )
        self.reactionProgress = previous.reactionProgressModel
        self.reactionProgressSecondaryIonCount = LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxTitrant),
            y2: CGFloat(
                previous.reactionProgressModel.moleculeCounts(ofType: .substance)
            )
        )
    }

    let previous: TitrationWeakSubstancePreparationModel

    @Published var titrantAdded = 0

    @Published var reactionProgress: ReactionProgressChartViewModel<ExtendedSubstancePart>

    var beakerReactionModel: ReactingBeakerViewModel<ExtendedSubstancePart>

    var substance: AcidOrBase {
        previous.substance
    }

    var settings: TitrationSettings {
        previous.settings
    }

    let maxTitrant: Int

    private var calculations: WeakSubstanceCalculations

    var equationData: TitrationEquationData {
        calculations.equationData
    }

    var pH: Equation {
        equationData.pValues.value(for: .hydrogen)
    }

    var currentPH: CGFloat {
        pH.getY(at: CGFloat(titrantAdded))
    }

    var barChartData: [BarChartData] {
        calculations.barChartData
    }

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        calculations.molarity
    }

    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
        calculations.concentration
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, Equation> {
        calculations.volume
    }

    var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> {
        calculations.barChartDataMap
    }

    func resetState() {
        titrantAdded = 0
        self.beakerReactionModel = Self.initialReactingBeakerModel(previous: previous)
        self.calculations = .init(
            substance: previous.substance,
            previous: previous,
            maxTitrant: maxTitrant,
            titrantAdded: 0
        )
    }

    private let reactionProgressSecondaryIonCount: Equation
}

// MARK: - Incrementing
extension TitrationWeakSubstancePreEPModel {
    func incrementTitrant(count: Int) {
        let maxToAdd = min(count, titrantCountAvailable)

        guard maxToAdd > 0 else {
            return
        }
        withAnimation(.linear(duration: 1)) {
            titrantAdded += maxToAdd
        }


        beakerReactionModel.add(
            reactant: substance.type.isAcid ? .hydroxide : .hydrogen,
            reactingWith: .substance,
            producing: .secondaryIon,
            withDuration: 1,
            count: count
        )

        // TODO - we don't actually need to recompute the calculations
        // when adding titrant. It is not a function of titrant added.
        self.calculations = .init(
            substance: previous.substance,
            previous: previous,
            maxTitrant: maxTitrant,
            titrantAdded: titrantAdded
        )
        updateReactionProgress()
    }
}

// MARK: Reaction Progress Chart
extension TitrationWeakSubstancePreEPModel {

    func copyReactionProgress() -> ReactionProgressChartViewModel<ExtendedSubstancePart> {
        let original = reactionProgress
        self.reactionProgress = reactionProgress.copy()
        return original
    }

    private func updateReactionProgress() {
        let currentCount = reactionProgress.moleculeCounts(ofType: .secondaryIon)
        let desiredCount = reactionProgressSecondaryIonCount.getY(
            at: CGFloat(titrantAdded)
        ).roundedInt()

        let toAdd = desiredCount - currentCount
        assert(toAdd >= 0, "Expected positive number of molecules to add")
        if toAdd > 0 {
            (0..<toAdd).forEach { _ in
                _ = reactionProgress.startReaction(
                    adding: reactionProgressAddingMolecule,
                    reactsWith: .substance,
                    producing: .secondaryIon
                )
            }
        }
    }

    private var reactionProgressAddingMolecule: ExtendedSubstancePart {
        substance.primary == .hydrogen ? .hydrogen : .hydroxide
    }
}

private class WeakSubstanceCalculations {

    init(
        substance: AcidOrBase,
        previous: TitrationWeakSubstancePreparationModel,
        maxTitrant: Int,
        titrantAdded: Int
    ) {
        self.substance = substance
        self.previous = previous
        self.maxTitrant = maxTitrant
        self.titrantAdded = titrantAdded
    }

    let substance: AcidOrBase
    let previous: TitrationWeakSubstancePreparationModel
    let maxTitrant: Int
    let titrantAdded: Int

    lazy var equationData: TitrationEquationData = TitrationEquationData(
        substance: substance,
        titrant: "KOH",
        moles: moles,
        volume: volume,
        molarity: molarity.map(ConstantEquation.init),
        concentration: concentration
    )

    lazy var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> = previous.kValues

    // MARK: - Concentration
    lazy var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            case .initialSecondary:
                return ConstantEquation(value: initialConcentration(of: .secondary))
            case .initialSubstance:
                return ConstantEquation(value: initialConcentration(of: .substance))
            case .secondary: return secondaryConcentration
            case .substance: return substanceConcentration
            }
        }

    private lazy var finalPrevious: EnumMap<TitrationEquationTerm.Concentration, CGFloat> =
        previous.concentration.map { $0.getY(at: 1) }

    private lazy var finalSecondaryPreKBalancing: CGFloat =
        initialSubstanceMoles / (initialSubstanceVolume + finalTitrantVolume)

    private lazy var changeInConcentrationToBalanceKRelation: CGFloat = {
        let kValue = substance.type.isAcid ? substance.kB : substance.kA
        return AcidConcentrationEquations.changeInConcentration(
            kValue: kValue,
            initialDenominatorConcentration: finalSecondaryPreKBalancing
        )
    }()

    private lazy var secondaryConcentration = LinearEquation(
        x1: 0,
        y1: initialConcentration(of: .secondary),
        x2: CGFloat(maxTitrant),
        y2: finalSecondaryPreKBalancing - changeInConcentrationToBalanceKRelation
    )

    private lazy var substanceConcentration = LinearEquation(
        x1: 0,
        y1: initialConcentration(of: .substance),
        x2: CGFloat(maxTitrant),
        y2: changeInConcentrationToBalanceKRelation
    )

    private var hydrogenConcentration: Equation {
        if substance.type.isAcid {
            return primaryIonConcentration
        }
        return complementIonConcentration
    }

    private var hydroxideConcentration: Equation {
        if substance.type.isAcid {
            return complementIonConcentration
        }
        return primaryIonConcentration
    }

    private lazy var primaryIonConcentration = LinearEquation(
        x1: 0,
        y1: initialConcentration(of: substance.primary.concentration),
        x2: CGFloat(maxTitrant),
        y2: finalPrimaryIonConcentration
    )

    private lazy var complementIonConcentration =
        primaryIonConcentration.map(PrimaryIonConcentration.complementConcentration)

    private lazy var finalComplementIonConcentration =
        changeInConcentrationToBalanceKRelation

    private lazy var finalPrimaryIonConcentration = PrimaryIonConcentration.complementConcentration(
        primaryConcentration: finalComplementIonConcentration
    )

    private func initialConcentration(of term: TitrationEquationTerm.Concentration) -> CGFloat {
        previous.concentration.value(for: term).getY(at: 1)
    }


// MARK: - Molarity
    lazy var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> =
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return previous.molarity.value(for: .substance)
            case .titrant: return previous.molarity.value(for: .titrant)
            }
        }


// MARK: - Volume
    lazy var volume: EnumMap<TitrationEquationTerm.Volume, Equation> =
        .init {
            switch $0 {
            case .equivalencePoint: return ConstantEquation(value: 0)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .substance, .initialSubstance:
                return ConstantEquation(value: initialVolume(of: .substance))
            case .titrant:
                return LinearEquation(
                    x1: 0,
                    y1: 0,
                    x2: CGFloat(maxTitrant),
                    y2: finalTitrantVolume
                )
            }
        }

    private lazy var finalTitrantVolume: CGFloat =
        initialSubstanceMoles / molarity.value(for: .titrant)

    private lazy var initialSubstanceVolume: CGFloat =
        previous.volume.value(for: .initialSubstance)

    private func initialVolume(of term: TitrationEquationTerm.Volume) -> CGFloat {
        previous.volume.value(for: term) 
    }

// MARK: - Moles
    lazy var moles: EnumMap<TitrationEquationTerm.Moles, Equation> =
        .init {
            switch $0 {
            case .initialSubstance:
                return ConstantEquation(value: initialSubstanceMoles)
            case .initialSecondary:
                return ConstantEquation(value: initialSecondaryMoles)
            case .secondary:
                return molesEquation(term: .secondary)
            case .substance:
                return initialSubstanceMoles - titrantMoles
            case .titrant: return titrantMoles
            case .hydrogen: return ConstantEquation(value: 0)
            }
        }

    private lazy var titrantMoles: Equation =
        molarity.value(for: .titrant) * volume.value(for: .titrant)

    // Returns concentration for the equation:
    // concentration = moles / (Va + Vb)
    private func molesEquation(term: TitrationEquationTerm.Concentration) -> Equation {
        let concentrationOfTerm = concentration.value(for: term)
        let vInitial = volume.value(for: .initialSubstance)
        let vTitrant = volume.value(for: .titrant)
        return concentrationOfTerm * (vInitial + vTitrant)
    }

    private lazy var initialSubstanceMoles: CGFloat = initialMoles(of: .substance)

    private lazy var initialSecondaryMoles: CGFloat = initialMoles(of: .secondary)

    private func initialMoles(of term: TitrationEquationTerm.Moles) -> CGFloat {
        previous.moles.value(for: term).getY(at: 1)
    }

    // MARK: Bar Chart Data
    lazy var barChartData: [BarChartData] = {
        let order: [ExtendedSubstancePart] = [.substance, .hydroxide, .hydrogen, .secondaryIon]
        return order.map(barChartDataMap.value)
    }()

    lazy var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> =
        .init {
            switch $0 {
            case .hydrogen: return BarChartData(
                label: PrimaryIon.hydrogen.rawValue,
                equation: barChartEquation(forPart: .hydrogen),
                color: RGB.hydrogen.color,
                accessibilityLabel: ""
            )
            case .hydroxide: return BarChartData(
                label: PrimaryIon.hydroxide.rawValue,
                equation: barChartEquation(forPart: .hydroxide),
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            )
            case .secondaryIon: return BarChartData(
                label: substance.symbol(ofPart: .secondaryIon),
                equation: barChartEquation(forPart: .secondaryIon),
                color: substance.color(ofPart: .secondaryIon),
                accessibilityLabel: ""
            )
            case .substance: return BarChartData(
                label: substance.symbol,
                equation: barChartEquation(forPart: .substance),
                color: substance.color(ofPart: .substance),
                accessibilityLabel: ""
            )
            }
        }

    private func barChartEquation(forPart part: ExtendedSubstancePart) -> Equation {
        LinearEquation(
            x1: 0,
            y1: initialBarHeight(forPart: part),
            x2: CGFloat(maxTitrant),
            y2: concentration
                .value(for: concentrationFromPart(part))
                .getY(at: CGFloat(maxTitrant))
        )
    }

    private func concentrationFromPart(_ part: ExtendedSubstancePart) -> TitrationEquationTerm.Concentration {
        switch part {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        case .secondaryIon: return .secondary
        case .substance: return .substance
        }
    }

    private func initialBarHeight(forPart part: ExtendedSubstancePart) -> CGFloat {
        previous.barChartDataMap.value(for: part).equation.getY(at: 1)
    }
}

extension TitrationWeakSubstancePreEPModel {

    static func initialReactingBeakerModel(previous: TitrationWeakSubstancePreparationModel) -> ReactingBeakerViewModel<ExtendedSubstancePart> {
        ReactingBeakerViewModel(
            initial: .init {
                switch $0 {
                case .hydrogen:
                    return BeakerMolecules(
                        coords: [],
                        color: RGB.hydrogen.color,
                        label: ""
                    )
                case .hydroxide:
                    return BeakerMolecules(
                        coords: [],
                        color: RGB.hydroxide.color,
                        label: ""
                    )
                case .secondaryIon:
                    return BeakerMolecules(
                        coords: [],
                        color: previous.substance.secondary.color,
                        label: ""
                    )
                case .substance: return previous.substanceCoords
                }
            },
            cols: previous.cols,
            rows: previous.rows
        )
    }
}
