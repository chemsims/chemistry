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

        let pKA = prev.substance.pKA

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

        self.haFractionInTermsOfPH = BufferSharedComponents.SubstanceFractionFromPh(pK: pKA)
        self.aFractionInTermsOfPH = BufferSharedComponents.SecondaryIonFractionFromPh(pK: pKA)

        // TODO - how does this class know that prev equation reaches a max at 1?
        let substanceBarChartEquation = SwitchingEquation(
            thresholdX: prev.substanceBarEquation.getY(at: 1),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: prev.substanceBarEquation.getY(at: 1),
                x2: initialCount(.substance),
                y2: finalHAConcentration
            ),
            underlyingRight: ConstantEquation(value: finalHAConcentration)
        )
        let initialIonBarHeight = prev.ionBarEquation.getY(at: 1)
        let primaryIonBarChartEquation = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialIonBarHeight,
                x2: initialCount(.primaryIon),
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )
        let secondaryIonBarChartEquation = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: ConstantEquation(value: initialIonBarHeight),
            underlyingRight: LinearEquation(
                x1: initialCount(.primaryIon),
                y1: initialIonBarHeight,
                x2: CGFloat(maxSubstance),
                y2: finalHAConcentration
            )
        )

        self.barChartEquations = SubstanceValue(
            substance: substanceBarChartEquation,
            primaryIon: primaryIonBarChartEquation,
            secondaryIon: secondaryIonBarChartEquation
        )

        // TODO - there should be a better way to access final pH from previous model
        self.initialPh = previous.pH.getY(at: 1)
    }

    let reactingModel: ReactingBeakerViewModel<SubstancePart>
    private let previous: BufferWeakSubstanceComponents

    @Published var substanceAdded = 0

    let haConcentration: Equation
    let aConcentration: Equation
    let hConcentration: Equation

    let maxSubstance: Int

    let initialPh: CGFloat

    var substance: AcidOrBase {
        previous.substance
    }

    var concentration: SubstanceValue<Equation> {
        SubstanceValue(
            substance: haConcentration,
            primaryIon: hConcentration,
            secondaryIon: aConcentration
        )
    }

    var finalConcentration: SubstanceValue<CGFloat> {
        concentration.map { $0.getY(at: CGFloat(maxSubstance)) }
    }

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

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            pKa: substance.pKA,
            substanceConcentration: haConcentration,
            secondaryConcentration: aConcentration
        )
    }

    var finalPH: CGFloat {
        pH.getY(at: CGFloat(maxSubstance))
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
    let barChartEquations: SubstanceValue<Equation>
    var barChartMap: SubstanceValue<BarChartData> {
        SubstanceValue(builder: { part in
            BarChartData(
                label: substance.symbol(ofPart: part),
                equation: barChartEquations.value(for: part),
                color: substance.color(ofPart: part),
                accessibilityLabel: "" // TODO
            )
        })
    }

    var barChartData: [BarChartData] {
        barChartMap.all
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
            substance: previous.substance,
            concentration: SubstanceValue(
                substance: haConcentration,
                primaryIon: hConcentration,
                secondaryIon: aConcentration
            ),
            pH: pH
        )
    }
}
