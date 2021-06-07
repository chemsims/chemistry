//
// Reactions App
//

import SwiftUI
import ReactionsCore

// TODO accessibility labels
class BufferWeakAcidComponents: ObservableObject {

    init(substance: AcidOrBase) {
        self.weakAcidCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: ""
        )
        self.substance = substance
    }

    @Published var weakAcidCoords: BeakerMolecules
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

    func incrementWeakAcid(count: Int) {
        weakAcidCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: weakAcidCoords.coords,
            count: count,
            cols: cols,
            rows: rows
        )
    }

    func coordForIon(_ color: Color, index: Int) -> AnimatingBeakerMolecules {
        let startCoordIndex = index * finalIonCoordCount
        let endCoordIndex = (index + 1) * finalIonCoordCount

        var coords = [GridCoordinate]()
        if endCoordIndex < weakAcidCoords.coords.endIndex {
            coords = Array(weakAcidCoords.coords[startCoordIndex...endCoordIndex])
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

    func molecules(for substance: SubstancePart) -> BeakerMolecules {
        switch substance {
        case .substance: return weakAcidCoords
        case .primaryIon: return ionCoords[0].molecules
        case .secondaryIon: return ionCoords[1].molecules
        }
    }

    var finalIonCoordCount: Int {
        weakAcidCoords.coords.count / 5
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
        CGFloat(weakAcidCoords.coords.count) / CGFloat(cols * rows)
    }

    private var ka: CGFloat {
        7.3e-5
    }
}


class BufferComponents2: ObservableObject {

    init(
        prev: BufferWeakAcidComponents?
    ) {
        if let prev = prev {
            reactingModel = ReactingBeakerViewModel(
                initial: SubstanceValue(
                    substance: prev.weakAcidCoords,
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

        func initialCountInt(_ part: SubstancePart) -> Int {
            prev?.molecules(for: part).coords.count ?? 0
        }
        func initialCount(_ part: SubstancePart) -> CGFloat {
            CGFloat(initialCountInt(part))
        }

        let maxSubstance = (initialCountInt(.substance) + initialCountInt(.primaryIon)) - initialCountInt(.secondaryIon)
        self.maxSubstance = maxSubstance
        self.haConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialHAConcentration,
                x2: initialCount(.primaryIon),
                y2: finalHAConcentration
            ),
            underlyingRight: ConstantEquation(value: initialHAConcentration)
        )
        self.aConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: ConstantEquation(value: initialAConcentration),
            underlyingRight: LinearEquation(
                x1: initialCount(.primaryIon),
                y1: initialAConcentration,
                x2: CGFloat(maxSubstance),
                y2: finalHAConcentration
            )
        )
    }

    let reactingModel: ReactingBeakerViewModel<SubstancePart>

    @Published var substanceAdded = 0

    let haConcentration: Equation
    let aConcentration: Equation

    private let maxSubstance: Int


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
        4.14 + Log10Equation(underlying: aConcentration / haConcentration)
    }
}

class BufferComponents3: ObservableObject {
    init(
        prev: BufferComponents2?
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
