//
// Reactions App
//

import SwiftUI
import ReactionsCore

// TODO accessibility labels
class BufferWeakSubstanceComponents: ObservableObject {

    init(substance: AcidOrBase) {
        self.substanceCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: ""
        )
        self.substance = substance
    }

    @Published var substanceCoords: BeakerMolecules
    @Published var progress: CGFloat = 0
    var ionCoords: [AnimatingBeakerMolecules] {
        [
            coordForIon(substance.primary.color, index: 0),
            coordForIon(substance.secondary.color, index: 1)
        ]
    }

    let cols: Int = MoleculeGridSettings.cols
    let rows: Int = MoleculeGridSettings.rows
    private let substance: AcidOrBase

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
        let endCoordIndex = (index + 1) * finalIonCoordCount

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
        substanceCoords.coords.count / 5
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

    var kaEquation: Equation {
        let numerator = concentration.primaryIon * concentration.secondaryIon
        let denom = concentration.substance
        return numerator / denom
    }

    var kb: Equation {
        10e-14 / kaEquation
    }

    var pKa: Equation {
        -1 * Log10Equation(underlying: kaEquation)
    }

    var ph: Equation {
        pKa + Log10Equation(underlying: concentration.secondaryIon / concentration.substance)
    }

    var fractionOfSubstance: Equation {
        concentration.substance / (concentration.substance + concentration.secondaryIon)
    }

    var fractionOfSecondaryIon: Equation {
        concentration.secondaryIon / (concentration.substance + concentration.secondaryIon)
    }

    private var changeInConcentration: CGFloat {
        guard let roots = QuadraticEquation.roots(a: 1, b: ka, c: -(ka * initialSubstanceConcentration)) else {
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

    private var ka: CGFloat {
        7.3e-5
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
    var barChartData: [BarChartData] {
        [
            bar(.substance, equation: substanceBarEquation),
            bar(.primaryIon, equation: ionBarEquation),
            bar(.secondaryIon, equation: ionBarEquation)
        ]
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

    // TODO - store this kind of setting somewhere
    private var changeInBarHeight: CGFloat {
        0.2 * initialSubstanceConcentration
    }

    // TODO - put the scaling factor in config somewhere
    private func bar(_ part: SubstancePart, equation: Equation) -> BarChartData {
        BarChartData(
            label: substance.symbol(ofPart: part),
            equation: equation,
            color: substance.color(ofPart: part),
            accessibilityLabel: "" // TODO
        )
    }
}
