//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct PrecipitationStatements {
    private init() { }

    static func filingCabinet(index: Int) -> [TextLine] {
        let swipeDir = index == 0 ? "left" : "right"
        let navDir = index == 0 ? "next" : "back"
        return [
            "Check out the reaction you ran earlier! Tap the run again button to see the last part of the reaction again.",
            "Swipe \(swipeDir) or tap \(navDir) to see the other reaction."
        ]
    }

    static let intro: [TextLine] = [
        """
        Stoichiometry has various applications. Let's find out more.
        """,
        "*Choose a reaction.*"
    ]

    static let explainUnknownMetal: [TextLine] = [
        """
        But there's something else that is strange about this reaction \
        right? Well, *M* is not a real element. M in this case represents \
        just an alkaline metal. We will learn how stoichiometry can tell \
        us which one of those 3 components is *M*.
        """
    ]

    static let instructToSetWaterLevel: [TextLine] = [
        """
        This is a reaction that takes place in water, so let's set the \
        volume of water in the beaker.
        """,
        "*Use the slider to set the volume.*"
    ]

    static let endOfApp: [TextLine] = [
        """
        Now you can explore all parts of this unit, or try a different unit! Just tap the button \
        at the top left corner to reveal the navigation menu, and then choose your favorite part \
        to review it once more!
        """
    ]

    static let chooseNextReaction: [TextLine] = [
        "Now, let's repeat the experiment with the other reaction!"
    ]
}

struct PrecipitationReactionStatements {

    let reaction: PrecipitationReaction

    private var product: String {
        reaction.product.name.asMarkdown
    }

    private var knownReactant: String {
        reaction.knownReactant.name.asMarkdown
    }

    private var unknownReactant: String {
        reaction.unknownReactant.name(showMetal: false, showCoeff: false).asMarkdown
    }

    private var unknownReactantWithMetal: String {
        reaction.unknownReactant.name(showMetal: true, showCoeff: false).asMarkdown
    }

    var explainPrecipitation: [TextLine] {
        [
            """
            This is a precipitation reaction. How do I know? Well, one way \
            is to notice that one of the products is a *solid (s)*, so once \
            the reaction takes place, this solid will be produced and \
            deposit as a precipitate. In this case, *\(product)*.
            """
        ]
    }

    var instructToAddKnownReactant: [TextLine] {
        [
            """
            Perfect! Now, shake *\(knownReactant)* to prepare a solution \
            of it.
            """,
            "*Shake it into the beaker.*"
        ]
    }

    func instructToAddUnknownReactant(molesAdded: CGFloat) -> [TextLine] {
        [
            """
            You added \(molesAdded.str(decimals: 2)) moles of \
            *\(knownReactant)*. Now, go ahead and add \
            *\(unknownReactant)* and let's watch them react.
            """,
            """
            *Notice the amount of grams added by the shaker.*
            """
        ]
    }

    func runInitialReaction(unknownReactantGramsAdded: CGFloat) -> [TextLine] {
        let grams = gramString(grams: unknownReactantGramsAdded)
        return [
            """
            Perfect! You added \(grams) of *\(unknownReactant)*. Now, \
            let's watch the reaction going.
            """,
            "*Watch how \(product) is produced.*"
        ]
    }

    let endOfInitialReaction: [TextLine] = [
        """
        The reaction is complete! Why don't you check out the \
        macroscopic beaker to see the precipitate you produced! *Tap the toggle.*
        """,
        """
        You can also tap back or the run again button to see the reaction again.
        """
    ]

    var instructToWeighProduct: [TextLine] {
        [
            """
            Now, why don't you drag the solid *\(product)* onto the \
            scales to weigh it?
            """,
            "*Drag the solid onto the scales.*"
        ]
    }

    func showWeightOfProduct(
        productGrams: CGFloat,
        productMoles: CGFloat,
        unknownReactantGrams: CGFloat,
        unknownReactantMoles: CGFloat
    ) -> [TextLine] {
        let productGramStr = gramString(grams: productGrams)
        let productMolesStr = productMoles.str(decimals: 2)
        let unknownReactantGramStr = gramString(grams: unknownReactantGrams)
        let unknownReactantMolesStr = unknownReactantMoles.str(decimals: 2)

        return [
            """
            *\(productGramStr) of \(product)* was produced. By \
            dividing this by its molar mass, we know that it is \
            \(productMolesStr) mol, which means that the \
            \(unknownReactantGramStr) of *\(unknownReactant)* we added \
            are *\(unknownReactantMolesStr) mol. But what does this mean?*
            """
        ]
    }

    func revealKnownMetal(
        unknownReactantGrams: CGFloat,
        unknownReactantMoles: CGFloat
    ) -> [TextLine] {
        let gramStr = gramString(grams: unknownReactantGrams)
        let molesStr = unknownReactantMoles.str(decimals: 2)

        let molarMass = reaction.unknownReactant.molarMass
        let metal = reaction.unknownReactant.metal.rawValue

        return [
            """
            *Well, if there are \(gramStr) in \(molesStr) moles of \
            \(unknownReactant)*, then how many are in 1 mol? There are \
            \(molarMass) grams of *\(unknownReactant)* in 1 mol. That's \
            right, \(molarMass) $g/mol$ is the molar mass of it, and \
            the molar mass of *\(unknownReactantWithMetal)* matches \
            it perfectly! So, *$M = \(metal)$.*
            """
        ]
    }

    var instructToAddFurtherUnknownReactant: [TextLine] {
        [
            """
            We already discovered the mystery. At this point, \
            *\(unknownReactantWithMetal)* is the limiting reagent, \
            so just keep shaking *\(unknownReactantWithMetal)* to \
            neutralize the *\(knownReactant)* in its entirety.
            """,
            "*Keep shaking to see it react*"
        ]
    }

    var runFinalReaction: [TextLine] {
        [
            """
            Now just watch how the reactant you added produces more \
            and more *\(product)*, as it neutralizes all of the \
            *\(knownReactant)* that was left in the beaker.
            """,
            """
            *Change between both microscopic and macroscopic views.*
            """
        ]
    }

    var finalStatement: [TextLine] {
        [
            "Done! There's no more reactant left.",
            """
            In a real laboratory, you would be able to extract the \
            precipitate of *\(product)* with a filter and weigh it to \
            know the mass, so this could be applied in real life.
            """
        ]
    }

    private func gramString(grams: CGFloat) -> String {
        let rounded = grams.str(decimals: 2)
        let gramName = grams == 1 ? "gram" : "grams"
        return "\(rounded) \(gramName)"
    }
}
