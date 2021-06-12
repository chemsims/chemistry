//
// Reactions App
//

import SwiftUI
import ReactionsCore

class BufferStrongSubstanceComponents: ObservableObject {

    init(prev: BufferSaltComponents) {
        self.previous = prev
        let initialCoords = prev.reactingModel.consolidated
        self.reactingModel = ReactingBeakerViewModel(initial: initialCoords, cols: prev.previous.cols, rows: prev.previous.rows)

        let initialSecondary = initialCoords.value(for: .secondaryIon).coords.count
        let finalSecondary = prev.settings.finalSecondaryIonCount
        let finalPrimary = prev.settings.minimumFinalPrimaryIonCount

        let maxSubstance = initialSecondary - finalSecondary + finalPrimary
        self.maxSubstance = maxSubstance

        let changeInConcentration = Self.changeInConcentration(
            forTargetPh: prev.finalPH - 1.5,
            initialPh: previous.finalPH,
            pKA: previous.substance.pKA,
            initialSubstanceConcentration: prev.finalConcentration.substance,
            initialSecondaryConcentration: previous.finalConcentration.secondaryIon
        )

        let primaryConcentration = ConstantEquation(value: 0)
        let substanceConcentration = LinearEquation(
            x1: 0,
            y1: prev.finalConcentration.substance,
            x2: CGFloat(maxSubstance),
            y2: prev.finalConcentration.substance + changeInConcentration
        )
        let secondaryConcentration = LinearEquation(
            x1: 0,
            y1: prev.finalConcentration.secondaryIon,
            x2: CGFloat(maxSubstance),
            y2: prev.finalConcentration.secondaryIon - changeInConcentration
        )

        self.concentration = SubstanceValue(
            substance: substanceConcentration,
            primaryIon: primaryConcentration,
            secondaryIon: secondaryConcentration
        )
    }

    @Published var substanceAdded = 0

    let reactingModel: ReactingBeakerViewModel<SubstancePart>
    private let previous: BufferSaltComponents

    let maxSubstance: Int
    let concentration: SubstanceValue<Equation>

    var settings: BufferComponentSettings {
        previous.settings
    }

    func incrementStrongSubstance(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        reactingModel.add(
            reactant: .primaryIon,
            reactingWith: .secondaryIon,
            producing: .substance,
            withDuration: 1,
            count: maxToAdd,
            minConsumableReactantCoords: settings.finalSecondaryIonCount
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += maxToAdd
        }
    }

    var substance: AcidOrBase {
        previous.substance
    }

    var substanceFractionInTermsOfPh: Equation {
        BufferSharedComponents.SubstanceFractionFromPh(pK: substance.pKA)
    }

    var secondaryIonFractionInTermsOfPh: Equation {
        BufferSharedComponents.SecondaryIonFractionFromPh(pK: substance.pKA)
    }

    var pH: Equation {
        BufferSharedComponents.pHEquation(
            pKa: substance.pKA,
            substanceConcentration: concentration.substance,
            secondaryConcentration: concentration.secondaryIon
        )
    }
}


// MARK: Input limits
extension BufferStrongSubstanceComponents {

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
extension BufferStrongSubstanceComponents {
    var equationData: BufferEquationData {
        BufferEquationData(
            substance: substance,
            concentration: concentration,
            pH: pH
        )
    }
}


// MARK: Bar chart data
extension BufferStrongSubstanceComponents {

    var barChartMap: SubstanceValue<BarChartData> {
        SubstanceValue(builder: { part in
            BarChartData(
                label: substance.symbol(ofPart: part),
                equation: concentration.value(for: part),
                color: substance.color(ofPart: part),
                accessibilityLabel: "" // TODO
            )
        })
    }

    var barChartData: [BarChartData] {
        barChartMap.all
    }
}

extension BufferStrongSubstanceComponents {
    private static func changeInConcentration(
        forTargetPh finalPh: CGFloat,
        initialPh: CGFloat,
        pKA: CGFloat,
        initialSubstanceConcentration: CGFloat,
        initialSecondaryConcentration: CGFloat
    ) -> CGFloat {
        let powerTerm = pow(10, finalPh - pKA)
        let numer = initialSecondaryConcentration - (initialSubstanceConcentration * powerTerm)
        let denom = 1 + powerTerm
        return denom == 0 ? 0 : numer / denom
    }
}
