//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationWeakSubstancePostEPModel: ObservableObject {
    init(previous: TitrationWeakSubstancePreEPModel) {
        let maxTitrant = 2 * previous.maxTitrant
        self.previous = previous
        self.ionMolecules = Self.initialIonMolecules(previous: previous)
        self.secondaryMolecules = Self.initialSecondaryMolecules(previous: previous)
        self.maxTitrant = maxTitrant
        self.reactionProgress = previous.copyReactionProgress()
        self.reactionProgressComplementIonCount = LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxTitrant),
            y2: CGFloat(
                previous.reactionProgress.moleculeCounts(ofType: .secondaryIon)
            )
        )
        self.calculations = Calculations(previous: previous, maxTitrant: maxTitrant)
    }

    let previous: TitrationWeakSubstancePreEPModel

    @Published var titrantAdded = 0
    @Published var ionMolecules: BeakerMolecules
    @Published var secondaryMolecules: BeakerMolecules

    @Published var reactionProgress: ReactionProgressChartViewModel<ExtendedSubstancePart>

    let reactionProgressComplementIonCount: Equation

    let maxTitrant: Int

    var settings: TitrationSettings {
        previous.settings
    }

    var substance: AcidOrBase {
        previous.substance
    }

    private var calculations: Calculations
}

// MARK: - Incrementing
extension TitrationWeakSubstancePostEPModel {
    func incrementTitrant(count: Int) {
        let maxToAdd = min(count, titrantCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        withAnimation(.linear(duration: 1)) {
            titrantAdded += maxToAdd
        }
        ionMolecules.coords = GridCoordinateList.addingRandomElementsTo(
            grid: ionMolecules.coords,
            count: maxToAdd,
            cols: previous.previous.cols,
            rows: previous.previous.rows,
            avoiding: secondaryMolecules.coords
        )
        updateReactionProgress()

        // See comment in weak substance pre ep increment method
        objectWillChange.send()
    }
}

// MARK: - Reaction progress chart
extension TitrationWeakSubstancePostEPModel {
    private func updateReactionProgress() {
        let ion: ExtendedSubstancePart = substance.primary == .hydrogen ? .hydroxide : .hydrogen
        let currentCount = reactionProgress.moleculeCounts(ofType: ion)
        let desiredCount = reactionProgressComplementIonCount.getY(
            at: CGFloat(titrantAdded)
        ).roundedInt()
        let toAdd = desiredCount - currentCount
        assert(toAdd >= 0, "Expected positive number of molecules to add")

        if toAdd > 0 {
            (0..<toAdd).forEach { _ in
                _ = reactionProgress.addMolecule(ion)
            }
        }
    }
}

// MARK: - Calculation data access
extension TitrationWeakSubstancePostEPModel {
    var equationData: TitrationEquationData {
        calculations.equationData
    }

    var barChartData: [BarChartData] {
        calculations.barChartData
    }

    var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> {
        calculations.barChartDataMap
    }

    var pH: Equation {
        equationData.pValues.value(for: .hydrogen)
    }
}

// MARK: - Calculations
private class Calculations {
    init(previous: TitrationWeakSubstancePreEPModel, maxTitrant: Int) {
        self.previous = previous
        self.maxTitrant = maxTitrant
    }

    let previous: TitrationWeakSubstancePreEPModel
    let maxTitrant: Int
    private var substance: AcidOrBase {
        previous.substance
    }
    private var settings: TitrationSettings {
        previous.settings
    }

    lazy var equationData: TitrationEquationData =
        TitrationEquationData(
            substance: substance,
            titrant: previous.previous.titrant.name,
            moles: moles,
            volume: volume,
            molarity: molarity.map { ConstantEquation(value: $0) },
            concentration: concentration
        )


    // MARK: - Concentration
    lazy var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            case .secondary, .initialSecondary:
                return ConstantEquation(value: initialConcentration(of: .secondary))
            case .substance, .initialSubstance:
                return ConstantEquation(value: initialConcentration(of: .substance))
            }
        }

    private lazy var hydrogenConcentration: Equation = {
        if !substance.type.isAcid {
            return
                primaryIonConcentration.atLeast(initialConcentration(of: .hydrogen))
        }
        return hydroxideConcentration.map(PrimaryIonConcentration.complementConcentration)
    }()

    private lazy var hydroxideConcentration: Equation = {
        if !substance.type.isAcid {
            return hydrogenConcentration.map(PrimaryIonConcentration.complementConcentration)
        }
        return primaryIonConcentration.atLeast(initialConcentration(of: .hydroxide))
    }()

    private lazy var primaryIonConcentration =
        moles.value(for: .titrant) / (volume.value(for: .titrant) + volume.value(for: .equivalencePoint))


    private lazy var finalHConcentration: CGFloat =
        PrimaryIonConcentration.concentration(forP: finalPH)

    private lazy var finalOHConcentration: CGFloat = {
        let finalPOH = 14 - finalPH
        return PrimaryIonConcentration.concentration(forP: finalPOH)
    }()

    private func initialConcentration(of part: TitrationEquationTerm.Concentration) -> CGFloat {
        previous.concentration.value(for: part).getY(at: CGFloat(previous.maxTitrant))
    }

    // MARK: - P Values
    private var finalPH: CGFloat {
        if substance.type.isAcid {
            return settings.finalMaxPValue
        }
        return 14 - settings.finalMaxPValue
    }

    private var finalPOH: CGFloat {
        14 - finalPH
    }

    // MARK: - Volume
    lazy var volume: EnumMap<TitrationEquationTerm.Volume, Equation> =
        .init {
            switch $0 {
            case .equivalencePoint: return ConstantEquation(value: equivalencePointVolume)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            case .titrant:
                return LinearEquation(
                    x1: 0,
                    y1: 0,
                    x2: CGFloat(maxTitrant),
                    y2: finalTitrantVolume
                )
            }
        }

    // Titrant volume which satisfies the equation:
    // [complement-ion] = n-titrant / (V-e + V-titrant)
    // Rearranging & substituting n-titrant = V-titrant * M-titrant, we get:
    // V-titrant = ([complement-ion]Ve)/(M-titrant - [complement-ion])
    private lazy var finalTitrantVolume: CGFloat = {
        let finalComplement = substance.type.isAcid ? finalOHConcentration : finalHConcentration
        let numer = finalComplement * equivalencePointVolume
        let denom = molarity.value(for: .titrant) - finalComplement
        return denom == 0 ? 0 : numer / denom
    }()

    private lazy var equivalencePointVolume =
        initialVolume(of: .titrant) + initialVolume(of: .initialSubstance)

    private func initialVolume(of term: TitrationEquationTerm.Volume) -> CGFloat {
        previous.volume.value(for: term).getY(at: CGFloat(previous.maxTitrant))
    }

    // MARK: Moles
    lazy var moles: EnumMap<TitrationEquationTerm.Moles, Equation> =
        .init {
            switch $0 {
            case .titrant: return molarity.value(for: .titrant) * volume.value(for: .titrant)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            }
        }

    // MARK: Molarity
    lazy var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> =
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return previous.equationData.molarity.value(for: .substance).getY(at: CGFloat(previous.titrantAdded))
            case .titrant: return previous.molarity.value(for: .titrant)
            }
        }

    // MARK: Bar chart data
    lazy var barChartData: [BarChartData] = {
        let order: [ExtendedSubstancePart] = [.substance, .hydroxide, .secondaryIon, .hydrogen]
        return order.map(barChartDataMap.value)
    }()

    lazy var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> =
        .init {
            switch $0 {
            case .hydrogen: return BarChartData(
                label: PrimaryIon.hydrogen.chargedSymbol.text,
                equation: barChartEquation(forPart: .hydrogen),
                color: RGB.hydrogen.color,
                accessibilityLabel: ""
            )
            case .hydroxide: return BarChartData(
                label: PrimaryIon.hydroxide.chargedSymbol.text,
                equation: barChartEquation(forPart: .hydroxide),
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            )
            case .secondaryIon: return BarChartData(
                label: substance.chargedSymbol(ofPart: .secondaryIon).text,
                equation: barChartEquation(forPart: .secondaryIon),
                color: substance.color(ofPart: .secondaryIon),
                accessibilityLabel: ""
            )
            case .substance: return BarChartData(
                label: substance.chargedSymbol(ofPart: .substance).text,
                equation: barChartEquation(forPart: .substance),
                color: substance.color(ofPart: .substance),
                accessibilityLabel: ""
            )
            }
        }

    private func barChartEquation(forPart part: ExtendedSubstancePart) -> Equation {
        // complement ion should end up as the same height as primary complement
        if part == substance.primary.complement.extendedSubstancePart {
            let finalHeight = concentration.value(for: .secondary).getY(at: CGFloat(maxTitrant))

            return LinearEquation(
                x1: 0,
                y1: initialBarHeight(forPart: part),
                x2: CGFloat(maxTitrant),
                y2: finalHeight
            )
        }

        return ConstantEquation(value: initialBarHeight(forPart: part))
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
        previous.barChartDataMap.value(for: part).equation.getY(at: CGFloat(previous.maxTitrant))
    }
}

extension TitrationWeakSubstancePostEPModel {
    static func initialIonMolecules(previous: TitrationWeakSubstancePreEPModel) -> BeakerMolecules {
        BeakerMolecules(
            coords: [],
            color: previous.substance.primary.complement.color,
            label: previous.substance.primary.rawValue
        )
    }

    static func initialSecondaryMolecules(previous: TitrationWeakSubstancePreEPModel) -> BeakerMolecules {
        BeakerMolecules(
            coords: previous.beakerReactionModel.consolidated.value(for: .secondaryIon).coords,
            color: previous.substance.secondary.color,
            label: previous.substance.secondary.rawValue
        )
    }
}
