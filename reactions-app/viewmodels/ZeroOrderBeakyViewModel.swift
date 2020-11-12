//
// Reactions App
//
  

import SwiftUI

class ZeroOrderBeakyViewModel: ObservableObject {

    let reactionViewModel: ReactionViewModel

    init(reactionViewModel: ReactionViewModel) {
        self.reactionViewModel = reactionViewModel
    }

    @Published var statement: [SpeechBubbleLine] = ZeroOrderBeakyStatements.statement1

    private var currentStep: Int = 1 {
        didSet {
            statement = getStatementForCurrentStep()
        }
    }

    func next() {
        currentStep = 2
        let upperConcentration = reactionViewModel.initialConcentration
        let lowerConcentration = ReactionSettings.minConcentration
        let midConcenration = (upperConcentration + lowerConcentration) / 2

        let lowerTime = reactionViewModel.initialTime
        let upperTime = ReactionSettings.maxTime
        let midTime = (lowerTime + upperTime) / 2

        reactionViewModel.finalConcentration = midConcenration
        reactionViewModel.finalTime = midTime
    }

    func back() {
        currentStep = 1
        reactionViewModel.finalConcentration = nil
        reactionViewModel.finalTime = nil
    }

    private func getStatementForCurrentStep() -> [SpeechBubbleLine] {
        switch (currentStep) {
        case 1: return ZeroOrderBeakyStatements.statement1
        case 2: return ZeroOrderBeakyStatements.statement2
        default: return []
        }
    }

}

struct ZeroOrderBeakyStatements {

    static let statement1: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            str: "This is a zero Order Reaction."
        ),
        SpeechBubbleLineGenerator.makeLine(
            str: "Why don't you set the *initial time (t1)* and *initial concentration of A (c1)*, the reactant?"
        )
    ]

    static let statement2: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            str: "Great! Now you can set the *concentration of A at the end of the reaction (c2)* and the *time the reaction will last (t2)*"
        )
    ]

}
