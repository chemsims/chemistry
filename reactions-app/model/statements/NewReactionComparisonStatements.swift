//
// Reactions App
//
  

import Foundation

struct NewReactionComparisonStatements {
    static let intro = [
        SpeechBubbleLineGenerator.makeLine("Do you know the difference between the reaction orders?"),
        SpeechBubbleLineGenerator.makeLine("*Let's dig in!*")
    ]

    static let equationExplainer = [
        SpeechBubbleLineGenerator.makeLine(
            "These equations on the top seem pretty familiar right? They are the same equations we've encountered before, just solved for *[A]* which is a very useful form. Notice how the constants *k* are the ones we already got from the *previous reactions*."
        )
    ]

    static let chartExplainer = [
        SpeechBubbleLineGenerator.makeLine(
            "On the left, we have 3 beakers with a reaction of A to B taking place in each one, all paired to a [A] vs t graph. Each reaction will represent an Order: Zero Order, First Order, and Second Order."
        )
    ]

    static let dragAndDropExplainer = [
        SpeechBubbleLineGenerator.makeLine(
            "Let's try something out now! We know that plotting a [A] vs t graph for each order results in different types of line (straight line, curved line and more accentuated curve). *Try dragging the right equations and dropping them into the proper graphs*"
        )
    ]

    static let preReaction = [
        SpeechBubbleLineGenerator.makeLine("But first tap next or play on any of the graphs to make all the reactions start."),
        SpeechBubbleLineGenerator.makeLine("Let's see how long it takes you to guess!")
    ]

    static let reactionRunning = [
        SpeechBubbleLineGenerator.makeLine("Let's see how long it takes you to guess!"),
        SpeechBubbleLineGenerator.makeLine("*Drag and drop the equations to the graph of the corresponding order*.")
    ]

    static let end = [
        SpeechBubbleLineGenerator.makeLine("Awesome! Took you a while didn't it?"),
        SpeechBubbleLineGenerator.makeLine("Let's see how to make things faster."),
    ]
}

