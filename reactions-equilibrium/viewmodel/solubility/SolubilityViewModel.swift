//
// Reactions App
//

import SwiftUI
import ReactionsCore

final class SolubilityViewModel: ObservableObject {

    init(persistence: SolubilityPersistence) {
        let firstTiming = SolubleReactionSettings.firstReactionTiming
        let firstReaction = SolubleReactionType.A
        self.selectedReaction = firstReaction
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.persistence = persistence
        self.componentsWrapper = PrimarySoluteComponentsWrapper(
            soluteToAddForSaturation: soluteToAddForSaturation,
            timing: firstTiming,
            previous: nil,
            solubilityCurve: firstReaction.solubility,
            setTime: setTime,
            reaction: firstReaction
        )
        self.navigation = SolubilityNavigationModel.model(model: self)
    }

    var persistence: SolubilityPersistence

    @Published var statement = [TextLine]()
    var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0.5 {
        didSet {
            highlights.clear()
        }
    }
    @Published var inputState = SolubilityInputState.none
    @Published var activeSolute = ValueWithPrevious<SoluteType?>(value: nil)

    @Published var currentTime: CGFloat = 0
    @Published var waterColor: Color = RGB.beakerLiquid.color
    
    @Published var beakerState: BeakerStateTransition = BeakerStateTransition()

    @Published var chartOffset: CGFloat = 0
    @Published var equationState = SolubilityEquationState.showOriginalQuotient

    @Published var selectedReaction: SolubleReactionType {
        didSet {
            componentsWrapper.solubilityCurve = selectedReaction.solubility
            persistence.reaction = selectedReaction
        }
    }
    @Published var reactionSelectionToggled = false
    @Published var showSelectedReaction = false
    @Published var highlights = HighlightedElements<SolubleScreenElement>()
    @Published var highlightForwardReactionArrow = false

    @Published var componentsWrapper: SolubleComponentsWrapper!

    @Published var milligramsSoluteAdded: CGFloat = 0

    @Published var showShakeText = false
    @Published var canSetCurrentTime = false
    @Published var beakerLabel = SolubilityBeakerAccessibilityLabel.clear

    @Published var addVoiceOverParticle = AddManualParticle.none
    @Published var showSoluteReactionLabel = false

    var components: SolubilityComponents {
        componentsWrapper.components
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

    func addVoiceOverParticle(soluteType: SoluteType) {
        let shouldDissolve = inputState == .addSolute(type: .primary)
        addVoiceOverParticle = .add(forceDissolve: shouldDissolve)
        onParticleEmit(soluteType: soluteType, onBeakerState: beakerState.state)
        onParticleWaterEntry(soluteType: soluteType, onBeakerState: beakerState.state)
        onDissolve(soluteType: soluteType, onBeakerState: beakerState.state)
    }

    private func doGoNext(force: Bool) {
        if force || !nextIsDisabled {
            navigation?.next()
        }
    }

    var nextIsDisabled: Bool {
        switch inputState {
        case .addSaturatedSolute, .addSolute(type: _):
            return !componentsWrapper.shouldGoNext
        default:
            return false
        }
    }

    func back() {
        navigation?.back()
    }

    func onParticleEmit(soluteType: SoluteType, onBeakerState: BeakerState) {
        guard canRunSoluteAction(soluteType: soluteType, onBeakerState: onBeakerState) else {
            return
        }
        componentsWrapper.solutePerformed(action: .emitted)
        goNextIfNeeded()
    }

    func onParticleWaterEntry(soluteType: SoluteType, onBeakerState: BeakerState) {
        guard canRunSoluteAction(soluteType: soluteType, onBeakerState: onBeakerState) else {
            return
        }
        withAnimation(.easeOut(duration: 0.5)) {
            showShakeText = false
        }
        componentsWrapper.solutePerformed(action: .enteredWater)
        withAnimation(.linear(duration: 1)) {
            setMilligramsAdded()
        }
        goNextIfNeeded()
    }

    func onDissolve(soluteType: SoluteType, onBeakerState: BeakerState) {
        guard canRunSoluteAction(soluteType: soluteType, onBeakerState: onBeakerState) else {
            return
        }
        componentsWrapper.solutePerformed(action: .dissolved)

        if inputState == .addSolute(type: .primary) {
            let dissolvedFraction = componentsWrapper.counts.fraction(of: .dissolved)
            if dissolvedFraction < 0.3 {
                statement = SolubilityStatements.primaryReactionStarted
            } else if dissolvedFraction < 0.6 {
                statement = SolubilityStatements.firstThirdPrimaryReaction
            } else {
                statement = SolubilityStatements.lastThirdPrimaryReaction
            }
        }

        goNextIfNeeded()

    }

    func setMilligramsAdded() {
        let enteredWater = componentsWrapper.totalSoluteCount(of: .enteredWater, soluteType: beakerState.state.soluteType)
        let newSoluteAdded = SolubleReactionSettings.milligrams(for: enteredWater)
        milligramsSoluteAdded = CGFloat(newSoluteAdded)
    }

    private func canRunSoluteAction(soluteType: SoluteType, onBeakerState: BeakerState) -> Bool {
        inputState.addingSolute(type: soluteType) && beakerState.state == onBeakerState
    }

    private func goNextIfNeeded() {
        if componentsWrapper.shouldGoNext {
            doGoNext(force: true)
            UIAccessibility.post(notification: .announcement, argument: statement.label)
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

    var commonIonSoluteToAddForSaturation: Int {
        soluteToAddForSaturation - 4
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
