//
// Reactions App
//

import SwiftUI
import ReactionsCore

protocol SolubleComponentsWrapper {

    mutating func reset()
    mutating func solutePerformed(action: SoluteParticleAction)

    var previous: SolubleComponentsWrapper? { get }

    var components: SolubilityComponents { get }

    var initialColor: RGB { get }
    var finalColor: RGB { get }

    var timing: ReactionTiming { get }

    var counts: SoluteCounter { get set }

    var ph: Equation { get }
    var solubility: Equation { get }

    var shouldGoNext: Bool { get }

    var solubilityCurve: SolublePhCurve { get set }
}

extension SolubleComponentsWrapper {
    
    mutating func reset() {
        counts.reset()
    }

    func canPerform(action: SoluteParticleAction) -> Bool {
        counts.canPerform(action: action)
    }

    var ph: Equation {
        ConstantEquation(value: solubilityCurve.startingPh)
    }

    var solubility: Equation {
        makeSolubilityEquation(timing: timing, solubilityCurve: solubilityCurve)
    }
}

struct PrimarySoluteComponentsWrapper: SolubleComponentsWrapper {

    init(
        soluteToAddForSaturation: Int,
        timing: ReactionTiming,
        previous: SolubleComponentsWrapper?,
        solubilityCurve: SolublePhCurve,
        setTime: @escaping (CGFloat) -> Void
    ) {
        self.soluteToAddForSaturation = soluteToAddForSaturation
        self.timing = timing
        self.counts = SoluteCounter(maxAllowed: soluteToAddForSaturation)
        self.solubilityCurve = solubilityCurve
        self.previous = previous
        self.setTime = setTime
    }

    let soluteToAddForSaturation: Int
    let timing: ReactionTiming
    var counts: SoluteCounter
    let previous: SolubleComponentsWrapper?
    let setTime: (CGFloat) -> Void
    var solubilityCurve: SolublePhCurve

    mutating func solutePerformed(action: SoluteParticleAction) {
        counts.didPerform(action: action)
        if action == .dissolved {
            let dt = timing.equilibrium - timing.start
            let time = timing.start + (counts.fraction(of: .dissolved) * dt)
            setTime(time)
        }
    }

    var components: SolubilityComponents {
        SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: prevComponents?.initialConcentration ?? SoluteValues.constant(0),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium,
            previousEquation: prevComponents?.equation
        )
    }

    var initialColor: RGB {
        previous?.finalColor ?? .beakerLiquid
    }
    let finalColor = RGB.saturatedLiquid

    var prevComponents: SolubilityComponents? {
        previous?.components
    }

    var shouldGoNext: Bool {
        !counts.canPerform(action: .dissolved)
    }
}

struct DemoReactionComponentsWrapper: SolubleComponentsWrapper {
    init(
        maxCount: Int,
        previous: SolubleComponentsWrapper?,
        timing: ReactionTiming,
        solubilityCurve: SolublePhCurve,
        setColor: @escaping (Color) -> Void
    ) {
        self.counts = SoluteCounter(maxAllowed: maxCount)
        self.previous = previous
        self.timing = timing
        self.solubilityCurve = solubilityCurve
        self.setColor = setColor
    }

    var counts: SoluteCounter
    let timing: ReactionTiming
    let previous: SolubleComponentsWrapper?
    let setColor: (Color) -> Void
    var solubilityCurve: SolublePhCurve

    mutating func solutePerformed(action: SoluteParticleAction) {
        counts.didPerform(action: action)
        if action == .dissolved {
            setColor(colorEquation.getRgb(at: CGFloat(counts.fraction(of: .dissolved))).color)
        }
    }

    var components: SolubilityComponents {
        SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues.constant(0),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium,
            previousEquation: previous?.components.equation
        )
    }

    let initialColor: RGB = RGB.beakerLiquid
    let finalColor: RGB = RGB.saturatedLiquid
    let shouldGoNext: Bool = false

    private var colorEquation: RGBEquation {
        RGBEquation(initialX: 0, finalX: CGFloat(counts.maxAllowed), initialColor: initialColor, finalColor: finalColor)
    }

}

struct PrimarySoluteSaturatedComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, solubilityCurve: SolublePhCurve, setTime: @escaping (CGFloat) -> Void) {
        self.underlyingPrevious = previous
        self.counts = SoluteCounter(maxAllowed: SolubleReactionSettings.saturatedSoluteParticlesToAdd)
        self.solubilityCurve = solubilityCurve
        self.setTime = setTime
    }

    var counts: SoluteCounter
    var solubilityCurve: SolublePhCurve
    private let underlyingPrevious: SolubleComponentsWrapper
    var timing: ReactionTiming {
        underlyingPrevious.timing
    }
    private let setTime: (CGFloat) -> Void

    var initialColor: RGB {
        underlyingPrevious.initialColor
    }

    var finalColor: RGB {
        underlyingPrevious.finalColor
    }

    mutating func solutePerformed(action: SoluteParticleAction) {
        counts.didPerform(action: action)
        if action == .enteredWater {
            let dt = timing.end - timing.equilibrium
            let time = timing.equilibrium + (counts.fraction(of: .enteredWater) * dt)
            setTime(time)
        }
    }

    var previous: SolubleComponentsWrapper? {
        underlyingPrevious
    }

    var components: SolubilityComponents {
        underlyingPrevious.components
    }

    var shouldGoNext: Bool {
        !counts.canPerform(action: .enteredWater)
    }
}

private func makeSolubilityEquation(timing: ReactionTiming, solubilityCurve: SolublePhCurve) -> Equation {
    let saturated = solubilityCurve.saturatedSolubility
    let superSaturated = solubilityCurve.superSaturatedSolubility
    return SwitchingEquation(
        thresholdX: timing.equilibrium,
        underlyingLeft: LinearEquation(x1: timing.start, y1: 0, x2: timing.equilibrium, y2: saturated),
        underlyingRight: LinearEquation(x1: timing.equilibrium, y1: saturated, x2: timing.end, y2: superSaturated)
    ).upTo(superSaturated)
}

struct CommonIonComponentsWrapper: SolubleComponentsWrapper {

    let timing: ReactionTiming
    var counts: SoluteCounter
    let setColor: (Color) -> Void
    init(timing: ReactionTiming, previous: SolubleComponentsWrapper?, solubilityCurve: SolublePhCurve, setColor: @escaping (Color) -> Void) {
        self.timing = timing
        self.previous = previous
        self.setColor = setColor
        self.solubilityCurve = solubilityCurve
        self.counts = SoluteCounter(
            maxAllowed: SolubleReactionSettings.commonIonSoluteParticlesToAdd
        )
    }

    mutating func solutePerformed(action: SoluteParticleAction) {
        counts.didPerform(action: action)
        if action == .dissolved {
            setColor(initialColor.color)
        }
    }

    let previous: SolubleComponentsWrapper?
    var solubilityCurve: SolublePhCurve

    private let maxB = SolubleReactionSettings.maxInitialBConcentration

    var components: SolubilityComponents {
        SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues(
                productA: 0,
                productB: maxB * counts.fraction(of: .dissolved)
            ),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium,
            previousEquation: nil
        )
    }

    var initialColor: RGB {
        RGBEquation(
            initialX: 0,
            finalX: maxB,
            initialColor: .beakerLiquid,
            finalColor: .maxCommonIonLiquid
        ).getRgb(at: maxB * counts.fraction(of: .dissolved))
    }

    let finalColor = RGB.maxCommonIonLiquid

    var shouldGoNext: Bool {
        !counts.canPerform(action: .dissolved)
    }
}

struct AddAcidComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, timing: ReactionTiming, solubilityCurve: SolublePhCurve, setColor: @escaping (Color) -> Void) {
        self.counts = SoluteCounter(maxAllowed: SolubleReactionSettings.acidSoluteParticlesToAdd)
        self.underlyingPrevious = previous
        self.timing = timing
        self.setColor = setColor
        self.solubilityCurve = solubilityCurve
    }

    var counts: SoluteCounter
    let timing: ReactionTiming
    var solubilityCurve: SolublePhCurve
    private let setColor: (Color) -> Void

    mutating func solutePerformed(action: SoluteParticleAction) {
        counts.didPerform(action: action)
        setColor(initialColor.color)
    }

    var previous: SolubleComponentsWrapper? {
        underlyingPrevious
    }
    private let underlyingPrevious: SolubleComponentsWrapper

    var components: SolubilityComponents {
        SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues(
                productA: prevEquilibriumConcentration.productA,
                productB: currentB0
            ),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium,
            previousEquation: previous?.components.equation
        )
    }

    var initialColor: RGB {
        RGBEquation(
            initialX: prevEquilibriumB,
            finalX: minB0,
            initialColor: .saturatedLiquid,
            finalColor: .maxAcidLiquid
        ).getRgb(at: currentB0)
    }

    let finalColor = RGB.saturatedLiquid

    var ph: Equation {
        LinearEquation(
            x1: timing.start,
            y1: solubilityCurve.startingPh,
            x2: timing.equilibrium,
            y2: solubilityCurve.phForAcidSaturation
        )
        .atLeast(solubilityCurve.phForAcidSaturation)
    }

    var solubility: Equation {
        ConstantEquation(value: solubilityCurve.superSaturatedSolubility)
    }

    var shouldGoNext: Bool {
        !counts.canPerform(action: .dissolved)
    }

    private var currentB0: CGFloat {
        prevEquilibriumB - (counts.fraction(of: .dissolved) * (prevEquilibriumB - minB0))
    }

    private var prevEquilibriumB: CGFloat {
        prevEquilibriumConcentration.value(for: .B)
    }

    private var prevEquilibriumConcentration: SoluteValues<CGFloat> {
        underlyingPrevious.components.equation.finalConcentration
    }

    private var minB0: CGFloat {
        0.1
    }
}

