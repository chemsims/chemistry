//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePreparationModel: ObservableObject {

    init(
        substance: AcidOrBase,
        titrant: String,
        cols: Int,
        rows: Int,
        settings: TitrationSettings
    ) {
        self.substance = substance
        self.cols = cols
        self.exactRows = CGFloat(rows)
        self.settings = settings
        self.titrant = titrant

        self.primaryIonCoords = BeakerMolecules(
            coords: [],
            color: substance.primary.color,
            label: "" // TODO
        )
    }

    var substance: AcidOrBase
    let titrant: String
    let cols: Int
    @Published var exactRows: CGFloat
    let settings: TitrationSettings

    @Published var primaryIonCoords: BeakerMolecules
    @Published var substanceAdded: Int = 0

    @Published var titrantMolarity: CGFloat = 0.4

    var rows: Int {
        GridCoordinateList.availableRows(for: exactRows)
    }

    private var gridSizeFloat: CGFloat {
        CGFloat(cols * rows)
    }
}

// MARK: Incrementing
extension TitrationStrongSubstancePreparationModel {
    func incrementSubstance(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        primaryIonCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: primaryIonCoords.coords,
            count: maxToAdd,
            cols: cols,
            rows: rows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += maxToAdd
        }
    }
}

// MARK: - Equation Data
extension TitrationStrongSubstancePreparationModel {
    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: substance,
            titrant: titrant,
            moles: moles,
            volume: volume,
            molarity: molarity,
            concentration: concentration
        )
    }
}

// MARK: - Concentration
extension TitrationStrongSubstancePreparationModel {

    /// Equation for concentration in terms of substance added
    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
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
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

    private var hydrogenConcentration: Equation {
        if substance.type.isAcid {
            return substanceConcentration
        }
        return complementaryIonConcentration
    }

    private var hydroxideConcentration: Equation {
        if substance.type.isAcid {
            return complementaryIonConcentration
        }
        return substanceConcentration
    }

    private var substanceConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxSubstance),
            y2: CGFloat(maxSubstance) / gridSizeFloat
        )
    }

    private var complementaryIonConcentration: Equation {
        substanceConcentration.map(PrimaryIonConcentration.complementConcentration)
    }
}

// MARK: - Bar chart
extension TitrationStrongSubstancePreparationModel {
    var barChartData: [BarChartData] {
        let map = barChartDataMap
        return [map.hydroxide, map.hydrogen]
    }

    var barChartDataMap: EnumMap<PrimaryIon, BarChartData> {
        .init(builder: barChartData)
    }

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        BarChartData(
            label: primaryIon.rawValue, // TODO get the charged symbol
            equation: barChartHeightEquation.value(for: primaryIon),
            color: primaryIon.color,
            accessibilityLabel: "" // TODO
        )
    }

    var barChartHeightEquation: PrimaryIonValue<Equation> {
        PrimaryIonValue(
            hydrogen: substance.primary == .hydrogen ? increasingBarEquation : decreasingBarEquation,
            hydroxide: substance.primary == .hydroxide ? increasingBarEquation : decreasingBarEquation
        )
    }

    private var increasingBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxSubstance),
            y2: settings
                .barChartHeightFromConcentration
                .getY(
                    at: substanceConcentration.getY(at: CGFloat(maxSubstance))
                )
        )
    }

    private var decreasingBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxSubstance),
            y2: 0
        )
    }
}

// MARK: - Input limits
extension TitrationStrongSubstancePreparationModel {

    /// Maximum substance count to ensure the `maxInitialStrongConcentration` is not exceeded.
    var maxSubstance: Int {
        Int(settings.maxInitialStrongConcentration * gridSizeFloat)
    }

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughSubstance: Bool {
        substanceAdded >= minSubstance
    }

    /// Minimum substance count to ensure the `minInitialStrongConcentration` is met
    private var minSubstance: Int {
        Int(ceil((settings.minInitialStrongConcentration * gridSizeFloat)))
    }

    private var remainingCountAvailable: Int {
        max(0, maxSubstance - substanceAdded)
    }
}

// MARK: - Moles
extension TitrationStrongSubstancePreparationModel {

    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .titrant: return ConstantEquation(value: 0)
            case .initialSubstance:
                return molarity.value(for: .substance) * volume.value(for: .substance)
            case .substance:
                return molarity.value(for: .substance) * volume.value(for: .substance)

            }
        }
    }


    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        moles.map { $0.getY(at: CGFloat(substanceAdded)) }
    }
}

// MARK: - Molarity
extension TitrationStrongSubstancePreparationModel {

    var molarity: EnumMap<TitrationEquationTerm.Molarity, Equation> {
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .substance: return substanceConcentration
            case .titrant: return ConstantEquation(value: titrantMolarity)
            }
        }
    }

    var currentMolarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        molarity.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

}

// MARK: - Volume
extension TitrationStrongSubstancePreparationModel {

    var volume: EnumMap<TitrationEquationTerm.Volume, Equation> {
        .init {
            switch $0 {
            case .equivalencePoint: return ConstantEquation(value: 0)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: currentVolume)
            case .substance: return ConstantEquation(value: currentVolume)
            case .titrant: return ConstantEquation(value: 0)
            }
        }
    }

    var currentVolume: CGFloat {
        settings.beakerVolumeFromRows.getY(at: exactRows)
    }
}
