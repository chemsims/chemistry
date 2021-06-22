//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePostEPModel: ObservableObject {

    init(
        previous: TitrationStrongSubstancePreEPModel
    ) {
        self.previous = previous
        self.titrantMolecules = BeakerMolecules(
            coords: [],
            color: .purple,
            label: ""
        )
    }

    let previous: TitrationStrongSubstancePreEPModel
    @Published var titrantAdded = 0
    @Published var titrantMolecules: BeakerMolecules
}

// MARK: Incrementing titrant
extension TitrationStrongSubstancePostEPModel {
    func incrementTitrant(count: Int) {
        guard titrantAdded < maxTitrant else {
            return
        }
        titrantMolecules.coords = GridCoordinateList.addingRandomElementsTo(
            grid: titrantMolecules.coords,
            count: count,
            cols: previous.previous.cols,
            rows: previous.previous.rows
        )
        withAnimation(.linear(duration: 1)) {
            titrantAdded += count
        }
    }
}

// MARK: Bar chart data
extension TitrationStrongSubstancePostEPModel {
    var barChartData: [BarChartData] {
        [
            BarChartData(
                label: "OH",
                equation: ohConcentration,
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            ),
            BarChartData(
                label: "H",
                equation: hConcentration,
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            )
        ]
    }
}


// MARK: Equation data
extension TitrationStrongSubstancePostEPModel {

    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: previous.previous.substance,
            titrant: previous.previous.titrant,
            moles: moles,
            volume: volume,
            molarity: previous.molarity,
            concentration: concentration,
            pValues: pValues,
            kValues: previous.previous.kValues
        )
    }

    var moles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance: return previous.moles.value(for: .initialSubstance)
            case .secondary: return 0
            case .substance: return previous.moles.value(for: .substance)
            case .titrant: return titrantMoles
            }
        }
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        .init {
            switch $0 {
            case .equivalencePoint: return 0
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance: return 0
            case .substance: return previous.previous.currentVolume
            case .titrant: return titrantVolume.getY(at: CGFloat(titrantAdded))
            }
        }
    }

    var concentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return hConcentration.getY(at: CGFloat(titrantAdded))
            case .hydroxide: return ohConcentration.getY(at: CGFloat(titrantAdded))
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
            case .hydrogen: return -safeLog10(concentration.value(for: .hydrogen))
            case .hydroxide: return -safeLog10(concentration.value(for: .hydroxide))
            case .kA: return previous.substance.pKA
            case .kB: return previous.substance.pKB
            }
        }
    }

    var titrantMoles: CGFloat {
        volume.value(for: .titrant) * previous.molarity.value(for: .titrant)
    }

    var hConcentration: LinearEquation {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxTitrant),
            y2: finalHConcentration
        )
    }

    /// Returns final titrant moles to satisfy the equation:
    /// [OH] = (nkoh - nhcl) / (Vhcl + Vkoh)
    /// using the relation nkoh = Vkoh * Mkph
    var finalTitrantMoles: CGFloat {
        let titrantMolarity = previous.molarity.value(for: .titrant)
        let numer1 = finalOH * previous.previous.currentVolume * titrantMolarity
        let numer2 = previous.moles.value(for: .substance) * titrantMolarity
        let numerator = numer1 + numer2
        let denominator = titrantMolarity - finalOH

        return denominator == 0 ? 0 : numerator / denominator
    }

    var finalTitrantVolume: CGFloat {
        finalTitrantMoles / previous.molarity.value(for: .titrant)
    }

    var initialTitrantVolume: CGFloat {
        previous.volume.value(for: .titrant)
    }

    var titrantVolume: Equation {
        LinearEquation(
            x1: 0,
            y1: initialTitrantVolume,
            x2: CGFloat(maxTitrant),
            y2: finalTitrantVolume
        )
    }

    var ohConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxTitrant),
            y2: finalOH
        )
    }

    var finalOH: CGFloat {
        1e-1
    }

    var finalPOH: CGFloat {
        -safeLog10(finalOH)
    }

    var finalHConcentration: CGFloat {
        PrimaryIonConcentration.concentration(forP: 14 - finalPOH)
    }

    var currentOh: CGFloat {
        ohConcentration.getY(at: CGFloat(maxTitrant))
    }
}

// MARK: Input limits
extension TitrationStrongSubstancePostEPModel {
    var maxTitrant: Int {
        20
    }
}
