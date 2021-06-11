//
// Reactions App
//

import SwiftUI
import ReactionsCore

// TODO accessibility labels
class BufferWeakSubstanceComponents: ObservableObject {

    init(
        substance: AcidOrBase,
        settings: Settings,
        cols: Int,
        rows: Int
    ) {
        self.cols = cols
        self.rows = rows
        self.substanceCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: ""
        )
        self.substance = substance
        self.settings = settings
    }

    @Published var substanceCoords: BeakerMolecules
    @Published var progress: CGFloat = 0
    var ionCoords: [AnimatingBeakerMolecules] {
        [
            coordForIon(substance.primary.color, index: 0),
            coordForIon(substance.secondary.color, index: 1)
        ]
    }

    let cols: Int
    var rows: Int
    var substance: AcidOrBase

    let settings: Settings

    func incrementSubstance(count: Int) {
        substanceCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: substanceCoords.coords,
            count: count,
            cols: cols,
            rows: rows
        )
    }

    func molecules(for substance: SubstancePart) -> BeakerMolecules {
        switch substance {
        case .substance: return substanceCoords
        case .primaryIon: return ionCoords[0].molecules
        case .secondaryIon: return ionCoords[1].molecules
        }
    }

    private func coordForIon(_ color: Color, index: Int) -> AnimatingBeakerMolecules {
        let startCoordIndex = index * finalIonCoordCount
        let endCoordIndex = max(startCoordIndex, startCoordIndex + finalIonCoordCount - 1)

        var coords = [GridCoordinate]()
        if endCoordIndex < substanceCoords.coords.endIndex {
            coords = Array(substanceCoords.coords[startCoordIndex...endCoordIndex])
        }

        return AnimatingBeakerMolecules(
            molecules: BeakerMolecules(
                coords: coords,
                color: color,
                label: ""
            ),
            fractionToDraw: LinearEquation(m: 1, x1: 0, y1: 0)
        )
    }

    var finalIonCoordCount: Int {
        (settings.fractionOfFinalIonMolecules * CGFloat(substanceCoords.coords.count)).roundedInt()
    }

    var concentration: SubstanceValue<Equation> {
        let ionConcentration = LinearEquation(x1: 0, y1: 0, x2: 1, y2: changeInConcentration)
        return SubstanceValue(
            substance: LinearEquation(
                x1: 0,
                y1: initialSubstanceConcentration,
                x2: 1,
                y2: initialSubstanceConcentration - changeInConcentration
            ),
            primaryIon: ionConcentration,
            secondaryIon: ionConcentration
        )
    }

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            pKa: substance.pKA,
            substanceConcentration: concentration.substance,
            secondaryConcentration: concentration.secondaryIon
        )
    }

    var fractionOfSubstance: Equation {
        concentration.substance / (concentration.substance + concentration.secondaryIon)
    }

    var fractionOfSecondaryIon: Equation {
        concentration.secondaryIon / (concentration.substance + concentration.secondaryIon)
    }

    private var changeInConcentration: CGFloat {
        guard let roots = QuadraticEquation.roots(
            a: 1,
            b: substance.kA,
            c: -(substance.kA * initialSubstanceConcentration)
        ) else {
            return 0
        }

        guard let validRoot = [roots.0, roots.1].first(where: {
            $0 > 0 && $0 < (initialSubstanceConcentration / 2)
        }) else {
            return 0
        }

        return validRoot
    }

    private var initialSubstanceConcentration: CGFloat {
        CGFloat(substanceCoords.coords.count) / CGFloat(cols * rows)
    }
}

// MARK: Table data
extension BufferWeakSubstanceComponents {
    var tableData: [ICETableColumn] {
        [
            column(.substance),
            column(.primaryIon),
            column(.secondaryIon)
        ]
    }

    private func column(_ part: SubstancePart) -> ICETableColumn {
        ICETableColumn(
            header: substance.symbol(ofPart: part),
            initialValue: ConstantEquation(value: 0),
            finalValue: concentration.value(for: part)
        )
    }
}

// MARK: Bar chart data
extension BufferWeakSubstanceComponents {

    var barChartMap: SubstanceValue<BarChartData> {
        SubstanceValue(
            substance: bar(.substance, equation: substanceBarEquation),
            primaryIon: bar(.primaryIon, equation: ionBarEquation),
            secondaryIon: bar(.secondaryIon, equation: ionBarEquation)
        )
    }

    var barChartData: [BarChartData] {
        barChartMap.all
    }

    var substanceBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: 1,
            y2: initialSubstanceConcentration - changeInBarHeight
        )
    }

    var ionBarEquation: Equation {
        LinearEquation(x1: 0, y1: 0, x2: 1, y2: changeInBarHeight)
    }

    private var changeInBarHeight: CGFloat {
        settings.changeInBarHeightAsFractionOfInitialSubstance * initialSubstanceConcentration
    }

    private func bar(_ part: SubstancePart, equation: Equation) -> BarChartData {
        BarChartData(
            label: substance.symbol(ofPart: part),
            equation: equation,
            color: substance.color(ofPart: part),
            accessibilityLabel: "" // TODO
        )
    }
}

// MARK: Equation data
extension BufferWeakSubstanceComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            substance: substance,
            concentration: concentration,
            pH: pH
        )
    }
}

// MARK: Settings
extension BufferWeakSubstanceComponents {
    struct Settings {
        /// How much should each bar change over reaction, as a fraction of the initial substance concentration
        let changeInBarHeightAsFractionOfInitialSubstance: CGFloat

        /// The number of ion molecules at the end of the reaction, as a fraction of the number of substance molecules
        let fractionOfFinalIonMolecules: CGFloat

        static let standard = Settings(
            changeInBarHeightAsFractionOfInitialSubstance: 0.2,
            fractionOfFinalIonMolecules: 0.15
        )
    }
}
