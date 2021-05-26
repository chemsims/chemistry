//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol IntroScreenComponents {

    var cols: Int { get }
    var rows: Int { get set }
    var substance: Substance { get }

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
    let substance: Substance
    let cols: Int
    var rows: Int

    private(set) var substanceAdded: Int = 0

    mutating func increment(count: Int) {
        guard count > 0 else {
            return
        }
        let maxToAdd = min(maxSubstanceCount - substanceAdded, count)
        substanceAdded += maxToAdd
    }

    func concentration(ofIon ion: PrimaryIon) -> PrimaryIonConcentration {
        if substance.primary == ion {
            return PrimaryIonConcentration.varyingPWithSubstance(
                fractionSubstanceAdded: fractionSubstanceAdded
            )
        }
        return PrimaryIonConcentration.addingToPh14(
            otherIonPh: concentration(ofIon: substance.primary).p
        )
    }


    var coords: SubstanceValue<BeakerMolecules> {
        SubstanceValue(
            substanceValue: BeakerMolecules(coords: [], color: .black, label: ""),
            primaryIonValue: BeakerMolecules(coords: [], color: .black, label: ""),
            secondaryIonValue: BeakerMolecules(coords: [], color: .black, label: "")
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

struct Substance: Equatable {
    /// Display name of the substance
    let name: String

    /// Number of substance molecules added for each pair of ions which are produced
    /// - Examples:
    ///     - 0: Substance ionizes when entering liquid with no substance remaining in liquid
    ///     - 1: Substance ionizes when entering liquid, while also remaining in the liquid
    ///     - 2: Every 2nd substance ionizes when entering liquid, while also remaining in the liquid
    let substanceAddedPerIon: Int

    let primary: PrimaryIon
    let secondary: SecondaryIon

    static func strongAcid(
        name: String,
        secondaryIon: SecondaryIon
    ) -> Substance {
        Substance(
            name: name,
            substanceAddedPerIon: 0,
            primary: .hydrogen,
            secondary: secondaryIon
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
