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

    var substance: AcidOrBase {
        didSet {
            underlyingCoords.substance = substance
        }
    }
    let cols: Int
    var rows: Int

    private let maxSubstanceCountDivisor: Int

    @Published private(set) var substanceAdded: Int = 0
    @Published private var underlyingCoords: AcidSubstanceBeakerCoords
    @Published private(set) var fractionSubstanceAdded: CGFloat = 0

    var maxSubstanceCount: Int {
        (cols * rows) / maxSubstanceCountDivisor
    }

    var canAddSubstance: Bool {
        substanceAdded < maxSubstanceCount
    }

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
            substance: BeakerMolecules(
                coords: underlyingCoords.coords.substance,
                color: substance.color,
                label: substance.symbol.label
            ),
            primaryIon: BeakerMolecules(
                coords: underlyingCoords.coords.primaryIon,
                color: substance.primary.color,
                label: substance.chargedSymbol(ofPart: .primaryIon).text.label
            ),
            secondaryIon: BeakerMolecules(
                coords: underlyingCoords.coords.secondaryIon,
                color: substance.secondary.color,
                label: substance.chargedSymbol(ofPart: .secondaryIon).text.label
            )
        )
    }

    var barChart: SubstanceValue<BarChartData> {
        let addedIsAboveZero = substance.substanceAddedPerIon.value > 0
        let finalSubstanceFraction: CGFloat = addedIsAboveZero ? 1 : 0

        return SubstanceValue(
            substance: barChartData(
                ofPart: .substance,
                equation: LinearEquation(
                    m: finalSubstanceFraction,
                    x1: 0,
                    y1: 0
                ).within(min: 0, max: 1)
            ),
            primaryIon: barChartData(
                ofPart: .primaryIon,
                equation: ionFraction
            ),
            secondaryIon: barChartData(
                ofPart: .secondaryIon,
                equation: ionFraction
            )
        )
    }

    private func barChartData(
        ofPart part: SubstancePart,
        equation: Equation
    ) -> BarChartData {
        BarChartData(
            label: substance.chargedSymbol(ofPart: part).text,
            equation: equation,
            color: substance.color(ofPart: part),
            accessibilityLabel: substance.chargedSymbol(ofPart: part).text.label,
            initialValue: nil,
            accessibilityValue: { equation.getValue(at: $0).percentage }
        )
    }

    private var ionFraction: Equation {
        let addedIsAboveZero = substance.substanceAddedPerIon.value > 0
        let finalIonFraction = addedIsAboveZero ? 1 / CGFloat(substance.substanceAddedPerIon.value) : 1
        return LinearEquation(x1: 0, y1: 0, x2: 1, y2: finalIonFraction).within(min: 0, max: 1)
    }

    private var hConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: 1,
            y2: substance.type.isAcid ? 1e-1 : 1e-14
        )
    }

    var phLine: Equation {
        if substance.primary == .hydrogen {
            return PrimaryPhEquation(substance: substance)
        }
        return ComplementPhEquation(substance: substance)
    }
}

private struct PrimaryPhEquation: Equation {
    let substance: AcidOrBase

    func getValue(at x: CGFloat) -> CGFloat {
        let p = PrimaryIonConcentration.varyingPWithSubstance(
            fractionSubstanceAdded: x.within(min: 0, max: 1),
            finalConcentration: substance.concentrationAtMaxSubstance
        ).p.within(min: 0, max: 14)
        return p
    }
}

private struct ComplementPhEquation: Equation {
    let substance: AcidOrBase

    func getValue(at x: CGFloat) -> CGFloat {
        let otherP = PrimaryPhEquation(substance: substance).getValue(at: x)
        return 14 - otherP
    }
}


// MARK: Restoring state
extension IntroScreenComponents {

    var state: State {
        State(
            rows: rows,
            substance: substance,
            substanceAdded: substanceAdded,
            coords: underlyingCoords,
            fractionSubstanceAdded: fractionSubstanceAdded
        )
    }

    func restore(from state: State) {
        self.rows = state.rows
        self.substance = state.substance
        self.substanceAdded = state.substanceAdded
        self.underlyingCoords = state.coords
        self.fractionSubstanceAdded = state.fractionSubstanceAdded
    }

    struct State {
        let rows: Int
        let substance: AcidOrBase
        let substanceAdded: Int
        let coords: AcidSubstanceBeakerCoords
        let fractionSubstanceAdded: CGFloat
    }

    func reset() {
        self.substanceAdded = 0
        self.fractionSubstanceAdded = 0
        self.underlyingCoords.reset()
    }
}
