//
// Reactions App
//
  

import SwiftUI

class ZeroOrderBeakyViewModel: ObservableObject {

    @Published var currentText: [SpeechBubbleLine] = ZeroOrderBeakyStatements.statement1

    private var currentStep: Int = 1

    func next() {

    }

    func back() {

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

}
