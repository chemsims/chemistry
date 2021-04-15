//
// Reactions App
//

import ReactionsCore
import SwiftUI

class AqueousScreenState: ScreenState, SubState {

    typealias Model = AqueousReactionViewModel
    typealias NestedState = AqueousScreenState

    func delayedStates(model: AqueousReactionViewModel) -> [DelayedState<AqueousScreenState>] {
        []
    }

    func apply(on model: AqueousReactionViewModel) { }

    func unapply(on model: AqueousReactionViewModel) { }

    func reapply(on model: AqueousReactionViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        nil
    }
}

class AqueousSetStatementState: AqueousScreenState {

    let statement: [TextLine]
    let highlights: [AqueousScreenElement]
    init(statement: [TextLine], highlights: [AqueousScreenElement] = []) {
        self.statement = statement
        self.highlights = highlights
    }

    private var initialElements = [AqueousScreenElement]()

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = statement
        initialElements = model.highlightedElements.elements
        model.highlightedElements.elements = highlights
        model.canSetCurrentTime = false
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.highlightedElements.elements = initialElements
    }
}

class AqueousHasSelectedReactionState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.explainEquilibrium
        model.inputState = .none
        model.reactionSelectionIsToggled = false
        model.highlightedElements.clear()
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.reactionSelectionIsToggled = true
        model.inputState = .selectReactionType
    }

}

class AqueousSetWaterLevelState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.inputState = .setLiquidLevel
        model.statement = AqueousStatements.instructToSetWaterLevel
        model.highlightedElements.elements = [.waterSlider]
    }

    override func reapply(on model: AqueousReactionViewModel) {
        model.resetMolecules()
        super.reapply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.inputState = .none
    }
}

class AqueousAddReactantState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToAddReactant(selected: model.selectedReaction)
        model.inputState = .addReactants
        model.showConcentrationLines = true
        model.showEquationTerms = true
        model.highlightedElements.elements = [.moleculeContainers]
        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.stopShaking()
        model.showConcentrationLines = false
        model.showEquationTerms = false
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

class AqueousPreRunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.preAnimation
        model.inputState = .none
        model.showQuotientLine = true
        model.stopShaking()
        DeferScreenEdgesState.shared.deferEdges = []
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.showQuotientLine = false
    }
}

class AqueousRunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.runAnimation
        model.highlightForwardReactionArrow = true
        let time = AqueousReactionSettings.forwardReactionTime
        model.currentTime = 0
        withAnimation(.linear(duration: Double(time))) {
            model.currentTime = time
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.highlightForwardReactionArrow = false
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
            model.highlightedElements.clear()
        }
    }

    override func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.forwardReactionTime)
    }

    override func delayedStates(model: AqueousReactionViewModel) -> [DelayedState<AqueousScreenState>] {
        func delayedState(
            _ statement: [TextLine],
            _ delay: Double,
            _ elements: [AqueousScreenElement] = []
        ) -> DelayedState<AqueousScreenState> {
            DelayedState(
                state: AqueousSetStatementState(
                    statement: statement,
                    highlights: elements
                ),
                delay: delay
            )
        }
        let delay = Double(AqueousReactionSettings.timeForConvergence / 2)
        return [
            delayedState(AqueousStatements.midAnimation, delay),
            delayedState(AqueousStatements.reachedEquilibrium, delay, [.chartEquilibrium]),
        ]
    }
}

class AqueousEndAnimationState: AqueousScreenState {

    let statement: [TextLine]
    let endTime: CGFloat

    init(statement: [TextLine], endTime: CGFloat) {
        self.statement = statement
        self.endTime = endTime
    }

    override func apply(on model: AqueousReactionViewModel) {
        doApply(on: model, isReapplying: false)
    }

    override func reapply(on model: AqueousReactionViewModel) {
        doApply(on: model, isReapplying: true)
    }

    private func doApply(on model: AqueousReactionViewModel, isReapplying: Bool) {
        model.statement = statement
        model.highlightForwardReactionArrow = false
        model.highlightReverseReactionArrow = false
        if isReapplying {
            model.highlightedElements.elements = [.chartEquilibrium]
        }
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = endTime * endOfReactionFactor
            if !isReapplying {
                model.highlightedElements.elements = [.chartEquilibrium]
            }
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.highlightedElements.clear()
    }
}

class AqueousCanSetCurrentTimeState: AqueousScreenState {

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToChangeCurrentTime
        model.highlightedElements.clear()
        model.canSetCurrentTime = true
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = false
    }

}

class AqueousShiftChartState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.introToReverse
        model.canSetCurrentTime = false
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = AqueousReactionSettings.forwardReactionTime
            model.currentTime = AqueousReactionSettings.timeToAddProduct
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = AqueousReactionSettings.forwardReactionTime
        }
        model.canSetCurrentTime = true
    }
}

class InstructToAddProductState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        doApply(on: model, setComponent: true)
    }

    override func reapply(on model: AqueousReactionViewModel) {
        doApply(on: model, setComponent: false)
    }

    private func doApply(on model: AqueousReactionViewModel, setComponent: Bool) {
        model.statement = AqueousStatements.instructToAddProduct(selected: model.selectedReaction)
        model.inputState = .addProducts
        model.highlightedElements.elements = [.moleculeContainers]
        if setComponent {
            model.componentsWrapper = ReactionComponentsWrapper(
                previous: model.componentsWrapper,
                startTime: AqueousReactionSettings.timeToAddProduct,
                equilibriumTime: AqueousReactionSettings.timeForReverseConvergence
            )
        }

        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.inputState = .none
        model.highlightedElements.clear()
        model.stopShaking()
        if let previous = model.componentsWrapper.previous {
            model.componentsWrapper = previous
        } else {
            print("no previous to unapply")
        }
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

class AqueousPreReverseAnimation: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.preReverseReaction
        model.inputState = .none
        model.highlightedElements.clear()
        model.stopShaking()
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

class AqueousRunReverseAnimation: AqueousScreenState {

    private let tAddProduct = AqueousReactionSettings.timeToAddProduct
    private let tConvergence = AqueousReactionSettings.timeForReverseConvergence
    private let tEnd = AqueousReactionSettings.endOfReverseReaction
    
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.reverseReactionStarted
        model.highlightReverseReactionArrow = true
        withAnimation(.linear(duration: Double(tEnd - tAddProduct))) {
            model.currentTime = tEnd
        }
    }

    override func reapply(on model: AqueousReactionViewModel) {
        model.currentTime = tAddProduct
        super.reapply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.highlightReverseReactionArrow = false
        withAnimation(.easeOut(duration: Double(0.5))) {
            model.currentTime = tAddProduct
            model.highlightedElements.clear()
        }
    }

    override func delayedStates(model: AqueousReactionViewModel) -> [DelayedState<AqueousScreenState>] {
        let tToConvergence = tConvergence - tAddProduct
        let delay = Double(tToConvergence / 2)
        return [
            DelayedState(
                state: AqueousSetStatementState(
                    statement: AqueousStatements.midReverseReaction
                ),
                delay: delay
            ),
            DelayedState(
                state: AqueousSetStatementState(
                    statement: AqueousStatements.reverseEquilibriumReached,
                    highlights: [.chartEquilibrium]
                ),
                delay: delay
            )
        ]
    }

    override func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.endOfReverseReaction - AqueousReactionSettings.timeToAddProduct)
    }
}

class FinalAqueousState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.endStatement
        model.canSetCurrentTime = false
        model.highlightedElements.clear()
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = true
    }
}

private let endOfReactionFactor: CGFloat = 1.0001
