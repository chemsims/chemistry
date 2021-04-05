//
// Reactions App
//

import SwiftUI
import ReactionsCore


enum SoluteType {
    case primary, commonIon, acid

    var image: String {
        switch self {
        case .primary: return "soluteAB"
        case .commonIon: return "soluteCB"
        case .acid: return "acidH"
        }
    }
}

class SolubilityViewModel: ObservableObject {

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0.5
    @Published var inputState = SolubilityInputState.none
    @Published var activeSolute: SoluteType?

    @Published var currentTime: CGFloat = 0
    
    @Published var shouldRemoveSolute = false
    @Published var shouldAddRemovedSolute = false

    @Published var beakerSoluteState = BeakerSoluteState.addingSolute(type: .primary, clearPrevious: false)

    @Published var chartOffset: CGFloat = 0

    var soluteCounts: SoluteContainer
    
    @Published var components: SolubilityComponents

    init() {
        let firstTiming = SolubleReactionSettings.firstReactionTiming
        self.timing = firstTiming
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.soluteCounts = SoluteContainer(maxAllowed: 0)
        self.components = SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues.constant(0),
            startTime: firstTiming.start,
            equilibriumTime: firstTiming.equilibrium,
            previousEquation: nil
        )
        self.navigation = SolubilityNavigationModel.model(model: self)
        self.soluteCounts.maxAllowed = self.soluteToAddForSaturation
    }

    var timing: ReactionTiming {
        didSet {
            setComponents()
        }
    }

    let shakingModel: SoluteBeakerShakingViewModel

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func onParticleEmit(soluteType: SoluteType) {
        soluteCounts.didEmit()
    }

    func onParticleWaterEntry(soluteType: SoluteType) {
        switch inputState {
        case .addSaturatedSolute where soluteType == .primary:
            saturatedSoluteEnteredWater()
        case .addSolute(type: soluteType) where soluteType == .acid:
            acidEnteredWater()
        default: break
        }
    }

    func onDissolve(soluteType: SoluteType) {
        guard inputState == .addSolute(type: soluteType) else {
            return
        }

        soluteCounts.didDissolve()
        switch soluteType {
        case .primary: primarySoluteDissolved()
        case .commonIon: commonIonSoluteDissolved()
        case .acid: break
        }
    }

    private func saturatedSoluteEnteredWater() {
        withAnimation(.linear(duration: Double(saturatedDt))) {
            currentTime += saturatedDt
        }
    }

    private func acidEnteredWater() {
        if let initB0 = components.previousEquation?.finalConcentration.value(for: .B) {
            let dc = (0.75 * initB0) / CGFloat(SolubleReactionSettings.acidSoluteParticlesToAdd)
            withAnimation(.easeOut(duration: 0.5)) {
                extraB0 -= dc
            }
        }
    }

    private func primarySoluteDissolved() {
        let newTime = soluteCounts.dissolvedFraction * (timing.equilibrium - timing.start)
        let dt = newTime - currentTime

        withAnimation(.linear(duration: Double(dt))) {
            currentTime = newTime
        }
        if !soluteCounts.canDissolve {
            navigation?.next()
            shakingModel.shouldAddParticle = false
        }
    }

    private func commonIonSoluteDissolved() {
        withAnimation(.easeOut(duration: 0.5)) {
            extraB0 = SolubleReactionSettings.maxInitialBConcentration * soluteCounts.dissolvedFraction
        }
    }

    var extraB0: CGFloat = 0 {
        didSet {
            setComponents()
        }
    }

    func startShaking() {
        shakingModel.shake.position.start()
    }

    func stopShaking() {
        shakingModel.shake.position.stop()
    }

    var canEmit: Bool {
        inputState.isAddingSolute && soluteCounts.canEmit
    }

    var waterColor2: Color {
        let initialRGB = initialWaterColor
        let finalRGB = RGB.saturatedLiquid
        let fraction = (currentTime - components.startTime) / (components.equilibriumTime - components.startTime)
        let boundFraction = fraction.within(min: 0, max: 1)
        return RGB.interpolate(initialRGB, finalRGB, fraction: Double(boundFraction)).color
    }

    private var initialWaterColor: RGB {
        let initialRGB = RGB.beakerLiquid
        let finalRGB = RGB.maxCommonIon
        let fraction = min(1, extraB0 / SolubleReactionSettings.maxInitialBConcentration)
        return RGB.interpolate(initialRGB, finalRGB, fraction: Double(fraction))
    }

    var soluteToAddForSaturation: Int {
        let equation = LinearEquation(x1: 0, y1: 10, x2: 1, y2: 20)
        return equation.getY(at: waterHeightFactor).roundedInt()
    }

    private var saturatedDt: CGFloat {
        (timing.end - timing.equilibrium) / CGFloat(SolubleReactionSettings.saturatedSoluteParticlesToAdd)
    }

    private func setComponents() {
        self.components = SolubilityComponents(
            equilibriumConstant: components.equilibriumConstant,
            initialConcentration: SoluteValues(
                productA: (components.previousEquation?.finalConcentration.value(for: .A) ?? 0),
                productB: (components.previousEquation?.finalConcentration.value(for: .B) ?? 0) + extraB0
            ),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium,
            previousEquation: components.previousEquation
        )
    }


    var waterColor: Color {
        switch reactionPhase {
        case .primarySolute: return primarySoluteColor
        case .commonIon: return commonIonReactionColor
        case .acidity: return acidIonReactionColor
        }
    }

    var reactionPhase: SolubleReactionPhase = .primarySolute

    private var primarySoluteColor: Color {
        ReactionTimingColor(
            timing: timing,
            currentTime: currentTime,
            initialColor: .beakerLiquid,
            finalColor: .saturatedLiquid
        ).rgb.color
    }

    private var commonIonReactionColor: Color {
        ReactionTimingColor(
            timing: timing,
            currentTime: currentTime,
            initialColor: ColorInterpolator(
                initialValue: 0,
                finalValue: SolubleReactionSettings.maxInitialBConcentration,
                currentValue: extraB0,
                initialColor: .beakerLiquid,
                finalColor: .maxCommonIon
            ).rgb,
            finalColor: .saturatedLiquid
        ).rgb.color
    }

    private var acidIonReactionColor: Color {
        ReactionTimingColor(
            timing: timing,
            currentTime: currentTime,
            initialColor: ColorInterpolator(
                initialValue: components.previousEquation?.finalConcentration.value(for: .B) ?? 0,
                finalValue: 0,
                currentValue: components.initialConcentration.value(for: .B),
                initialColor: .saturatedLiquid,
                finalColor: RGB(r: 255, g: 0, b: 0)
            ).rgb,
            finalColor: .saturatedLiquid
        ).rgb.color
    }
}

struct ReactionTimingColor {
    let timing: ReactionTiming
    let currentTime: CGFloat
    let initialColor: RGB
    let finalColor: RGB

    var rgb: RGB {
        ColorInterpolator(
            initialValue: timing.start,
            finalValue: timing.equilibrium,
            currentValue: currentTime,
            initialColor: initialColor,
            finalColor: finalColor
        ).rgb
    }
}

enum SolubleReactionPhase {
    case primarySolute, commonIon, acidity
}

struct ColorInterpolator {
    let initialValue: CGFloat
    let finalValue: CGFloat
    let currentValue: CGFloat
    let initialColor: RGB
    let finalColor: RGB

    var rgb: RGB {
        let fraction = abs((currentValue - initialValue) / (finalValue - initialValue))

        // The max is above 1, so that when overlapping an existing animation to a later state,
        // the animation carries on
        let boundFraction = fraction.within(min: 0, max: 1.1)
        return RGB.interpolate(initialColor, finalColor, fraction: Double(boundFraction))
    }
}

class SoluteContainer {

    var maxAllowed: Int

    init(maxAllowed: Int, isSaturated: Bool = false) {
        self.maxAllowed = maxAllowed
        if isSaturated {
            emitted = maxAllowed
            dissolved = maxAllowed
        }
    }

    private var emitted: Int = 0
    private(set) var dissolved: Int = 0

    func didEmit() {
        emitted += 1
    }

    func didDissolve() {
        dissolved += 1
    }

    func reset() {
        emitted = 0
        dissolved = 0
    }

    var canEmit: Bool {
        emitted < maxAllowed
    }

    var canDissolve: Bool {
        dissolved < maxAllowed
    }

    var dissolvedFraction: CGFloat {
        CGFloat(dissolved) / CGFloat(maxAllowed)
    }
}

enum SolubilityInputState: Equatable {
    case none, addSaturatedSolute
    case addSolute(type: SoluteType)

    var isAddingSolute: Bool {
        if case .addSolute = self {
            return true
        }
        return self == .addSaturatedSolute
    }

    func addingSolute(type: SoluteType) -> Bool {
        self == .addSolute(type: type) || (type == .primary && self == .addSaturatedSolute)
    }
}

extension RGB {
    static let saturatedLiquid = RGB(r: 230, g: 203, b: 140)
    static let maxCommonIon = RGB(r: 233, g: 200, b: 183)
}
