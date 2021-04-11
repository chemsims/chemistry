//
// Reactions App
//

import SwiftUI
import ReactionsCore

final class SolubilityViewModel: ObservableObject {

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0.5
    @Published var inputState = SolubilityInputState.none
    @Published var activeSolute: SoluteType?

    @Published var currentTime: CGFloat = 0
    @Published var waterColor: Color = RGB.beakerLiquid.color
    
    @Published var beakerState: BeakerStateTransition = BeakerStateTransition()

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
        componentsWrapper.solutePerformed(action: .emitted)
        goNextIfNeeded()
    }

    func onParticleWaterEntry(soluteType: SoluteType) {
        componentsWrapper.solutePerformed(action: .enteredWater)
        goNextIfNeeded()
    }

    func onDissolve(soluteType: SoluteType) {
        guard inputState == .addSolute(type: soluteType) || beakerState.state == .demoReaction else {
            return
        }
        componentsWrapper.solutePerformed(action: .dissolved)
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
        componentsWrapper.canPerform(action: .emitted)
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
