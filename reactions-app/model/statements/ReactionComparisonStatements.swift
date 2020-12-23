//
// Reactions App
//
  

import Foundation

struct ReactionComparisonStatements {
    static let intro = [
        TextLineGenerator.makeLine("Do you know the difference between the reaction orders?"),
        TextLineGenerator.makeLine("*Let's dig in!*")
    ]

    static let equationExplainer = [
        TextLineGenerator.makeLine(
            "These equations on the top seem pretty familiar right? They are the same equations we've encountered before, just solved for *[A]* which is a very useful form. Notice how the constants *k* are the ones we already got from the *previous reactions*."
        )
    ]

    static let chartExplainer = [
        TextLineGenerator.makeLine(
            "On the left, we have 3 beakers with a reaction of *A* to *B* taking place in each one, all paired to a \(Strings.aVsT) graph. Each reaction will represent an Order: Zero Order, First Order, and Second Order."
        )
    ]

    static let dragAndDropExplainer = [
        TextLineGenerator.makeLine(
            "Let's try something out now! We know that plotting a \(Strings.aVsT) graph for each order results in different types of line (straight line, curved line and more accentuated curve). When the reaction starts running, *try dragging the right equations and dropping them into the proper graphs*."
        )
    ]

    static let preReaction = [
        TextLineGenerator.makeLine("Tap next or press play on any of the graphs to start the reactions."),
        TextLineGenerator.makeLine("Let's see how long it takes you to guess!")
    ]

    static let reactionRunning = [
        TextLineGenerator.makeLine("Let's see how long it takes you to guess!"),
        TextLineGenerator.makeLine("*Drag and drop the equations to the graph of the corresponding order*.")
    ]

    static let instructToScrubReaction = [
        TextLineGenerator.makeLine("Awesome!"),
        TextLineGenerator.makeLine("Try scrubbing the animation for each beaker one after another, and see visually how these reaction rates differ.")
    ]

    static let end = [
        TextLineGenerator.makeLine("Took you a while didn't it?"),
        TextLineGenerator.makeLine("Let's see how to make things faster."),
    ]
}

