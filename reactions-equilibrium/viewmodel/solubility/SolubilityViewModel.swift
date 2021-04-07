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

    var color: RGB {
        switch self {
        case .primary: return RGB.primarySolute
        case .commonIon: return RGB.commonIonSolute
        case .acid: return RGB.acidSolute
        }
    }
}

final class SolubilityViewModel: ObservableObject {

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0.5
    @Published var inputState = SolubilityInputState.none
    @Published var activeSolute: SoluteType?

    @Published var currentTime: CGFloat = 0
    @Published var waterColor: Color = RGB.beakerLiquid.color
    
    @Published var beakerSoluteState = BeakerSoluteState.addingSolute(type: .primary, clearPrevious: false)

    @Published var chartOffset: CGFloat = 0
    @Published var equationState = SolubilityEquationState.showOriginalQuotient

    @Published var componentsWrapper: SolubleComponentsWrapper!

    var components: SolubilityComponents {
        componentsWrapper.components
    }

    init() {
        let firstTiming = SolubleReactionSettings.firstReactionTiming
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.componentsWrapper = PrimarySoluteComponentsWrapper(
            soluteToAddForSaturation: soluteToAddForSaturation,
            timing: firstTiming,
            previous: nil,
            setTime: setTime
        )
        self.navigation = SolubilityNavigationModel.model(model: self)
    }

    func setTime(to newTime: CGFloat) {
        let dt = newTime - currentTime
        let newColor = color(at: newTime)
        withAnimation(.linear(duration: abs(Double(dt)))) {
            currentTime = newTime
            waterColor = newColor
        }
    }

    func setColor(to newColor: Color) {
        withAnimation(.linear(duration: 0.5)) {
            waterColor = newColor
        }
    }

    var timing: ReactionTiming {
        componentsWrapper.timing
    }

    let shakingModel: SoluteBeakerShakingViewModel

    func next() {
        doGoNext(force: false)
    }

    private func doGoNext(force: Bool) {
        if force {
            navigation?.next()
        } else {
            switch inputState {
            case .addSaturatedSolute,
                 .addSolute(type: _):
                if componentsWrapper.shouldGoNext {
                    navigation?.next()
                }
                break;
            default: navigation?.next()
            }
        }
    }

    func back() {
        navigation?.back()
    }

    func onParticleEmit(soluteType: SoluteType) {
        componentsWrapper.soluteEmitted(soluteType)
        goNextIfNeeded()
    }

    func onParticleWaterEntry(soluteType: SoluteType) {
        componentsWrapper.soluteEnteredWater(soluteType)
        goNextIfNeeded()
    }

    func onDissolve(soluteType: SoluteType) {
        guard inputState == .addSolute(type: soluteType) else {
            return
        }
        componentsWrapper.soluteDissolved(soluteType)
        goNextIfNeeded()
    }

    private func goNextIfNeeded() {
        if componentsWrapper.shouldGoNext {
            doGoNext(force: true)
        }
    }

    func startShaking() {
        shakingModel.start()
    }

    func stopShaking() {
        shakingModel.stop()
    }

    var canEmit: Bool {
        componentsWrapper.counts.canEmit
    }

    var soluteToAddForSaturation: Int {
        let equation = LinearEquation(x1: 0, y1: 10, x2: 1, y2: 20)
        return equation.getY(at: waterHeightFactor).roundedInt()
    }

    private func color(at time: CGFloat) -> Color {
        RGBEquation(
            initialX: timing.start,
            finalX: timing.equilibrium,
            initialColor: componentsWrapper.initialColor,
            finalColor: componentsWrapper.finalColor
        ).getRgb(at: time).color
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

struct RGBEquation {

    let initialX: CGFloat
    let finalX: CGFloat
    let initialColor: RGB
    let finalColor: RGB

    func getRgb(at x: CGFloat) -> RGB {
        let fraction = abs((x - initialX) / (finalX - initialX))
        let boundFraction = fraction.within(min: 0, max: 1)
        return RGB.interpolate(initialColor, finalColor, fraction: Double(boundFraction))
    }
}

struct SoluteContainer {

    var maxAllowed: Int

    init(maxAllowed: Int, isSaturated: Bool = false) {
        self.maxAllowed = maxAllowed
        if isSaturated {
            emitted = maxAllowed
            dissolved = maxAllowed
        }
    }

    private(set) var emitted: Int = 0
    private(set) var dissolved: Int = 0
    private(set) var enteredWater: Int = 0

    mutating func didEmit() {
        emitted += 1
    }

    mutating func didDissolve() {
        dissolved += 1
    }

    mutating func didEnterWater() {
        enteredWater += 1
    }

    mutating func reset() {
        emitted = 0
        dissolved = 0
        enteredWater = 0
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

    var enteredWaterFraction: CGFloat {
        CGFloat(enteredWater) / CGFloat(maxAllowed)
    }
}


// TODO - move everything below here to other files
enum SolubilityInputState: Equatable {
    case none, addSaturatedSolute, setWaterLevel
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
    static let saturatedLiquid = RGB(r: 237, g: 218, b: 174)
    static let maxCommonIonLiquid = RGB(r: 233, g: 200, b: 183)
    static let maxAcidLiquid = RGB(r: 167, g: 250, b: 218)

    static let primarySolute = RGB(r: 230, g: 175, b: 33)
    static let commonIonSolute = RGB(r: 214, g: 91, b: 35)
    static let acidSolute = RGB(r: 9, g: 179, b: 97)
}


enum SolubilityEquationState {
    case showOriginalQuotient,
         showOriginalQuotientAndQuotientRecap,
         crossOutOriginalQuotientDenominator,
         showCorrectQuotientNotFilledIn,
         showCorrectQuotientFilledIn

    var doShowOriginalQuotient: Bool {
        switch self {
        case .showOriginalQuotient,
             .showOriginalQuotientAndQuotientRecap,
             .crossOutOriginalQuotientDenominator:
            return true
        default: return false
        }
    }

    var doShowCorrectQuotient: Bool {
        switch self {
        case .showCorrectQuotientFilledIn,
             .showCorrectQuotientNotFilledIn:
            return true
        default: return false
        }
    }

    var doCrossOutDenom: Bool {
        switch self {
        case .showOriginalQuotient, .showOriginalQuotientAndQuotientRecap: return false
        default: return true
        }
    }
}
