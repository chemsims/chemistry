//
// Reactions App
//

import SwiftUI
import ReactionsCore

/// Returns log base 10 of the value if it is above 0, else returns 0
func safeLog10(_ value: CGFloat) -> CGFloat {
    value <= 0 ? 0 : log10(value)
}

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

    let substance: AcidOrBase
    let titrant: String
    let cols: Int
    @Published var exactRows: CGFloat
    let settings: TitrationSettings

    @Published var primaryIonCoords: BeakerMolecules
    @Published var substanceAdded: Int = 0

    var rows: Int {
        GridCoordinateList.availableRows(for: exactRows)
    }
}

extension TitrationStrongSubstancePreparationModel {
    var currentSubstanceConcentration: CGFloat {
        primarySubstanceConcentration.getY(at: CGFloat(substanceAdded))
    }

    var currentVolume: CGFloat {
        settings.beakerVolumeFromRows.getY(at: exactRows)
    }

    var primarySubstanceConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxSubstance),
            y2: CGFloat(maxSubstance) / CGFloat(cols * rows)
        )
    }
}

// MARK: Incrementing
extension TitrationStrongSubstancePreparationModel {
    func incrementSubstance(count: Int) {
        guard count > 0 else {
            return
        }
        primaryIonCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: primaryIonCoords.coords,
            count: count,
            cols: cols,
            rows: rows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += count
        }
    }
}

// MARK: Bar chart
extension TitrationStrongSubstancePreparationModel {
    var barChartData: [BarChartData] {
        [barChartData(forIon: .hydroxide), barChartData(forIon: .hydrogen)]
    }

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        let isZero = substance.primary != primaryIon
        return BarChartData(
            label: primaryIon.rawValue, // TODO get the charged symbol
            equation: isZero ? ConstantEquation(value: 0) : LinearEquation(
                x1: 0,
                y1: 0,
                x2: CGFloat(maxSubstance),
                y2: CGFloat(maxSubstance) / CGFloat(cols * rows)
            ),
            color: primaryIon.color,
            accessibilityLabel: "" // TODO
        )
    }
}

// MARK: Input limits
extension TitrationStrongSubstancePreparationModel {
    var maxSubstance: Int {
        20
    }
}

// MARK: Equation data
extension TitrationStrongSubstancePreparationModel {
    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: substance,
            titrant: titrant,
            moles: moles,
            volume: volume,
            molarity: molarity,
            concentration: concentration,
            pValues: pValues,
            kValues: kValues
        )
    }

    var moles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance:
                return molarity.value(for: .substance) * volume.value(for: .substance)
            case .secondary: return 0
            case .substance:
                return molarity.value(for: .substance) * volume.value(for: .substance)
            case .titrant: return 0
            }
        }
    }

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return currentSubstanceConcentration
            case .titrant: return 0
            }
        }
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        .init {
            switch $0 {
            case .equivalencePoint: return 0
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance: return currentVolume
            case .substance: return currentVolume
            case .titrant: return 0
            }
        }
    }

    var concentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return ionConcentration(forPrimaryIon: .hydrogen).concentration
            case .hydroxide: return ionConcentration(forPrimaryIon: .hydroxide).concentration
            case .initialSecondary: return 0
            case .initialSubstance: return 0
            case .secondary: return 0
            case .substance: return 0
            }
        }
    }

    var pValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return ionConcentration(forPrimaryIon: .hydrogen).p
            case .hydroxide: return ionConcentration(forPrimaryIon: .hydroxide).p
            case .kA: return substance.pKA
            case .kB: return substance.pKB
            }
        }
    }

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        .init {
            switch $0 {
            case .kA: return substance.kA
            case .kB: return substance.kB
            }
        }
    }

    private func ionConcentration(forPrimaryIon primaryIon: PrimaryIon) -> PrimaryIonConcentration {
        if substance.primary == primaryIon {
            return primaryIonConcentration
        } else {
            return complementPrimaryIonConcentration
        }
    }

    private var primaryIonConcentration: PrimaryIonConcentration {
        PrimaryIonConcentration(concentration: currentSubstanceConcentration)
    }

    private var complementPrimaryIonConcentration: PrimaryIonConcentration {
        PrimaryIonConcentration.addingToPh14(otherIonPh: primaryIonConcentration.p
        )
    }
}
