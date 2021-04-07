//
// Reactions App
//

import SwiftUI
import ReactionsCore

protocol SolubleComponentsWrapper {

    mutating func soluteEmitted(_ soluteType: SoluteType)
    mutating func soluteEnteredWater(_ soluteType: SoluteType)
    mutating func soluteDissolved(_ soluteType: SoluteType)
    mutating func reset()

    var previous: SolubleComponentsWrapper? { get }

    var components: SolubilityComponents { get }

    var initialColor: RGB { get }
    var finalColor: RGB { get }

    var timing: ReactionTiming { get }

    var counts: SoluteContainer { get set }
}

extension SolubleComponentsWrapper {
    mutating func reset() {
        counts.reset()
    }
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
    var counts: SoluteContainer
    let previous: SolubleComponentsWrapper?
    let setTime: (CGFloat) -> Void

    func soluteEnteredWater(_ soluteType: SoluteType) {
    }

    mutating func soluteEmitted(_ soluteType: SoluteType) {
        counts.didEmit()
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

    var initialColor: RGB {
        previous?.finalColor ?? .beakerLiquid
    }
    let finalColor = RGB.saturatedLiquid

    var prevComponents: SolubilityComponents? {
        previous?.components
    }
}

struct PrimarySoluteSaturatedComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, setTime: @escaping (CGFloat) -> Void) {
        self.underlyingPrevious = previous
        self.counts = SoluteContainer(maxAllowed: SolubleReactionSettings.saturatedSoluteParticlesToAdd)
        self.setTime = setTime
    }

    var counts: SoluteContainer
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

    mutating func soluteEmitted(_ soluteType: SoluteType) {
        counts.didEmit()
    }

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {
        counts.didEnterWater()
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

    private var extraDt: CGFloat {
        counts.enteredWaterFraction * (timing.end - timing.equilibrium)
    }
}

struct CommonIonComponentsWrapper: SolubleComponentsWrapper {

    let timing: ReactionTiming
    var counts: SoluteContainer
    let setColor: (Color) -> Void
    init(timing: ReactionTiming, previous: SolubleComponentsWrapper?, setColor: @escaping (Color) -> Void) {
        self.timing = timing
        self.previous = previous
        self.setColor = setColor
        self.counts = SoluteContainer(
            maxAllowed: SolubleReactionSettings.commonIonSoluteParticlesToAdd
        )
    }

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {

    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {
        counts.didDissolve()
        setColor(initialColor.color)
    }

    mutating func soluteEmitted(_ soluteType: SoluteType) {
        counts.didEmit()
    }

    let previous: SolubleComponentsWrapper?

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

    var initialColor: RGB {
        RGBEquation(
            initialX: 0,
            finalX: maxB,
            initialColor: .beakerLiquid,
            finalColor: .maxCommonIonLiquid
        ).getRgb(at: maxB * counts.dissolvedFraction)
    }

    let finalColor = RGB.maxCommonIonLiquid

}

struct AddAcidComponentsWrapper: SolubleComponentsWrapper {

    init(previous: SolubleComponentsWrapper, timing: ReactionTiming, setColor: @escaping (Color) -> Void) {
        self.counts = SoluteContainer(maxAllowed: SolubleReactionSettings.acidSoluteParticlesToAdd)
        self.underlyingPrevious = previous
        self.timing = timing
        self.setColor = setColor
    }

    var counts: SoluteContainer
    let timing: ReactionTiming
    private let setColor: (Color) -> Void

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {
        counts.didEnterWater()
    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {
        counts.didDissolve()
        setColor(initialColor.color)
    }

    mutating func soluteEmitted(_ soluteType: SoluteType) {
        counts.didEmit()
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
        self.counts = previous.counts
    }

    var previous: SolubleComponentsWrapper? {
        underlyingPrevious
    }
    private let underlyingPrevious: SolubleComponentsWrapper
    let timing: ReactionTiming
    var counts: SoluteContainer

    mutating func soluteEnteredWater(_ soluteType: SoluteType) {

    }

    mutating func soluteDissolved(_ soluteType: SoluteType) {

    }

    mutating func soluteEmitted(_ soluteType: SoluteType) {

    }

    var components: SolubilityComponents {
        underlyingPrevious.components
    }

    let deltaTime: CGFloat = 0

    var initialColor: RGB {
        underlyingPrevious.initialColor
    }

    let finalColor: RGB = .saturatedLiquid
}
