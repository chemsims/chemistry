//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let energyProfileQuizQuestions = QuizQuestionsList(
        questionSet: .energyProfile,
        [
            QuizQuestionData(
                id: "ENERGYPROFILE-1",
                question: "What is the concept of Activation Energy (E_a_)?",
                correctAnswer: QuizAnswerData(
                    answer:  "Activation Energy is the one required to form the transition state in a chemical reaction",
                    explanation: """
                    This is the definition of Activation Energy. It's the one that's required for a chemical \
                    reaction to take place.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Activation Energy is the one that a molecule possesses due to its motion",
                        explanation: "That would be closer to the concept of Kinetics Energy."
                    ),
                    QuizAnswerData(
                        answer: "Activation Energy is the one released or consumed when one mole of a substance is created under standard conditions from its pure elements",
                        explanation: "That would be closer to the concept of Standard Enthalpy of Formation."
                    ),
                    QuizAnswerData(
                        answer: "Activation Energy is the one stored in the bonds of chemical compounds (atoms and molecules)",
                        explanation: "That would be closer to the concept of Chemical Energy."
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-2",
                question: """
            Consider the energy diagram below. By adding the catalyst, it has created a new pathway \
            that's being represented by the red line (line 2) in the diagram. How exactly does this make the \
            reaction faster?
            """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    By the addition of the catalyst, another pathway is created which requires \
                    much less energy for A and B to finally produce C
                    """,
                    explanation: """
                    The red line (line 2) represents a pathway that the catalyst created which requires a \
                    lot less energy for the reactants A and B to follow and become C.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        By the addition of the catalyst, two pathways have been created for A and \
                        B to follow to produce C.
                        """,
                        explanation: """
                        Even though another pathways has been indeed created by the addition of \
                        the catalyst, A and B reactants wouldn't follow both pathways, but only \
                        the one with much less energy.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Adding the catalyst results in an increment of the temperature of the system, making the heat to increase as well.",
                        explanation: """
                        The heat difference between reactants (A and B) and product (C) remains \
                        the same even when the hump is lowered.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Adding the catalyst makes the products to be at a lower state of energy, so it's easier for the reaction to reach.",
                        explanation: """
                        The product state of energy stays the same, the only thing that was \
                        lowered is the activation energy represented by the hump of the diagram.
                        """
                    )
                ],
                difficulty: .easy,
                image: LabelledImage(
                    image: "energy-profile-reaction-profile",
                    label: """
                    A reaction profile for an endothermic reaction (A + B to C), \
                    where the hump for line 2 is much below the hump of line 1. Line 2 starts and ends at the same energy level as line 1.
                    """
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-3",
                question: """
                Take a look at the energy diagram below that represents the pathway of a reaction. \
                The steps of the pathway are numbered:

                1: reactants, and 7: products. Fill the rest of the numbers accordingly.
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    1: Reactants, 2: Activated Complex, 3: Intermediate, 4: Activated Complex, \
                    5: Intermediate, 6: Activated Complex, 7: Products
                    """,
                    explanation: """
                    All energy profiles follow this order: reactants, activated complex, products. \
                    In this case there is an intermediate, so there would be two activated complexes.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        1: Reactants, 2: Reactants, 3: Intermediate, 4: Activated Complex, \
                        5: Intermediate, 6: Products, 7: Products
                        """,
                        explanation: """
                        The reaction mechanism has at least three activated complexes which are \
                        represented by the peaks of the diagram. Also, nothing formed along the \
                        pathway are reactants or products.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        1: Reactants, 2: Intermediate, 3: Activated Complex, 4: Intermediate, \
                        5: Activated Complex, 6: Intermediate, 7: Products
                        """,
                        explanation: """
                        The peaks represent the activated complex and not the intermediate.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        1: Reactants, 2: Activated Complex, 3: Intermediate, 4: Intermediate, \
                        5: Intermediate, 6: Activated Complex, 7: Products
                        """,
                        explanation: """
                        The intermediates (represented by the valleys) are always followed by \
                        another activated complex. Not every reaction has intermediates.
                        """
                    )
                ],
                difficulty: .hard,
                image: LabelledImage(
                    image: "energy-profile-reaction-pathway",
                    label: """
                    Reaction profile diagram with 3 peaks and 2 valleys, which are labelled from 1 to 7.

                    1: Start of reaction
                    2: First peak
                    3: First valley
                    4: Second peak
                    5: Second valley
                    6: Third peak
                    7: End of reaction, at a low energy
                    """
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-4",
                question: """
                Consider the following reactions and scenarios, and choose the one that would most \
                likely have the lowest activation energy to overcome:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "A reaction like H^+^ + OH^-^ ➝ H_2_O in the presence of a catalyst",
                    answerLabel: "A reaction like H^+^, + OH^-^, yields H_2_O, in the presence of a catalyst",
                    explanation: """
                    Correct, because in general, comparing both reactions, the formation of water \
                    by its ions $(H^+^ + OH^-^ ➝ H_2_O_3_)$ is spontaneous while the formation of \
                    nitrogen monoxide $(N_2_ + O_2_ ➝ 2NO)$ is non-spontaneous, so from the get-go, \
                    the spontaneous reaction would have a lower activation energy. Also, adding a \
                    catalyst lowers the activation energy of the reaction.
                    """,
                    explanationLabel: """
                    Correct, because in general, comparing both reactions, the formation of water \
                    by its ions $(H^+^ + OH^-^, yields H_2_O_3_)$ is spontaneous while the formation of \
                    nitrogen monoxide $(N_2_ + O_2_ ➝ 2NO)$ is non-spontaneous, so from the get-go, \
                    the spontaneous reaction would have a lower activation energy. Also, adding a \
                    catalyst lowers the activation energy of the reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A reaction like N_2_ + O_2_ ➝ 2NO without any catalyst",
                        explanation: """
                        The formation of nitrogen monoxide $(N_2_ + O_2_ ➝ 2NO)$ is a \
                        non-spontaneous reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A reaction like H6^+^ + OH^-^ ➝ H_2_O without any catalyst",
                        explanation: """
                        The formation of water by its ions $(H^+^ + OH^-^ ➝ H_2_O)$ is spontaneous \
                        but being in the presence of a catalyst would make the reaction faster.
                        """
                    ),
                    QuizAnswerData(
                        answer: " A reaction like N_2_ + O_2_ ➝ 2NO in the presence of a catalyst",
                        explanation: """
                        The decomposition of water $(N_2_ + O_2_ ➝ 2NO)$ is a non-spontaneous \
                        reaction, so even with the addition of a catalyst, its activation energy \
                        would most likely still be higher than other choices.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-5",
                question: """
                Consider a first order reaction as: $R ➝ Products$.

                In which scenario is it most likely for the reaction to have a higher rate of reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "[R] = 0.200M @70°C",
                    explanation: """
                    This option has the highest concentration of R and also the highest \
                    temperature, those conditions would boost the rate of the reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "[R] = 0.030M @5°C",
                        explanation: """
                        Take into account the rate law equation for a first order reaction, \
                        $rate = k[R]$, the lower the concentration of R, then the lower the rate \
                        of the reaction too. Also, take into account the Arrhenius equation, \
                        $k = Ae^(-Ea/RT)^$. The lower the temperature, then the lower the rate \
                        constant, which ultimately results in a lower rate of reaction.
                        """,
                        explanationLabel: """
                        Take into account the rate law equation for a first order reaction, \
                        rate = k[R], the lower the concentration of R, then the lower the rate \
                        of the reaction too. Also, take into account the Arrhenius equation, \
                        k = A, times e^(-EA/RT)^. The lower the temperature, then the lower the rate \
                        constant, which ultimately results in a lower rate of reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "[R] = 0.030M @70°C",
                        explanation: """
                        Take into account the rate law equation for a first order reaction, \
                        $rate = k[R]$. The lower the concentration of R, then the lower the rate of \
                        the reaction too.
                        """
                    ),
                    QuizAnswerData(
                        answer: "[R] = 0.200M @5°C",
                        explanation: """
                        Take into account the Arrhenius equation, $k = Ae^(-Ea/RT)^$. The lower \
                        the temperature, then the lower the rate constant, which ultimately results \
                        in a lower rate of reaction.
                        """,
                        explanationLabel: """
                        Take into account the Arrhenius equation, k = A, times e^(-EA/RT)^. The lower \
                        the temperature, then the lower the rate constant, which ultimately results \
                        in a lower rate of reaction.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-6",
                question: """
                There are different types of catalysts and they are often classified according to \
                their state of matter in relation with the reactants/products, and according to \
                what type of substance it is, etc. They all boost the rate of a reaction, but for \
                the following reaction:

                CH_2_=CH_2_(g) + H_2_O(g)===H_3_PO_4_ ➝ CH_3_CH_2_OH

                What type of catalyst is being used?
                """,
                questionLabel: """
                There are different types of catalysts and they are often classified according to \
                their state of matter in relation with the reactants/products, and according to \
                what type of substance it is, etc. They all boost the rate of a reaction, but for \
                the following reaction:

                CH_2_=CH_2_(g) + H_2_O(g)===H_3_PO_4_, yields CH_3_CH_2_OH

                What type of catalyst is being used?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Heterogeneous acid-base catalyst",
                    explanation: """
                    The catalyst is H_3_PO_4_, which is an acid. At the same time, it's a liquid \
                    while the reactants and products of this particular reaction are gaseous. \
                    Given that they're in different states of matter, the catalyst is considered heterogeneous.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Homogeneous acid-base catalyst",
                        explanation: """
                        Even though H_3_PO_4_ is in fact an acid, it's liquid while the reactants \
                        are gaseous, so it's not homogeneous.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Heterogeneous solid surface catalyst",
                        explanation: """
                        H_3_PO_4_ is a liquid catalyst and not a solid surface catalyst.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Homogeneous enzymatic catalyst",
                        explanation: """
                        H_3_PO_4_ is not an enzymatic catalyst but an acid-base one.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-7",
                question: """
                Determine what are the reactants of the overall reaction that has the following mechanism

                Step 1: A_2_ + B ➝ A + AB
                Step 2: AB + 2C ➝ A + BC_2_
                Step 3: A + D ➝ AD
                Step 4: A + AD ➝ A_2_ + D
                """,
                questionLabel: """
                Determine what are the reactants of the overall reaction that has the following mechanism:

                Step 1: A_2_ + B, yields A + AB.
                Step 2: AB + 2C, yields A + BC2.
                Step 3: A + D, yields AD.
                Step 4: A + AD, yields A_2_ + D.
                """,
                correctAnswer: QuizAnswerData(
                    answer: "C, D_2_",
                    explanation: """
                    The easiest way to determine the overall reaction is by summing up all steps \
                    and canceling out all of those species that repeat themselves in both reactant and product sides:

                    A_2_ + A + A + AB + B + 2C + AD + D ➝ A_2_ + A + A + AB + BC_2_ + AD + D

                    Canceling, we get:

                    B + 2C ➝ BC_2_
                    """,
                    explanationLabel: """
                    The easiest way to determine the overall reaction is by summing up all steps \
                    and canceling out all of those species that repeat themselves in both reactant and product sides:

                    A_2_ + A + A + AB + B + 2C + AD + D, yields, A_2_ + A + A + AB + BC_2_ + AD + D

                    Canceling, we get:

                    B + 2C yields BC_2_
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "B, BC_2_",
                        explanation: """
                        Even though BC_2_ is a product of the overall reaction, not a reactant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A_2_, B",
                        explanation: """
                        Even though B is a reactant of the reaction, there is A_2_ in both sides \
                        of the overall reaction, making it actually not a part of the overall reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A, B, BC_2_",
                        explanation: """
                        Even though B and BC_2_ are present in the overall reaction, A is not \
                        because it's being consumed as it's produced.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-8",
                question: """
                A catalyst is a substance that is used to boost the rate of reactions to \
                ultimately produce the desirable products faster. Knowing this, does the catalyst \
                take part in the reactions?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Yes, it takes part in the reaction. After the catalyst has served its \
                    function, it's recovered for its recycling.
                    """,
                    explanation: """
                    The catalyst can participate in the reaction as an intermediate that generates \
                    a "faster" pathway for the reaction to take. In some cases, it participates in \
                    other ways, like physically serving as a surface to increase the surface area \
                    where the reaction takes place.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Yes, it takes part in the reaction. It acts as a reactant of the reaction and increases the speed of it
                        """,
                        explanation: """
                        The catalyst can participate in the reaction, but not as a reactant of the \
                        overall reaction, but as an intermediate that generates another pathway \
                        for the reaction to follow for faster production.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        No, it doesn't take part in the reaction. By being added in the reaction, \
                        it makes the space in which the reactants interact smaller, pushing the \
                        molecules closer together
                        """,
                        explanation: """
                        The catalyst doesn't reduce the space of the reactants, on the contrary, \
                        they can sometimes provide space and serve as a surface to increase the \
                        surface area where the reaction takes place.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        No, it transfers its energy to the reactants, adding kinetic energy to the \
                        overall reaction, making the molecules go faster so when they collide, a \
                        successful collision would be more probable
                        """,
                        explanation: """
                        The catalyst doesn't transfer energy to the reactants or to the reaction. \
                        They're function is to lower the activation energy to make it easier to \
                        meet the requirements, not to increase the energy.
                        """
                    )
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-9",
                question: """
                Consider two reactions (reaction 1 and reaction 2). The black line (1) in the energy diagram \
                below represents reaction 1 and the red line (2) represents reaction 2. What is a true statement?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The activation energy of reaction 1 is the same one as the activation energy \
                    of reaction 2.
                    """,
                    explanation: """
                    The activation energy in the diagram is represented by the difference between \
                    the energy state at which the reactants are and the energy state at which an \
                    activated complex is formed to later become the products. In this diagram, \
                    that difference is the same for both reactions, so they have the same \
                    activation energy.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Reaction 1 was the original pathway for a reaction, which after a catalyst \
                        was added, became inefficient because reaction 2 is a pathway that results \
                        in a faster formation of the products.
                        """,
                        explanation: """
                        Cannot be true as a catalyst only lowers the activation energy, it doesn't \
                        lower the final energy of the reaction. Practically speaking, if a \
                        catalyst was added to a reaction, it would lower the hump in the diagram \
                        and not the products too.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The heat released in the reaction 1 is the same one as the heat in reaction 2.
                        """,
                        explanation: """
                        Even though both reactions are in fact exothermic, and do release heat \
                        when taking place, this heat is the difference between the energy state of \
                        the reactants and the energy state of the products, which is higher for \
                        the Reaction 1, because the reactants start at a higher point of energy.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Reaction 1 and reaction 2 have different reactants but end up with the \
                        same products.
                        """,
                        explanation: """
                        The reactions in the diagram might very well be different reactions \
                        entirely. This is an energy diagram, so it only represents the energy in \
                        every step of the pathway for both reactions. However, they do end up \
                        with products that are in the same energy state.
                        """
                    )
                ],
                difficulty: .hard,
                image: LabelledImage(
                    image: "energy-profile-reaction-profile-2",
                    label: """
                    Energy profile chart with two lines, 1 and 2, each with a single hump.
                    Reactants of line 1 have a higher energy than line 2, and the hump for line 1 \
                    is higher than line 2 by the same amount. Both lines have the same energy level for \
                    the products, which is lower than the reactant energy levels.
                    """
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-10",
                question: """
                A reaction $(2AB + C_2_ ➝ 2C_2_B)$ has the proposed mechanism:

                Step 1: AB + AB ➝ A_2_B_2_ (fast)
                Step 2: A_2_B_2_ + C_2_ ➝ A_2_B + C_2_B (slow)
                Step 3: A_2_B + C_2_ ➝ A_2_ + C_2_B (fast)

                What is the rate law of the overall equation and which one would be the \
                rate-determining step?
                """,
                questionLabel: """
                A reaction 2 AB, + C_2_, yields 2C_2_B,  has the proposed mechanism:

                Step 1: AB + AB, yields A_2_B_2_ (fast).
                Step 2: A_2_B_2_, + C_2_, yields A_2_B, + C_2_B (slow).
                Step 3: A_2_B, + C_2_, yields A_2_, + C_2_B (fast).

                What is the rate law of the overall equation and which one would be the \
                rate-determining step?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The rate law of the reaction is $rate=k[AB]^2^[C_2_]$ and the \
                    rate-determining step is step 2.
                    """,
                    answerLabel: """
                    The rate law of the reaction is rate = k, times [AB]^2^, times [C_2_], and the \
                    rate-determining step is step 2.
                    """,
                    explanation: """
                    The rate-determining step would be the slowest step, which in this case is \
                    step 2 $(A_2_B_2_ + C_2_ ➝ A_2_B + C_2_B)$. The rate law equation would be \
                    determined by this step, being $rate = k[A_2_B_2_][C_2_]$. However, A_2_B_2_ \
                    is neither a reactant nor a product of the overall reaction, so it has to be \
                    substituted by the reactants from which it comes $(AB + AB ➝ A_2_B_2_)$. \
                    $Rate = k[AB]^2^[C_2_]$.
                    """,
                    explanationLabel: """
                    The rate-determining step would be the slowest step, which in this case is \
                    step 2 (A_2_B_2_ + C_2_, yields A_2_B + C_2_B). The rate law equation would be \
                    determined by this step, being rate = k, times [A_2_B_2_], times [C_2_]. \
                    However, A_2_B_2_ is neither a reactant nor a product of the overall reaction, so it has to be \
                    substituted by the reactants from which it comes (AB + AB, yields A_2_B_2_). \
                    Rate = k, times [AB]^2^, times [C_2_].
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The rate law of the reaction is $rate=k[A_2_B_2_][C_2_]$ and the \
                        rate-determining step is step 2.
                        """,
                        answerLabel: """
                        The rate law of the reaction is rate = k, times [A_2_B_2_], times [C_2_] and the \
                        rate-determining step is step 2.
                        """,
                        explanation: """
                        Step 2 is indeed the rate-determining step, but A_2_B_2_ is not a reactant \
                        of the overall reaction but rather an intermediate, so it cannot be part \
                        of the rate law equation.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate law of the reaction is $rate=k[AB]^2^$ and the rate-determining \
                        step is step 1.
                        """,
                        answerLabel: """
                        The rate law of the reaction is rate = k, times [AB]^2^, and the rate-determining \
                        step is step 1.
                        """,
                        explanation: """
                        The rate-determining step would be the slowest of the steps, because the \
                        reaction cannot go faster than the slowest of the steps. Since step 1 is a \
                        fast one, then it cannot be the rate determining step.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate law of the reaction is $rate=k[A_2_B][C_2_]$ and the \
                        rate-determining step is step 3
                        """,
                        answerLabel: """
                        The rate law of the reaction is rate = k, times [A_2_B], times [C_2_], and the \
                        rate-determining step is step 3
                        """,
                        explanation: """
                        Since step 3 is not the slowest of the steps, then it isn't the \
                        rate-determining step. Besides that, A_2_B is not part of the overall \
                        reaction, so it can't be part of the rate law equation.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-11",
                question: """
                An experiment was conducted to test two different catalysts: catalyst A and \
                catalyst B. Both were tested for the same reaction at different temperatures. \
                Wether the reactants completely transformed into the products was also registered \
                in the table below:
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Catalyst B is the most effective one because it takes less energy for the \
                    reaction to go to completion when the catalyst is present.
                    """,
                    explanation: """
                    Raising the temperature is one way to make energy enter the reaction for it to \
                    take place. Catalysts are supposed to lower the energy required by the reaction \
                    (activation energy) so if the reaction went to completion at 400K in the \
                    presence of the catalyst B, it means that it needed less energy than when the \
                    reaction was in presence of the catalyst A.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Catalyst A is the most effective one because it resulted in a higher temperature for the reaction
                        """,
                        explanation: """
                        Catalyst A didn't "result in a higher temperature". The temperature had to \
                        be increased to 420K for the reaction to go to completion when adding catalyst A.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Catalyst B is the most effective one because it made the reaction go to \
                        completion in both temperature points 420K and 400K.
                        """,
                        explanation: """
                        Catalyst B isn't the most effective one because of that, the important \
                        thing is the actual temperature at which the reaction takes place in the \
                        presence of the catalyst.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        There's no way to know in these few experiments which one of the catalysts \
                        is the most effective one.
                        """,
                        explanation: """
                        It's totally possible to determine which catalyst is the most effective \
                        one by comparing the energy required for it to go to completion in the \
                        presence of the catalysts.
                        """
                    )
                ],
                difficulty: .medium,
                table: QuizTable(
                    rows: [
                        ["Catalyst", "Reaction temperature", "Reaction completed?"],
                        ["A", "400K", "No"],
                        ["A", "420K", "Yes"],
                        ["B", "400K", "Yes"],
                        ["B", "420K", "Yes"]
                    ]
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-12",
                question: """
                Consider the following reaction diagram. Which of the elementary steps requires \
                more energy to take place?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Section 5-6-7",
                    explanation: """
                    In the diagram, the difference between where the reaction starts with reactants \
                    (in this case, on the right for the reverse reactions) and the peak of the hump \
                    is the activation energy, or what is the same, the energy barrier to overcome.

                    For 1 (reactants) to get to 3, the activation energy is the difference between \
                    1 and 2. Since it is very small, it means it has a low activation energy.

                    For 3 to get to 5 (products), the activation energy is the difference between 3 \
                    and 4. Since it is a little bit bigger, it means it has a higher activation \
                    energy than from 1 to 3.

                    Finally, for 5 to get to 7, the activation energy is the difference between 5 \
                    and 6, which is the highest of all the elementary steps.

                    We get then that: section 5-6-7 > section 3-4-5 > section 1-2-3. Notice how the \
                    activation energy doesn't depend on the product side of the hump, \
                    but only on the reactants side.
                    """,
                    explanationLabel: """
                    In the diagram, the difference between where the reaction starts with reactants \
                    (in this case, on the right for the reverse reactions) and the peak of the hump \
                    is the activation energy, or what is the same, the energy barrier to overcome.

                    For 1 (reactants) to get to 3, the activation energy is the difference between \
                    1 and 2. Since it is very small, it means it has a low activation energy.

                    For 3 to get to 5 (products), the activation energy is the difference between 3 \
                    and 4. Since it is a little bit bigger, it means it has a higher activation \
                    energy than from 1 to 3.

                    Finally, for 5 to get to 7, the activation energy is the difference between 5 \
                    and 6, which is the highest of all the elementary steps.

                    We get then that: section 5 6 7 is bigger than section 3 4 5, which is bigger than \
                    section 1 2 3. Notice how the  activation energy doesn't depend on the product side of the hump, \
                    but only on the reactants side.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Section 3-4-5",
                        answerLabel: "Section 3 4 5",
                        explanation: """
                        For 3 to get to 5 (products), the activation energy is the difference \
                        between 3 and 4, which is not large enough compared to other steps.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Section 1-2-3",
                        answerLabel: "Section 1 2 3",
                        explanation: """
                        For 1 (reactants) to get to 3, the activation energy is the difference \
                        between 1 and 2. Since it is very small, it means it has a very low \
                        activation energy.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Cannot be determined",
                        explanation: """
                        The energy profile or diagram of a reaction mechanism would be enough to \
                        determine at least the activation energy of each step.
                        """
                    )
                ],
                difficulty: .medium,
                image: LabelledImage(
                    image: "energy-profile-reaction-coordinate",
                    label: """
                    Energy profile of an exothermic reaction, with 3 peaks and two valleys, and 7 points labelled from 1 to 7.
                    1: Start of reaction, at a high energy.
                    2: First peak, very small increase from point 1.
                    3: First valley, very large drop from point 2.
                    4: Second peak, moderate increase from point 3.
                    5: Second peak, very small drop from point 4.
                    6: Third peak, very large increase from point 5.
                    7: End of reaction, very large drop from point 6.
                    """
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-13",
                question: """
                Reactants molecules can collide without resulting in the formation of the products \
                of the reaction. What has to happen in order for the collision to be successful?
                """,
                correctAnswer:
                    QuizAnswerData(
                        answer: """
                        The molecules colliding have to be specifically oriented while also having \
                        enough energy to overcome the activation energy.
                        """,
                        explanation: """
                        Both the orientation and the kinetic energy of the molecules are factors \
                        that are required for a successful collision to take place.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The molecules colliding have to be in a specific orientation",
                        explanation: """
                        Is true, but only the orientation won't be enough to guarantee a successful collision.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The molecules colliding have to have enough kinetic energy
                        """,
                        explanation: """
                        Is true, but the molecules having enough energy won't guarantee a successful collision.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The molecules colliding have to be in the same state of matter",
                        explanation: """
                        Is not true, the molecules don't have to be in any particular state of \
                        matter for a successful collision to occur.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-14",
                question: """
                Consider a reaction represented by the energy diagram below. What is a true statement about this \
                reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "The reaction has three activated complex and the overall reaction is exothermic",
                    explanation: """
                    At a first glance it's noticeable that the reaction has three humps that \
                    represent the activated complex, meaning that it has three steps (three \
                    elementary reactions that compose the overall reaction). Reactants started at \
                    a higher energy state in comparison to the energy of the final products, \
                    meaning that energy was released, making the reaction exothermic.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The reaction has three intermediates and the overall reaction is exothermic",
                        explanation: """
                        The three humps represent the activated complex, not the intermediates
                        """
                    ),
                    QuizAnswerData(
                        answer: "The reaction has three activated complex and the overall reaction is endothermic",
                        explanation: """
                        The reactants start at a higher energy state than the products, so the \
                        difference is negative, making the reaction release energy when it takes place.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The reaction has three intermediates and the overall reaction is endothermic.",
                        explanation: """
                        Try comparing the points of energy at which the diagram starts and end, \
                        and take into account the humps represent the activated complex.
                        """
                    )
                ],
                difficulty: .easy,
                image: LabelledImage(
                    image: "energy-profile-reaction-profile-3",
                    label: """
                    Energy profile diagram with three humps, where the products energy state is \
                    less than the reactants energy state
                    """
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-15",
                question: """
                Consider a first order reaction (A ➝ B). What is an action you can take to increase \
                the speed of the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "All of the above",
                    explanation: """
                    All these actions may lead to an improvement on the rate of the reaction, \
                    forming products at a much higher rate in most cases.
                    """,
                    position: .D
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Increase the temperature of the reaction",
                        explanation: """
                        A way to increase the kinetic energy of the molecules, creating a higher \
                        frequency of collisions and increasing the changes that the collisions \
                        meet the energy requirements to be successful is by increasing the temperature.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Add a catalyst that creates another more efficient pathway to follow",
                        explanation: """
                        Adding a catalyst would ultimately decrease the activation energy, making \
                        the reaction go faster.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Add more of A to the mixture to increase its concentration.",
                        explanation: """
                        Adding more of A, since it's a first order reaction $(rate = k[A])$, the \
                        higher the concentration is, the faster the reaction will go.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-16",
                question: """
                How does the temperature affect the rate of a reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Increasing the temperature would charge the molecules with a higher kinetic \
                    energy so the potential energy when collision happens would be enough, or more \
                    than enough, to overcome the activation energy
                    """,
                    explanation: """
                    A high temperature will result in molecules with higher kinetic energy that \
                    will result in more successful collisions.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Increasing the temperature would lead to a lowering of the energy required \
                        for the reaction to take place
                        """,
                        explanation: """
                        Increasing the temperature will not lower the energy required for the \
                        reaction to take place.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Increasing the temperature would fix the orientation of the molecules so \
                        when they collide they are properly oriented and form products
                        """,
                        explanation: """
                        Increasing the temperature would only increase the kinetic energy of the \
                        molecules.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Increasing the temperature would make the liquid evaporate thus provoking \
                        a gaseous mixture in which collisions are more often than not successful
                        """,
                        explanation: """
                        Increasing the temperature can ultimately in some cases lead to a change \
                        in the state of matter of the compounds, but this is not the fundamental \
                        relationship between temperature and the rate of a reaction.
                        """
                    ),
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-17",
                question: """
                Which one of these elementary reactions would probably be the slowest one within a mechanism?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "A + B + C + D ➝ E + F",
                    answerLabel: "'A' + B + C + D ➝ E + F",
                    explanation: """
                    This would probably be the slowest reaction because in comparison to the rest \
                    of the reactions, this one has four reactants, which implies that a successful \
                    collision of 4 molecules has to take place for the reaction to occur.

                    Since the probability of this happening is lower, the chance of this \
                    reaction to be slower than the other ones is greater. Being the slowest of \
                    all the steps, this would be the rate-determining step.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "G + H + I ➝ J",
                        answerLabel: "G + H + I, to J",
                        explanation: """
                        G + H + I, three reactants (termolecular reaction), colliding successfully \
                        is a little more likely to happen than some of these other scenarios.
                        """
                    ),
                    QuizAnswerData(
                        answer: "K ➝ L + M + N",
                        answerLabel: "K to L + M + N",
                        explanation: """
                        K, being only one reactant, doesn't even need a collision for it to take \
                        place, so it should be the fastest one.
                        """
                    ),
                    QuizAnswerData(
                        answer: " O + P ➝ Q",
                        answerLabel: " O + P, to Q",
                        explanation: """
                        O + P, two reactants (bimolecular reaction), colliding successfully is more \
                        likely to happen than some of these other scenarios.
                        """
                    )
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-18",
                question: """
                Consider a reaction represented by the energy diagram below. What is a true statement about this \
                reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    This is an exothermic reaction with a mechanism with an intermediate
                    """,
                    explanation: """
                    At a first glance it's noticeable that the reaction starts with the reactants \
                    being at a higher energy state than the products, meaning that the reaction is \
                    exothermic since it's going to release energy. For each step an activated \
                    complex is formed, but between both steps an intermediate is produced.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        This is an endothermic reaction with a mechanism with an intermediate
                        """,
                        explanation: """
                        The reactants start at a higher point of energy than the products, so \
                        energy is being released when the reaction takes place.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        This is an exothermic reaction with a mechanism with an activated complex
                        """,
                        explanation: """
                        Not one, but two activated complexes are formed in this mechanism \
                        (represented by the humps or peaks).
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        This is an endothermic reaction with a mechanism with an activated complex
                        """,
                        explanation: """
                        Not only are two activated complexes formed, but the reaction releases \
                        energy instead of absorbing it.
                        """
                    )
                ],
                difficulty: .medium,
                image: LabelledImage(
                    image: "energy-profile-energy-diagram",
                    label: """
                    Energy profile diagram with two humps, where the products are at a lower \
                    energy state than the reactants.
                    """
                )
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-19",
                question: """
                What is a false statement about catalysts?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Catalysts are called heterogeneous when they are in a different state of matter \
                    compared to the reactants
                    """,
                    explanation: """
                    Catalysts can be classified in heterogeneous (when they're in different state \
                    of matter) and homogeneous (when they're the same).
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Catalysts do not change the mechanism of a reaction.
                        """,
                        explanation: """
                        Catalysts do change the mechanism. They create another pathway for the \
                        reaction to follow that is more efficient.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Catalysts lower the energy required for the reaction to take place.
                        """,
                        explanation: """
                        Catalysts lower the activation energy, making it easier for the kinetic \
                        energy of the molecules to overcome it.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Catalysts can be recycled after the reaction takes place.
                        """,
                        explanation: """
                        Catalysts are often recycled in the later steps of the reaction to use it \
                        once more.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                id: "ENERGYPROFILE-20",
                question: """
                The position of a reaction $(A + B ➝ C)$ is right now being represented by the \
                red vertical line in the energy diagram below. At that point, what could be happening?
                """,
                questionLabel: """
                The position of a reaction $(A + B, to C)$, is right now being represented by the \
                red vertical line in the energy diagram below. At that point, what could be happening?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Molecules of A and B colliding unsuccessfully because of their lack of kinetic \
                    energy, making them unable to form an activated complex.
                    """,
                    explanation: """
                    At this point, molecules of A and B colliding are lacking the energy to meet \
                    the energy requirements.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Molecules of A and B barely colliding successfully, just starting to form \
                        an activated complex.
                        """,
                        explanation: """
                        Molecules of A and B won't collide successfully at this point because of \
                        the lack of energy.
                        """
                    ),
                    QuizAnswerData(
                        answer: "An activated complex has been formed but it still hasn't transformed into C",
                        explanation: """
                        The activated complex is represented by the hump, so since the reaction is \
                        not yet at that point, no activated complex has been formed just yet.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Molecules of reactants colliding successfully with enough energy to form C molecules
                        """,
                        explanation: """
                        The production of C would start occurring after the activated complex was \
                        formed, and at this point molecules lack the energy to create the \
                        activated complex.
                        """
                    )
                ],
                difficulty: .medium,
                image: LabelledImage(
                    image: "energy-profile-reaction-progress",
                    label: """
                    Energy profile diagram with a single hump, where the product is at a higher \
                    energy state than the reactants. There is a red vertical line on the left side \
                    of the diagram where the energy state is the same as at the start of the reaction, \
                    before the hump.
                    """
                )
            ),
        ]
    )
}
