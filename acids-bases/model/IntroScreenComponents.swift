//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol IntroScreenComponents {

    var cols: Int { get }
    var rows: Int { get set }
    var substance: AcidOrBase { get }

    mutating func increment(count: Int)

    func concentration(ofIon ion: PrimaryIon) -> PrimaryIonConcentration

    var concentrations: PrimaryIonValue<PrimaryIonConcentration> { get }

    var coords: SubstanceValue<BeakerMolecules> { get }

    var barChart: SubstanceValue<BarChartData> { get }

    var substanceAdded: Int { get }
}

extension IntroScreenComponents {
    var maxSubstanceCount: Int {
        (cols * rows) / 2
    }

    var fractionSubstanceAdded: CGFloat {
        CGFloat(substanceAdded) / CGFloat(maxSubstanceCount)
    }
}

struct GeneralScreenComponents: IntroScreenComponents {
    let substance: AcidOrBase
    let cols: Int
    var rows: Int

    init(substance: AcidOrBase, cols: Int, rows: Int) {
        self.substance = substance
        self.cols = cols
        self.rows = rows
        self.underlyingCoords = AcidSubstanceBeakerCoords(substance: substance)
    }

    private(set) var substanceAdded: Int = 0
    private var underlyingCoords: AcidSubstanceBeakerCoords

    mutating func increment(count: Int) {
        guard count > 0 else {
            return
        }
        let maxToAdd = min(maxSubstanceCount - substanceAdded, count)
        substanceAdded += maxToAdd
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
