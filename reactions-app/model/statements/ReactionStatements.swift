//
// Reactions App
//
  

import CoreGraphics

struct ReactionStatements {

    static let chooseReaction: [TextLine] = [
        "Now that you've completed the app, why don't you try a different reaction type?",
        "Choose a reaction above, with a fixed rate constant, *k*"
    ]

    static func setInitialInputs(rateConstant: CGFloat) -> [TextLine] {
        [
            TextLineGenerator.makeLine(
                "Great! You picked a reaction with a rate constant \(rateConstant.str(decimals: 2))."
            ),
            "Why don't you *set the initial concentration and initial time*?"
        ]
    }

    static let setT2ForFixedRate: [TextLine] = [
        "Awesome! Now set the time the reaction ends.",
        "Notice how the final concentration varies as you adjust the final time."
    ]

    static let setC2ForFixedRate: [TextLine] = [
        "Awesome! Now set the final concentration of the reaction.",
        "Notice how the final time varies as you adjust the final concentration."
    ]


    static let inProgress: [TextLine] = [
        TextLineGenerator.makeLine(
            "Let's watch all the molecules changing!"
        ),
        TextLineGenerator.makeLine(
            "As A disappears, B is being produced."
        ),
        TextLineGenerator.makeLine(
            "This happens at a variable *Rate (in units of M/s)*, which is dependant on *k* and *[A]*."
        )
    ]
    
}
