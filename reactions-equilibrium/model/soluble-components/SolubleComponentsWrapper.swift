//
// Reactions App
//

import SwiftUI

protocol SolubleComponentsWrapper {

    mutating func soluteEnteredWater(_ soluteType: SoluteType)
    mutating func soluteDissolved(_ soluteType: SoluteType)

    var previous: SolubleComponentsWrapper? { get }

    var components: SolubilityComponents { get }

    var liquidColor: RGBEquation { get }
}

struct PrimarySoluteComponentsWrapper: SolubleComponentsWrapper {

    init(
        soluteToAddForSaturation: Int,
        timing: ReactionTiming,
        previous: SolubleComponentsWrapper?,
        setTime: @escaping (CGFloat) -> Void
    ) {
        self.soluteToAddForSaturation = soluteToAddForSaturation
        self.timing = timing
        self.counts = SoluteContainer(maxAllowed: soluteToAddForSaturation)
        self.previous = previous
        self.setTime = setTime
    }

    let soluteToAddForSaturation: Int
    let timing: ReactionTiming
    let counts: SoluteContainer
    let previous: SolubleComponentsWrapper?
    let setTime: (CGFloat) -> Void

    func soluteEnteredWater(_ soluteType: SoluteType) {
    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {
        counts.didDissolve()
        let dt = timing.equilibrium - timing.start
        let time = timing.start + (counts.dissolvedFraction * dt)

        setTime(time)
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

    var liquidColor: RGBEquation {
        RGBEquation(
            initialX: timing.start,
            finalX: timing.equilibrium,
            initialColor: .beakerLiquid,
            finalColor: .saturatedLiquid
        )
    }

    var prevComponents: SolubilityComponents? {
        previous?.components
    }
}

struct PrimarySoluteSaturatedComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, timing: ReactionTiming, setTime: @escaping (CGFloat) -> Void) {
        self.underlyingPrevious = previous
        self.counts = SoluteContainer(maxAllowed: SolubleReactionSettings.saturatedSoluteParticlesToAdd)
        self.timing = timing
        self.setTime = setTime
    }

    private let counts: SoluteContainer
    private let underlyingPrevious: SolubleComponentsWrapper
    private let timing: ReactionTiming
    private let setTime: (CGFloat) -> Void

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {
        counts.didEmit()
        let dt = timing.end - timing.equilibrium
        let time = timing.equilibrium + (counts.enteredWaterFraction * dt)
        setTime(time)
    }

    mutating func soluteDissolved(_ soluteType: SoluteType) { }

    var previous: SolubleComponentsWrapper? {
        underlyingPrevious
    }

    var components: SolubilityComponents {
        underlyingPrevious.components
    }

    var liquidColor: RGBEquation {
        underlyingPrevious.liquidColor
    }

    private var extraDt: CGFloat {
        counts.enteredWaterFraction * (timing.end - timing.equilibrium)
    }
}

struct CommonIonComponentsWrapper: SolubleComponentsWrapper {

    let timing: ReactionTiming
    let counts: SoluteContainer

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {

    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {
        counts.didDissolve()
    }

    let previous: SolubleComponentsWrapper? = nil

    private let maxB = SolubleReactionSettings.maxInitialBConcentration

    var components: SolubilityComponents {
        SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues(
                productA: 0,
                productB: maxB * counts.dissolvedFraction
            ),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium,
            previousEquation: nil
        )
    }

    var liquidColor: RGBEquation {
        RGBEquation(
            initialX: 0,
            finalX: maxB,
            initialColor: .beakerLiquid,
            finalColor: .maxCommonIonLiquid
        )
    }
}

struct AddAcidComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, timing: ReactionTiming) {
        self.counts = SoluteContainer(maxAllowed: SolubleReactionSettings.acidSoluteParticlesToAdd)
        self.underlyingPrevious = previous
        self.timing = timing
    }

    let counts: SoluteContainer
    let timing: ReactionTiming

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {
        counts.didEnterWater()
    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {
        counts.didDissolve()
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

    var liquidColor: RGBEquation {
        RGBEquation(
            initialX: prevEquilibriumB,
            finalX: minB0,
            initialColor: .saturatedLiquid,
            finalColor: .maxAcidLiquid
        )

    }

    private var currentB0: CGFloat {
        prevEquilibriumB - (counts.dissolvedFraction * (prevEquilibriumB - minB0))
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

struct RunAcidReactionComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, timing: ReactionTiming) {
        self.underlyingPrevious = previous
        self.timing = timing
    }

    var previous: SolubleComponentsWrapper? {
        underlyingPrevious
    }
    private let underlyingPrevious: SolubleComponentsWrapper
    private let timing: ReactionTiming

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {

    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {

    }

    var components: SolubilityComponents {
        underlyingPrevious.components
    }

    let deltaTime: CGFloat = 0

    var liquidColor: RGBEquation {
        RGBEquation(
            initialX: timing.start,
            finalX: timing.equilibrium,
            initialColor: underlyingPrevious.liquidColor.finalColor,
            finalColor: .saturatedLiquid
        )
    }
}
