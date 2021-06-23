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

    var secondarySubstanceConcentration: Equation {
        primarySubstanceConcentration.map { concentration in
            let pValue = -safeLog10(concentration)
            let currentP = 14 - pValue
            return PrimaryIonConcentration.concentration(forP: currentP)
        }
    }
}

// MARK: Incrementing
extension TitrationStrongSubstancePreparationModel {
    func incrementSubstance(count: Int) {
        guard substanceAdded < maxSubstance else {
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
        BarChartData(
            label: primaryIon.rawValue, // TODO get the charged symbol
            equation: barChartHeightEquation(forPrimaryIon: primaryIon),
            color: primaryIon.color,
            accessibilityLabel: "" // TODO
        )
    }

    private func barChartHeightEquation(forPrimaryIon primaryIon: PrimaryIon) -> Equation {
        if substance.primary == primaryIon {
            return increasingBarEquation
        } else {
            return decreasingBarEquation
        }
    }

    private func barChartHeightFromSubstance(concentration: Equation) -> Equation {
        ComposedEquation(
            outer: barChartHeightFromConcentration,
            inner: concentration
        )
    }

    private var barChartHeightFromConcentration: Equation {
        SwitchingEquation(
            thresholdX: 1e-7,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: 0,
                x2: 1e-7,
                y2: settings.neutralSubstanceBarChartHeight
            ),
            underlyingRight: LinearEquation(
                x1: 1e-7,
                y1: settings.neutralSubstanceBarChartHeight,
                x2: 1,
                y2: 1
            )
        )
    }

    private var increasingBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxSubstance),
            y2: barChartHeightFromConcentration
                .getY(
                    at: primarySubstanceConcentration.getY(at: CGFloat(maxSubstance))
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

// MARK: Input limits
extension TitrationStrongSubstancePreparationModel {
    var maxSubstance: Int {
        50
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
        let c = primarySubstanceConcentration.getY(at: CGFloat(substanceAdded))
        return PrimaryIonConcentration(concentration: c)
    }

    private var complementPrimaryIonConcentration: PrimaryIonConcentration {
        let c = secondarySubstanceConcentration.getY(at: CGFloat(substanceAdded))
        return PrimaryIonConcentration(concentration: c)
    }
}
