//
// Reactions App
//
  

import Foundation

struct EnergyProfileStatements {

    static let intro: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("Here's an endothermic reaction! Why don't you add a catalyst to make it faster? *Choose one.*"),
    ]

    static let setT2: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("Awesome!"),
        SpeechBubbleLineGenerator.makeLine("Play with temperature to set T_2_. *Use the flame slider.*")
    ]

    static let middle: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("Keep playing with temperature to see more collisions."),
        SpeechBubbleLineGenerator.makeLine("*Use the flame slider.*")
    ]

    static let finished: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("It's done!"),
        SpeechBubbleLineGenerator.makeLine("Now you're fre to *explore further* the reaction rates.")
    ]

}
