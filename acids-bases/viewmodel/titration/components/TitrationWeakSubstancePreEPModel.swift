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
        self.previous = previous
        self.beakerReactionModel = Self.initialReactingBeakerModel(previous: previous)
        self.maxTitrant = previous.substanceAdded
    }

    let previous: TitrationWeakSubstancePreparationModel

    @Published var titrantAdded = 0

    var beakerReactionModel: ReactingBeakerViewModel<ExtendedSubstancePart>

    var substance: AcidOrBase {
        previous.substance
    }

    var settings: TitrationSettings {
        previous.settings
    }

    let maxTitrant: Int
}

// MARK: - Equation data
extension TitrationWeakSubstancePreEPModel {
    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: substance,
            titrant: "KOH",
            moles: moles,
            volume: volume,
            molarity: molarity.map(ConstantEquation.init),
            concentration: concentration
        )
    }

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        previous.kValues
    }
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
    }
}

// MARK: - Concentration
extension TitrationWeakSubstancePreEPModel {
    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
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
    }

    private var finalPrevious: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        previous.concentration.map { $0.getY(at: 1) }
    }

    private var finalSecondaryPreKBalancing: CGFloat {
        initialSubstanceMoles / (initialSubstanceVolume + finalTitrantVolume)
    }

    private var changeInConcentrationToBalanceKRelation: CGFloat {
        let kValue = substance.type.isAcid ? substance.kB : substance.kA
        return AcidConcentrationEquations.changeInConcentration(
            kValue: kValue,
            initialDenominatorConcentration: finalSecondaryPreKBalancing
        )
    }

    private var secondaryConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: initialConcentration(of: .secondary),
            x2: CGFloat(maxTitrant),
            y2: finalSecondaryPreKBalancing - changeInConcentrationToBalanceKRelation
        )
    }

    private var substanceConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: initialConcentration(of: .substance),
            x2: CGFloat(maxTitrant),
            y2: changeInConcentrationToBalanceKRelation
        )
    }

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

    private var primaryIonConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: initialConcentration(of: substance.primary.concentration),
            x2: CGFloat(maxTitrant),
            y2: finalPrimaryIonConcentration
        )
    }

    private var complementIonConcentration: Equation {
        primaryIonConcentration.map(PrimaryIonConcentration.complementConcentration)
    }

    private var finalComplementIonConcentration: CGFloat {
        changeInConcentrationToBalanceKRelation
    }

    private var finalPrimaryIonConcentration: CGFloat {
        PrimaryIonConcentration.complementConcentration(
            primaryConcentration: finalComplementIonConcentration
        )
    }

    private func initialConcentration(of term: TitrationEquationTerm.Concentration) -> CGFloat {
        previous.concentration.value(for: term).getY(at: 1)
    }
}

// MARK: - P Values
extension TitrationWeakSubstancePreEPModel {
    var pH: Equation {
        equationData.pValues.value(for: .hydrogen)
    }

    var currentPH: CGFloat {
        pH.getY(at: CGFloat(titrantAdded))
    }
}

// MARK: - Molarity
extension TitrationWeakSubstancePreEPModel {

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return previous.molarity.value(for: .substance)
            case .titrant: return previous.molarity.value(for: .titrant)
            }
        }
    }
}


// MARK: - Volume
extension TitrationWeakSubstancePreEPModel {

    var volume: EnumMap<TitrationEquationTerm.Volume, Equation> {
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
    }

    private var finalTitrantVolume: CGFloat {
        initialSubstanceMoles / molarity.value(for: .titrant)
    }

    private var initialSubstanceVolume: CGFloat {
        previous.volume.value(for: .initialSubstance)
    }

    private func initialVolume(of term: TitrationEquationTerm.Volume) -> CGFloat {
        previous.volume.value(for: term) 
    }
}

// MARK: - Moles
extension TitrationWeakSubstancePreEPModel {

    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
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
    }

    private var titrantMoles: Equation {
        molarity.value(for: .titrant) * volume.value(for: .titrant)
    }

    // Returns concentration for the equation:
    // concentration = moles / (Va + Vb)
    private func molesEquation(term: TitrationEquationTerm.Concentration) -> Equation {
        let concentrationOfTerm = concentration.value(for: term)
        let vInitial = volume.value(for: .initialSubstance)
        let vTitrant = volume.value(for: .titrant)
        return concentrationOfTerm * (vInitial + vTitrant)
    }

    private var initialSubstanceMoles: CGFloat {
        initialMoles(of: .substance)
    }

    private var initialSecondaryMoles: CGFloat {
        initialMoles(of: .secondary)
    }

    private func initialMoles(of term: TitrationEquationTerm.Moles) -> CGFloat {
        previous.moles.value(for: term).getY(at: 1)
    }
}

extension TitrationWeakSubstancePreEPModel {
    var barChartData: [BarChartData] {
        let order: [ExtendedSubstancePart] = [.substance, .hydroxide, .hydrogen, .secondaryIon]
        return order.map(barChartDataMap.value)
    }

    var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> {
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
