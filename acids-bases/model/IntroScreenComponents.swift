//
// Reactions App
//

import SwiftUI
import ReactionsCore

class IntroScreenComponents: ObservableObject {

    init(
        substance: AcidOrBase,
        cols: Int,
        rows: Int,
        maxSubstanceCountDivisor: Int = 3
    ) {
        self.substance = substance
        self.cols = cols
        self.rows = rows
        self.maxSubstanceCountDivisor = maxSubstanceCountDivisor
        self.underlyingCoords = AcidSubstanceBeakerCoords(substance: substance)
    }

    let substance: AcidOrBase
    let cols: Int
    var rows: Int

    private let maxSubstanceCountDivisor: Int

    @Published private(set) var substanceAdded: Int = 0
    @Published private var underlyingCoords: AcidSubstanceBeakerCoords
    @Published private(set) var fractionSubstanceAdded: CGFloat = 0

    var maxSubstanceCount: Int {
        (cols * rows) / maxSubstanceCountDivisor
    }

    // TODO - the performance of this is laggy
    func increment(count: Int) {
        guard count > 0 else {
            return
        }
        let maxToAdd = min(maxSubstanceCount - substanceAdded, count)
        withAnimation(.easeOut(duration: 1)) {
            substanceAdded += maxToAdd
            fractionSubstanceAdded = CGFloat(substanceAdded) / CGFloat(maxSubstanceCount)
        }
        underlyingCoords.update(
            substanceCount: substanceAdded,
            cols: cols,
            rows: rows
        )
    }

    func concentration(ofIon ion: PrimaryIon) -> PrimaryIonConcentration {
        if substance.primary == ion {
            return PrimaryIonConcentration.varyingPWithSubstance(
                fractionSubstanceAdded: fractionSubstanceAdded,
                finalConcentration: substance.concentrationAtMaxSubstance
            )
        }
        return PrimaryIonConcentration.addingToPh14(
            otherIonPh: concentration(ofIon: substance.primary).p
        )
    }

    var concentrations: PrimaryIonValue<PrimaryIonConcentration> {
        PrimaryIonValue(
            hydrogen: concentration(ofIon: .hydrogen),
            hydroxide: concentration(ofIon: .hydroxide)
        )
    }


    var coords: SubstanceValue<BeakerMolecules> {
        SubstanceValue(
            substanceValue: BeakerMolecules(
                coords: underlyingCoords.coords.substanceValue,
                color: .red,
                label: ""
            ),
            primaryIonValue: BeakerMolecules(
                coords: underlyingCoords.coords.primaryIonValue,
                color: .blue,
                label: ""
            ),
            secondaryIonValue: BeakerMolecules(
                coords: underlyingCoords.coords.secondaryIonValue,
                color: .purple,
                label: ""
            )
        )
    }

    var barChart: SubstanceValue<BarChartData> {
        let addedIsAboveZero = substance.substanceAddedPerIon.value > 0
        let finalIonFraction = addedIsAboveZero ? 1 / CGFloat(substance.substanceAddedPerIon.value) : 1
        let finalSubstanceFraction: CGFloat = addedIsAboveZero ? 1 : 0

        let ionEquation = LinearEquation(x1: 0, y1: 0, x2: 1, y2: finalIonFraction).within(min: 0, max: 1)

        // TODO - accessibility labels
        return SubstanceValue(
            substanceValue: BarChartData(
                label: substance.symbol,
                equation: LinearEquation(
                    m: finalSubstanceFraction,
                    x1: 0,
                    y1: 0
                ).within(min: 0, max: 1),
                color: substance.color,
                accessibilityLabel: ""
            ),
            primaryIonValue: BarChartData(
                label: substance.primary.rawValue,
                equation: ionEquation,
                color: substance.primary.color,
                accessibilityLabel: ""
            ),
            secondaryIonValue: BarChartData(
                label: substance.secondary.rawValue,
                equation: ionEquation,
                color: substance.secondary.color,
                accessibilityLabel: ""
            )
        )
    }
}

struct SubstanceValue<Value> {
    let substanceValue: Value
    let primaryIonValue: Value
    let secondaryIonValue: Value

    var all: [Value] {
        [substanceValue, primaryIonValue, secondaryIonValue]
    }
}
