//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferSaltComponents: ObservableObject {

    init(
        prev: BufferWeakSubstanceComponents
    ) {

        var prevSubstanceCoords = prev.substanceCoords

        let ionCoords = prev.ionCoords.flatMap { $0.molecules.coords }

        let visibleSubstanceCoords = prevSubstanceCoords.coords.filter { !ionCoords.contains($0) }
        prevSubstanceCoords.coords = visibleSubstanceCoords

        reactingModel = ReactingBeakerViewModel(
            initial: SubstanceValue(
                substance: prevSubstanceCoords,
                primaryIon: prev.ionCoords[0].molecules,
                secondaryIon: prev.ionCoords[1].molecules
            ),
            cols: prev.cols,
            rows: prev.rows
        )

        let initialSubstanceC = prev.concentration.substance.getY(at: 1)
        let finalSubstanceC = prev.concentration.substance.getY(at: 0)
        let initialSecondaryC = prev.concentration.secondaryIon.getY(at: 1)
        let initialPrimaryC = prev.concentration.primaryIon.getY(at: 1)

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
        let substanceConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialSubstanceC,
                x2: initialCount(.primaryIon),
                y2: finalSubstanceC
            ),
            underlyingRight: ConstantEquation(value: finalSubstanceC)
        )
        let secondaryConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: ConstantEquation(value: initialSecondaryC),
            underlyingRight: LinearEquation(
                x1: initialCount(.primaryIon),
                y1: initialSecondaryC,
                x2: CGFloat(maxSubstance),
                y2: finalSubstanceC
            )
        )

        let primaryConcentration = SwitchingEquation(
            thresholdX: initialCount(.primaryIon),
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialPrimaryC,
                x2: initialCount(.primaryIon),
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )
        self.concentration = SubstanceValue(
            substance: substanceConcentration,
            primaryIon: primaryConcentration,
            secondaryIon: secondaryConcentration
        )

        self.haFractionInTermsOfPH = BufferSharedComponents.SubstanceFractionFromPh(pK: pKA)
        self.aFractionInTermsOfPH = BufferSharedComponents.SecondaryIonFractionFromPh(pK: pKA)

        let xThreshold = initialCount(.primaryIon)

        // TODO - how does this class know that prev equation reaches a max at 1?
        let substanceBarChartEquation = SwitchingEquation(
            thresholdX: xThreshold,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: prev.substanceBarEquation.getY(at: 1),
                x2: xThreshold,
                y2: finalSubstanceC
            ),
            underlyingRight: ConstantEquation(value: finalSubstanceC)
        )
        let initialIonBarHeight = prev.ionBarEquation.getY(at: 1)
        let primaryIonBarChartEquation = SwitchingEquation(
            thresholdX: xThreshold,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: initialIonBarHeight,
                x2: xThreshold,
                y2: 0
            ),
            underlyingRight: ConstantEquation(value: 0)
        )
        let secondaryIonBarChartEquation = SwitchingEquation(
            thresholdX: xThreshold,
            underlyingLeft: ConstantEquation(value: initialIonBarHeight),
            underlyingRight: LinearEquation(
                x1: xThreshold,
                y1: initialIonBarHeight,
                x2: CGFloat(maxSubstance),
                y2: finalSubstanceC
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
    let previous: BufferWeakSubstanceComponents

    @Published var substanceAdded = 0

    let maxSubstance: Int

    let initialPh: CGFloat

    var substance: AcidOrBase {
        previous.substance
    }

    var settings: BufferComponentSettings {
        previous.settings
    }

    let concentration: SubstanceValue<Equation>

    var finalConcentration: SubstanceValue<CGFloat> {
        concentration.map { $0.getY(at: CGFloat(maxSubstance)) }
    }

    func incrementSalt(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        reactingModel.add(
            reactant: .secondaryIon,
            reactingWith: .primaryIon,
            producing: .substance,
            withDuration: 1,
            count: maxToAdd
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += maxToAdd
        }
    }

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            pKa: substance.pKA,
            substanceConcentration: concentration.substance,
            secondaryConcentration: concentration.secondaryIon
        )
    }

    var finalPH: CGFloat {
        pH.getY(at: CGFloat(maxSubstance))
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


// MARK: Input limits
extension BufferSaltComponents {

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughSubstance: Bool {
        !canAddSubstance
    }

    private var remainingCountAvailable: Int {
        max(0, maxSubstance - substanceAdded)
    }
}

// MARK: Equation data
extension BufferSaltComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            substance: previous.substance,
            concentration: concentration,
            pH: pH
        )
    }
}

// MARK: Table data
extension BufferSaltComponents {
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
            initialValue: ConstantEquation(value: concentration.value(for: part).getY(at: 0)),
            finalValue: concentration.value(for: part)
        )
    }
}
