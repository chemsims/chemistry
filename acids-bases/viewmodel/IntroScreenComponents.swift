//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol IntroScreenComponents {

    var cols: Int { get }
    var rows: Int { get set }
    var substance: AcidSubstance { get }

    mutating func increment(count: Int)

    func concentration(ofIon ion: PrimaryIon) -> PrimaryIonConcentration

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
    let substance: AcidSubstance
    let cols: Int
    var rows: Int

    init(substance: AcidSubstance, cols: Int, rows: Int) {
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
        underlyingCoords.update(substanceCount: substanceAdded, cols: cols, rows: rows)
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
        let tempData = BarChartData(
            label: "",
            equation: ConstantEquation(value: 0),
            color: .black,
            accessibilityLabel: ""
        )
        return SubstanceValue(
            substanceValue: tempData,
            primaryIonValue: tempData,
            secondaryIonValue: tempData
        )
    }
}

struct AcidSubstance: Equatable {

    init(
        name: String,
        substanceAddedPerIon: PositiveInt,
        primary: PrimaryIon,
        secondary: SecondaryIon,
        concentrationAtMaxSubstance: CGFloat
    ) {
        self.name = name
        self.substanceAddedPerIon = substanceAddedPerIon
        self.primary = primary
        self.secondary = secondary
        self.concentrationAtMaxSubstance = concentrationAtMaxSubstance
    }

    /// Display name of the substance
    let name: String

    /// Number of substance molecules added for each pair of ions which are produced
    /// - Examples:
    ///     - 0: Substance ionizes when entering liquid with no substance remaining in liquid
    ///     - 1: Substance ionizes when entering liquid, while also remaining in the liquid
    ///     - 2: Every 2nd substance ionizes when entering liquid, while also remaining in the liquid
    let substanceAddedPerIon: PositiveInt

    let primary: PrimaryIon
    let secondary: SecondaryIon
    let concentrationAtMaxSubstance: CGFloat

    /// Returns a strong acid substance
    static func strongAcid(
        name: String,
        secondaryIon: SecondaryIon
    ) -> AcidSubstance {
        AcidSubstance(
            name: name,
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1
        )
    }

    /// Returns a weak acid substance
    static func weakAcid(
        name: String,
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt
    ) -> AcidSubstance {
        AcidSubstance(
            name: name,
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value)
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

enum PrimaryIon {
    case hydrogen
    case hydroxide
}

enum SecondaryIon {
    case A
    case Cl
}
