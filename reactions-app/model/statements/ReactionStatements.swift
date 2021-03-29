//
// Reactions App
//

import CoreGraphics

struct ReactionStatements {

    static let chooseReaction: [TextLine] = [
        "Now, let's try choosing a different reaction, which has a fixed rate constant, *k*.",
        "*Choose a reaction above*."
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

    static func inProgress(display: ReactionPairDisplay) -> [TextLine] {
        [
            "Let's watch all the molecules changing!",
            "As \(display.reactant.name) disappears, \(display.product.name) is being produced.",
            """
            This happens at a variable *rate (in units of $M/s$)*, which is dependent on *k* \
            and *[\(display.reactant.name)]*.
            """
        ]
    }

    static let endOfSecondReaction: [TextLine] = [
        "Amazing, let's take another snapshot!",
        "Try *dragging the time indicator* again to scrub through the reaction time."
    ]

    static let end: [TextLine] = [
        "Amazing, let's take another snapshot!",
        "Try *dragging the time indicator* to scrub through the reaction time.",
        "Then, let's take a quiz to review what we've learnt."
    ]

}
