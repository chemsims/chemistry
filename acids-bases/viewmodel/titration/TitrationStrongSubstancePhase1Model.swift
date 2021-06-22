//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePhase2Model: ObservableObject {
    init(phase1: TitrationStrongSubstancePhase1Model) {
        self.phase1 = phase1
    }

    @Published var substanceAdded: Int = 0

    private let phase1: TitrationStrongSubstancePhase1Model

    let initialConcentrationH: CGFloat = 0.01

    var concentrationH: Equation {
        LinearEquation(
            x1: 0,
            y1: initialConcentrationH,
            x2: substanceAtEp,
            y2: 1e-7
        )
    }

    var ph: Equation {
        SwitchingEquation(
            thresholdX: substanceAtEp,
            underlyingLeft: -1 * Log10Equation(underlying: concentrationH),
            underlyingRight:  14 + Log10Equation(underlying: concentrationOH)
        )
    }

    var concentrationOH: Equation {
        LinearEquation(
            x1: substanceAtEp,
            y1: 1e-7,
            x2: maxSubstanceFloat,
            y2: 1e-1
        )
    }

    let substanceAtEp: CGFloat = 50
    let maxSubstanceFloat: CGFloat = 100

    func incrementTitrant(count: Int) {
        guard CGFloat(substanceAdded) < (maxSubstanceFloat) else {
            return
        }
        substanceAdded += count
    }
}

class TitrationStrongSubstancePhase1Model: ObservableObject {

    init(
        cols: Int,
        rows: CGFloat,
        settings: TitrationSettings
    ) {
        self.settings = settings
        self.cols = cols
        self.rows = rows
        self.primaryIonCoords = BeakerMolecules(
            coords: [],
            color: .purple,
            label: "" // TODO label
        )
    }

    let settings: TitrationSettings
    let cols: Int
    var rows: CGFloat

    var gridRows: Int {
        GridCoordinateList.availableRows(for: rows)
    }

    @Published var primaryIonCoords: BeakerMolecules
    @Published var substanceAdded: Int = 0

    var gridCount: Int {
        gridRows * cols
    }
}

// MARK: Incrementing
extension TitrationStrongSubstancePhase1Model {
    func incrementSubstance(count: Int) {
        guard count > 0 else {
            return
        }

        primaryIonCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: primaryIonCoords.coords,
            count: count,
            cols: cols,
            rows: gridRows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += count
        }
    }
}

// MARK: Bar chart data
extension TitrationStrongSubstancePhase1Model {
    var barChartData: [BarChartData] {
        [
            BarChartData(
                label: "",
                equation: LinearEquation(
                    x1: 0,
                    y1: 0,
                    x2: CGFloat(maxSubstance),
                    y2: CGFloat(maxSubstance) / CGFloat(gridCount)
                ),
                color: .purple,
                accessibilityLabel: ""
            ),
            BarChartData(
                label: "",
                equation: ConstantEquation(value: 0),
                color: .purple,
                accessibilityLabel: ""
            )
        ]
    }
}

// MARK: Input limits
extension TitrationStrongSubstancePhase1Model {
    var maxSubstance: Int {
        20
    }
}


class TitrationWeakSubstancePhase2Model: ObservableObject {

    init(phase1: TitrationComponents) {
        self.phase1 = phase1
    }

    private let phase1: TitrationComponents

    @Published var substanceAdded: Int = 0

    func incrementSubstance(count: Int) {
        withAnimation(.linear(duration: 1)) {
            self.substanceAdded += count
        }
    }

    let kOhMolarity: CGFloat = 0.05
    let initialSubstanceConcentration: CGFloat = 0.3
    let initialSecondaryConcentration: CGFloat = 0.002
    let volumeHa: CGFloat = 0.1
    var initialSubstanceMoles: CGFloat {
        0.3 / volumeHa
    }

    var vKoh: CGFloat {
        initialSubstanceMoles / kOhMolarity
    }

    var semiFinalA: CGFloat {
        initialSubstanceMoles / (volumeHa + vKoh)
    }

    var substanceConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: substanceAtEp,
            y2: changeInConcentration
        )
    }

    var secondaryConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: initialSecondaryConcentration,
            x2: substanceAtEp,
            y2: semiFinalA - changeInConcentration
        )
    }

    var ohConcentration: Equation {
        SwitchingEquation(
            thresholdX: substanceAtEp,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: 0,
                x2: substanceAtEp,
                y2: changeInConcentration
            ),
            underlyingRight: LinearEquation(
                x1: substanceAtEp,
                y1: changeInConcentration,
                x2: maxSubstanceFloat,
                y2: 1e-1
            )
        )
    }

    var changeInConcentration: CGFloat {
        AcidConcentrationEquations.changeInConcentration(
            kValue: phase1.substance.kB,
            initialDenominatorConcentration: semiFinalA
        )
    }

    var ph: Equation {
        SwitchingEquation(
            thresholdX: substanceAtEp,
            underlyingLeft: phase1.substance.pKA + Log10Equation(underlying: secondaryConcentration / substanceConcentration),
            underlyingRight: 14 + Log10Equation(underlying: ohConcentration)
        )
    }

    private let substanceAtEp: CGFloat = 25
    let maxSubstanceFloat: CGFloat = 50
}
