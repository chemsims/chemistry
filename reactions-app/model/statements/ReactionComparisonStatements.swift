//
// Reactions App
//
  

import Foundation

struct ReactionComparisonStatements {
    static let intro: [TextLine] = [
        "Do you know the difference between the reaction orders?",
        "*Let's dig in!*"
    ]

    static let equationExplainer: [TextLine] = [
        "These equations on the top seem pretty familiar right? They are the same equations we've encountered before, just solved for *[A]* which is a very useful form. Notice how the constants *k* are the ones we already got from the *previous reactions*."

    ]

    static let chartExplainer: [TextLine] = [
        "On the left, we have 3 beakers with a reaction of *A* to *B* taking place in each one, all paired to an \(Strings.aVsT) graph. Each reaction will represent an order: zero order, first order, and second order."
]

    static let dragAndDropExplainer: [TextLine] = [
        "Let's try something out now! We know that plotting an \(Strings.aVsT) graph for each order results in different types of line (straight line, curved line and more accentuated curve). When the reaction starts running, *try dragging the right equations and dropping them into the proper graphs*."
    ]

    static let preReaction: [TextLine] = [
        "Tap next or press play on any of the graphs to start the reactions.",
        "Let's see how long it takes you to guess!"
    ]

    static let reactionRunning: [TextLine] = [
        "Let's see how long it takes you to guess!",
        "*Drag and drop the equations to the graph of the corresponding order*."
    ]

    static let instructToScrubReaction: [TextLine] = [
        "Awesome!",
        "Try scrubbing the animation for each beaker one after another, and see visually how these reaction rates differ."
    ]

    static let end: [TextLine] = [
        "Took you a while didn't it?",
        "Let's see how to make things faster.",
    ]

    static let blockClickingNextBeforeChoosingReactions: [TextLine] = [
        "Try to identify the correct orders for each graph first!",
        "*Drag and drop the equations to the graph of the corresponding order*.",
    ]
}

