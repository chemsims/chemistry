//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferSaltComponents: ObservableObject {

    init(
        prev: BufferWeakSubstanceComponents
    ) {
        reactingModel = ReactingBeakerViewModel(
            initial: SubstanceValue(
                substance: prev.substanceCoords,
                primaryIon: prev.ionCoords[0].molecules,
                secondaryIon: prev.ionCoords[1].molecules
            )
        )

        let initialHAConcentration = prev.concentration.substance.getY(at: 1)
        let finalHAConcentration = prev.concentration.substance.getY(at: 0)
        let initialAConcentration = prev.concentration.secondaryIon.getY(at: 1)
        let initialHConcentration = prev.concentration.primaryIon.getY(at: 1)


        self.previous = prev

        func initialCountInt(_ part: SubstancePart) -> Int {
            prev.molecules(for: part).coords.count
        }
        func initialCount(_ part: SubstancePart) -> CGFloat {
            CGFloat(initialCountInt(part))
        }

        let maxSubstance = (initialCountInt(.substance) + initialCountInt(.primaryIon)) - initialCountInt(.secondaryIon)
        self.maxSubstance = maxSubstance

        let haConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialHAConcentration,
                x2: initialCount(.primaryIon),
                y2: finalHAConcentration
            ),
            underlyingRight: ConstantEquation(value: initialHAConcentration)
        )
        let aConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: ConstantEquation(value: initialAConcentration),
            underlyingRight: LinearEquation(
                x1: initialCount(.primaryIon),
                y1: initialAConcentration,
                x2: CGFloat(maxSubstance),
                y2: finalHAConcentration
            )
        )

        self.haConcentration = haConcentration
        self.aConcentration = aConcentration

        self.hConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialHConcentration,
                x2: initialCount(.primaryIon),
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )

        self.haFractionInTermsOfPH = HAFractionFromPh(pka: 4.14)
        self.aFractionInTermsOfPH = AFractionFromPh(pka: 4.14)

        // TODO - how does this class know that prev equation reaches a max at 1?

        self.substanceBarChartEquation = SwitchingEquation(
            thresholdX: prev.substanceBarEquation.getY(at: 1),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialHAConcentration,
                x2: initialCount(.substance),
                y2: finalHAConcentration
            ),
            underlyingRight: ConstantEquation(value: finalHAConcentration)
        )
        let initialIonBarHeight = prev.ionBarEquation.getY(at: 1)
        self.primaryIonBarChartEquation = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialIonBarHeight,
                x2: initialCount(.primaryIon),
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )
        self.secondaryIonBarChartEquation = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: ConstantEquation(value: initialIonBarHeight),
            underlyingRight: LinearEquation(
                x1: 0,
                y1: initialIonBarHeight,
                x2: CGFloat(maxSubstance),
                y2: finalHAConcentration
            )
        )
    }

    let reactingModel: ReactingBeakerViewModel<SubstancePart>
    private let previous: BufferWeakSubstanceComponents

    @Published var substanceAdded = 0

    let haConcentration: Equation
    let aConcentration: Equation
    let hConcentration: Equation

    let maxSubstance: Int

    func incrementSalt() {
        guard substanceAdded < maxSubstance else {
            return
        }
        reactingModel.add(
            reactant: .secondaryIon,
            reactingWith: .primaryIon,
            producing: .substance,
            withDuration: 1
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += 1
        }
    }

    var ph: Equation {
        pka + Log10Equation(underlying: aConcentration / haConcentration)
    }

    var finalPH: CGFloat {
        ph.getY(at: CGFloat(maxSubstance))
    }

    var pka: CGFloat {
        4.14
    }

    var tableData: [ICETableColumn] {
        [
            column("HA", haConcentration),
            column("H", hConcentration),
            column("A", aConcentration),
        ]
    }

    private func column(_ name: String, _ equation: Equation) -> ICETableColumn {
        ICETableColumn(
            header: name,
            initialValue: ConstantEquation(value: equation.getY(at: 0)),
            finalValue: equation
        )
    }

    let haFractionInTermsOfPH: Equation
    let aFractionInTermsOfPH: Equation


    // MARK: Bar chart data
    let substanceBarChartEquation: Equation
    let primaryIonBarChartEquation: Equation
    let secondaryIonBarChartEquation: Equation

    var barChartData: [BarChartData] {
        [
            BarChartData(
                label: "", // TODO
                equation: substanceBarChartEquation,
                color: .red, // TODO
                accessibilityLabel: "" // TODO
            ),
            BarChartData(
                label: "", // TODO
                equation: primaryIonBarChartEquation,
                color: .purple, // TODO
                accessibilityLabel: "" // TODO
            ),
            BarChartData(
                label: "", // TODO
                equation: secondaryIonBarChartEquation,
                color: .orange, // TODO
                accessibilityLabel: "" // TODO
            )
        ]
    }
}


struct HAFractionFromPh: Equation {
    let pka: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        let denom = 1 + pow(10, x - pka)
        return denom == 0 ? 0 : 1 / denom
    }
}

struct AFractionFromPh: Equation {
    let pka: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        let powerTerm = pow(10, x - pka)
        let denom = powerTerm + 1
        return denom == 0 ? 0 : powerTerm / denom
    }
}

class BufferComponents3: ObservableObject {
    init(
        prev: BufferSaltComponents?
    ) {
        if let prev = prev {
            reactingModel = ReactingBeakerViewModel(
                initial: prev.reactingModel.consolidated
            )
        } else {
            reactingModel = ReactingBeakerViewModel(
                initial: .constant(BeakerMolecules(coords: [], color: .black, label: ""))
            )
        }
    }

    let reactingModel: ReactingBeakerViewModel<SubstancePart>

    func incrementStrongAcid() {
        reactingModel.add(
            reactant: .primaryIon,
            reactingWith: .secondaryIon,
            producing: .substance,
            withDuration: 1
        )
    }
}

// MARK: Equation data
extension BufferSaltComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            ka: ConstantEquation(value: 0.5),
            kb: ConstantEquation(value: 0.5),
            concentration: SubstanceValue(
                substance: haConcentration,
                primaryIon: hConcentration,
                secondaryIon: aConcentration
            ),
            pKa: ConstantEquation(value: pka),
            pH: ph,
            pOH: ConstantEquation(value: 14) - ph,
            fixedKa: 0.5,   // TODO
            fixedKb: 0.5    // TODO
        )
    }
}
