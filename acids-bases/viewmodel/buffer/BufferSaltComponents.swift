//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferSaltComponents: ObservableObject {

    init(
        prev: BufferWeakSubstanceComponents?
    ) {
        if let prev = prev {
            reactingModel = ReactingBeakerViewModel(
                initial: SubstanceValue(
                    substance: prev.substanceCoords,
                    primaryIon: prev.ionCoords[0].molecules,
                    secondaryIon: prev.ionCoords[1].molecules
                )
            )
        } else {
            reactingModel = ReactingBeakerViewModel(initial: .constant(BeakerMolecules(coords: [], color: .black, label: "")))
        }

        let initialHAConcentration = prev?.concentration.substance.getY(at: 1) ?? 0
        let finalHAConcentration = prev?.concentration.substance.getY(at: 0) ?? 0
        let initialAConcentration = prev?.concentration.secondaryIon.getY(at: 1) ?? 0
        let initialHConcentration = prev?.concentration.primaryIon.getY(at: 1) ?? 0

        func initialCountInt(_ part: SubstancePart) -> Int {
            prev?.molecules(for: part).coords.count ?? 0
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
    }

    let reactingModel: ReactingBeakerViewModel<SubstancePart>

    @Published var substanceAdded = 0

    let haConcentration: Equation
    let aConcentration: Equation
    let hConcentration: Equation

    let maxSubstance: Int


    func incrementSalt() {
        guard substanceAdded < maxSubstance else {
            print("Added enough substance! (\(maxSubstance))")
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
}

private struct HAFractionFromPh: Equation {
    let pka: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        let denom = 1 + pow(10, x - pka)
        return denom == 0 ? 0 : 1 / denom
    }
}

private struct AFractionFromPh: Equation {
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
