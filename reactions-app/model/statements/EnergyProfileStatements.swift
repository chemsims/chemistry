//
// Reactions App
//
  

import CoreGraphics

struct EnergyProfileStatements {

    static let intro: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine("Not so fast!"),
        SpeechBubbleLineGenerator.makeLine("Choose a reaction to work with for this experiment."),
        SpeechBubbleLineGenerator.makeLine("*Tap the right corner button to show the dropdown list.*"),
    ]

    static let introCollisionTheory = [
        SpeechBubbleLineGenerator.makeLine(
            """
            We now know that the concentration can affect the *Rate* of a reaction. \
            But there are other variables that can affect in one way or another the *Rate* too. Let's first talk about *Collision Theory*.
            """
        )
    ]

    static let explainCollisionTheory = [
        SpeechBubbleLineGenerator.makeLine(
            """
            It states that the reaction rate is equal to the frequency of effective collisions between reactants. \
            For a collision to be effective, the molecules must collide with sufficient energy and in the proper orientation so that products can form.
            """
        )
    ]

    static let explainActivationEnergy = [
        SpeechBubbleLineGenerator.makeLine(
            """
            This minimum amount of energy that is needed to initiate or start a chemical reaction is called *Activation Energy (E_a_).* \
            As long as the collision of the molecules orientated properly have enough energy to surpass the *E_a_*, the collision will be successful.
            """
        )
    ]

    static let explainArrhenius = [
        SpeechBubbleLineGenerator.makeLine(
            """
            But how is the temperature related to the *Rate*? Well, an equation that portrays this mode accurately is the *Arrhenius Equation*. \
            As you can see, the temperature specifically affects the rate constant *k*.
            """
        )
    ]

    static let explainTerms = [
        SpeechBubbleLineGenerator.makeLine(
            """
            *k* is the rate constant, *A* is a term called the frequency factor that accounts for molecular orientation, \
            *e* is the natural logarithm base, *R* is the universal gas constant \(Strings.withNoBreaks(str: "8.314 J mol^-1^ K^-1^")), \
            *T* is the Kelvin temperature, and *E_a_* is the activation energy.
            """
        )
    ]

    static let explainRateTempRelation = [
        SpeechBubbleLineGenerator.makeLine(
            """
            As you can tell by the equation, the higher the temperature, the higher the rate constant will be ,this making the *Rate* higher too. \
            In a more practical way, high temperatures make the avg. energy of molecules go up, beating the *E_a_* barrier.
            """
        )
    ]

    static let explainLinearKEquation = [
        SpeechBubbleLineGenerator.makeLine("When applying logarithmic properties to both sides, you get a version of the equation that's linear, where:"),
        SpeechBubbleLineGenerator.makeLine(Strings.withNoBreaks(str: "ln(k)*(y)*=(-E_a_/RT)*(mx)*+ln(a)*(b)*")),
        SpeechBubbleLineGenerator.makeLine("With a slope of -E_a_/R")
    ]

    static let explainArrheniusTwoPoints = [
        SpeechBubbleLineGenerator.makeLine(
            """
            If the linear equation is used to represent 2 different points (point 1 and point 2) of the line, we can sum \
            up the equations to get this form of the Arrhenius Equation. This is a very common way to use the Arrhenius Equation \
            where k_1_ is the rate constant at T_1_ and k_2_ is the rate constant at T_2_.
            """
        )
    ]

    static func showCurrentValues(
        ea: CGFloat,
        k: CGFloat,
        t: CGFloat
    ) -> [SpeechBubbleLine] {
        let eaString = Strings.withNoBreaks(str: "\(ea.str(decimals: 0))J")
        return [
            SpeechBubbleLineGenerator.makeLine(
                """
                For this reaction, \(Strings.withNoBreaks(str: "*E_a_=\(eaString)*")) and *k is \(k.str(decimals: 1))* \
                when the temperature is \(Strings.withNoBreaks(str: "*\(t.str(decimals: 0)) K*")) K. \
                In other words, the kinetic energy of the molecules have to be one that when colliding, the potential \
                energy resultant is higher than *\(eaString)* in order for A and B to successfully transform into a C molecule.
                """
            )
        ]
    }

    static let explainEnergyDiagram = [
        SpeechBubbleLineGenerator.makeLine(
            """
            One way to depict the reaction's Activation Energy and potential energy is with an *energy diagram or reaction profile*. \
            The reaction profile plots the increase in potential energy of the reactants as they approach, reaching a maximum at the moment \
            of collision, and then the decrease in potential energy as the products recoil.
            """
        )
    ]

    static let explainExothermic = [
        SpeechBubbleLineGenerator.makeLine(
            """
            This is an exothermic reaction because the reaction starts at a higher point of energy than where it ends. \
            In other words, energy is being released when the reaction takes place. This energy released is usually \
            referred to as heat, but we'll talk about that deeper in other units.
            """
        )
    ]

    static let explainEaHump = [
        SpeechBubbleLineGenerator.makeLine(
            """
            The hump or bell in the graph represents the *Activation Energy*. The reaction energy has to be one \
            that overcomes that difference for it to occur. Otherwise, even with the proper orientation the molecules colliding of \
            A and B won't be turning into C. The higher *E_a_* is, the harder it is for the reaction to have sufficient energy to overcome it.
            """
        )
    ]

    static let explainCatalyst = [
        SpeechBubbleLineGenerator.makeLine(
            """
            There's a way to reduce the *Activation Energy*, and that is with the use of a *catalyst*. \
            Catalysts make reactions faster, and even though there are various types, in one way or another they do \
            so by reducing the Activation Energy, or *E_a_*.
            """
        )
    ]

    static let instructToChooseCatalyst = [
        SpeechBubbleLineGenerator.makeLine("Let's try that out!"),
        SpeechBubbleLineGenerator.makeLine("Choose a catalyst to use to make the reaction in the beaker go faster."),
        SpeechBubbleLineGenerator.makeLine("*Tap a catalyst to select it*.")
    ]

    static let instructToShakeCatalyst = [
        SpeechBubbleLineGenerator.makeLine("Perfect! Now shake the catalyst to drop it into the beaker, and let's see what happens."),
        SpeechBubbleLineGenerator.makeLine("*Shake your phone or tablet or just tap the shaker once again*.")
    ]

    static func showEaReduction(newEa: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                """
                Look! The E_a_ was reduced to \(Strings.withNoBreaks(str: "*\(newEa.str(decimals: 0)) J*")) \
                thanks to that catalyst. See that horizontal line? It represents the average kinetic energy of the molecules. \
                Right now it's lower than Ea, so no products are going to be formed just yet.
                """
            )
        ]
    }

    static func showLinearChart(slope: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                """
                Take a look at the linear graph of \(Strings.withNoBreaks(str: "ln(k) vs 1/T")) with a slope of \(slope.str(decimals: 0)). This graph is very useful to determine the relation between the constant *k* and the temperature. Here you can see too that the higher is *k*, the higher is *T*.
                """
            )
        ]
    }

    static func showKRatio(newK: CGFloat) -> [SpeechBubbleLine] {
        [
            SpeechBubbleLineGenerator.makeLine(
                """
                Points of that graph are being represented in this equation. As of now, *k* went up to *\(newK.str(decimals: 1))* \
                when *T* is *\(newK.str(decimals: 0))K*, because the catalyst lowered the E_a_, making the constant k higher, thus making the Rate higher too.
                """
            )
        ]
    }

    static let instructToSetTemp = [
        SpeechBubbleLineGenerator.makeLine(
            """
            Let's try to produce C. *Use the flame slider to increase the temperature in the beaker*. \
            This will make the kinetic energy of the molecules increase too, meaning they will go faster so that when they collide \
            there's enough energy to overcome the E_a_.
            """
        )
    ]

    static let reactionInProgress = [
        SpeechBubbleLineGenerator.makeLine("Perfect! Successful collisions are taking place!"),
        SpeechBubbleLineGenerator.makeLine("Notice how the average kinetic bar goes up when the temperature goes up too. Also, notice how the rate constant can vary with the temperature.")
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
        SpeechBubbleLineGenerator.makeLine("It's all done! All of A and B has turned into C successfully."),
        SpeechBubbleLineGenerator.makeLine("Let's take another quiz, and then you're free to *explore further* the reaction rates.")
    ]

}
