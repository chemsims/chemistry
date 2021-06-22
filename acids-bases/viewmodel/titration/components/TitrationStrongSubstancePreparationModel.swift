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
        CGFloat(substanceAdded) / CGFloat(cols * rows)
    }

    var currentVolume: CGFloat {
        settings.beakerVolumeFromRows.getY(at: exactRows)
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

    private var moles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
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

    private var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return currentSubstanceConcentration
            case .titrant: return 0
            }
        }
    }

    private var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
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

    private var concentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen:
                return substance.primary == .hydrogen ? currentSubstanceConcentration : 0
            case .hydroxide:
                return substance.primary == .hydroxide ? currentSubstanceConcentration : 0
            case .initialSecondary: return 0
            case .initialSubstance: return 0
            case .secondary: return 0
            case .substance: return 0
            }
        }
    }

    private var pValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        // TODO put this somewhere common
        func safeLog(_ value: CGFloat) -> CGFloat {
            value <= 0 ? 0 : log10(value)
        }
        return .init {
            switch $0 {
            case .hydrogen: return safeLog(concentration.value(for: .hydrogen))
            case .hydroxide: return safeLog(concentration.value(for: .hydroxide))
            case .kA: return substance.pKA
            case .kB: return substance.pKB
            }
        }
    }

    private var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        .init {
            switch $0 {
            case .kA: return substance.kA
            case .kB: return substance.kB
            }
        }
    }
}
