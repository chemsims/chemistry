//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let energyProfileQuizQuestions = QuizQuestionsList(
        questionSet: .energyProfile,
        [
            QuizQuestionData(
                question: "What is the concept of Activation Energy (E_a_)?",
                correctAnswer: QuizAnswerData(
                    answer:  "The energy required to form the transition state in a chemical reaction",
                    explanation: """
                This is the definition of Activation Energy. It's the one that's required for a chemical \
                reaction to take place
                """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                    The energy required to convert a ground-state atom in the gas phase to a gaseous \
                    positive ion
                    """,
                        explanation: "This is the definition of Ionization Energy"
                    ),
                    QuizAnswerData(
                        answer: """
                    The energy change that occurs in the conversion of an ionic solid to widely separated \
                    gaseous ions
                    """,
                        explanation: "This is the definition of Lattice Energy"
                    ),
                    QuizAnswerData(
                        answer: "The energy in a chemical or physical change that is available to do useful work",
                        explanation: "This is the definition of Gibbs Free Energy"
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            Consider the energy diagram below. By adding the catalyst, this one has created a new pathways \
            that's being represented by the red line (line 2) in the diagram. How exactly does this make the \
            reaction faster?
            """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The catalyst lowers the activation energy required for the reaction to take place, making the \
                    transition state more stabilized
                    """,
                    explanation: """
                    The red line represents the new pathway created, and it has a much lower \
                    activation energy making it easier for the reactants to meet the energy \
                    requirements to react.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Adding the catalyst creates two different pathways for the reactants to form products
                        """,
                        explanation: """
                        Although a new pathway is created by adding the catalyst, the grey pathway \
                        requires much more activation energy, which would make it less likely to \
                        be used, making this answer not so accurate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The catalyst increases the heat, leading to a less stabilized transition state",
                        explanation: """
                        Notice how the products and reactants stay in the same place in the \
                        diagram for both lines or pathways, so that makes this answer incorrect \
                        since the heat (difference in energy between reactants and products) \
                        remains the same.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The catalyst alters the reactants, leading to an alternate energy pathway",
                        explanation: """
                        Notice how the products and reactants stay in the same place in the \
                        diagram for both lines or pathways, so that makes this answer incorrect \
                        because the reactants stay the same.
                        """
                    )
                ],
                difficulty: .easy,
                image: "energy-profile-reaction-profile"
            ),
            QuizQuestionData(
                question: """
                The energy profile of a reaction shows the successful collision of molecules. Which is the right \
                order for an energy profile when reading it from left or right?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Reactants, Activated Complex, Intermediate, Activated Complex, Products
                    """,
                    explanation: """
                    All energy profiles follow this order: Reactants, Activated Complex, Products. \
                    In this case there is an intermediate, so there would be two activated complex.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Reactants, Intermediate, Activated Complex, Products",
                        explanation: """
                        The reaction mechanism has at least two activated complex which are \
                        represented by the peaks of the diagram.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Reactants, Intermediate, Activated Complex, Intermediate, Products",
                        explanation: """
                        The diagram starts with reactants, but the peak represents an activated \
                        complex and not an intermediate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Reactants, Activated Complex, Intermediate, Products",
                        explanation: """
                        The intermediate (represented by the valley) is always followed by another \
                        activated complex which is in this case the second peak. Not every \
                        reaction has intermediates.
                        """
                    )
                ],
                difficulty: .hard,
                image: "energy-profile-reaction-pathway"
            ),
            QuizQuestionData(
                question: """
                Which of the following has the lowest Activation Energy?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "H_2_O + CO_2_ ⇌ H_2_CO_3_ (In the presence of a catalyst)",
                    explanation: """
                    Correct answer is A, because in general, comparing both reactions, the formation of carbonic \
                    acid $(H2O + CO2 ⇌ H2CO3)$ is spontaneous while the decomposition of water $(2H2O ⇌ 2H2 + O2)$ \
                    is non-spontaneous, so from the get-go, the spontaneous reaction would have a lower activation \
                    energy.

                    An inhibitor is meant to slow down a reaction while a catalyst is meant to speed the reaction \
                    up, so that's why the formation of carbonic acid with a catalyst would have the lowest \
                    activation energy.
                    """,
                    position: .A
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "2H_2_O ⇌ 2H_2_ + O_2_ (In an open system)",
                        explanation: """
                        The decomposition of water (2H_2_O ⇌ 2H_2_ + O_2_) is a non-spontaneous reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "H_2_O + CO_2_ ⇌ H_2_CO_3_ (In an open system)",
                        explanation: """
                        The formation of carbonic acid (H_2_O + CO_2_ ⇌ H_2_CO_3_) but being in \
                        the presence of a catalyst would make the reaction faster.
                        """
                    ),
                    QuizAnswerData(
                        answer: "2H_2_O ⇌ 2H_2_ + O_2_ (In the presence of an inhibitor)",
                        explanation: """
                        The decomposition of water (2H_2_O <==> 2H_2_ + O_2_) is a \
                        non-spontaneous reaction, besides, an inhibitor would actually slow down \
                        the reaction even more.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                question: """
                A student puts 100 mg of a piece of metal to a hydrochloric acid solution, which triggers a \
                reaction. Which conditions would make the reaction go at a faster rate?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "[HCl] = 0.200M @70°C",
                    explanation: """
                    This option has the highest concentration of HCl and also the highest \
                    temperature, those conditions would boost the rate of the reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "[HCl] = 0.030M @5°C",
                        explanation: """
                        Low concentrations of [HCl] and low temperatures would make the reaction \
                        very slow.
                        """
                    ),
                    QuizAnswerData(
                        answer: "[HCl] = 0.030M @70°C",
                        explanation: """
                        Low concentrations of [HCl] would make the reaction slow.
                        """
                    ),
                    QuizAnswerData(
                        answer: "[HCl] = 0.200M @5°C",
                        explanation: """
                        Low temperatures would make the reaction slow.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Catalyst can be of different shapes and different states of matter, but which kind of catalyst \
                is being added to the reaction below to increase the rate of the reaction?

                CH_3_CH_2_OH_(g)_ + HCl_(g)_ ➝ CH_3_CH_2_Cl + H_2_O_(l)_
                """,
                correctAnswer: QuizAnswerData(
                    answer: "A heterogeneous acid-base catalyst",
                    explanation: """
                    Being the catalyst H_2_SO_4_, is an acid that allows the transfer of hydroxide between \
                    reactants. Since it's an acid, it's liquid, meaning that its state of matter is different from \
                    the reactants that are gaseous, so it's also heterogeneous.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A homogeneous acid-base catalyst",
                        explanation: """
                        Even though H_2_SO_4_ is in fact an acid, it's liquid while the reactants \
                        are gaseous, so it's not homogeneous.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A heterogeneous solid surface catalyst",
                        explanation: """
                        H_2_SO_4_ is a liquid catalyst and not a solid surface catalyst.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A homogeneous redox catalyst",
                        explanation: """
                        H_2_SO_4_ is not a redox catalyst but an acid-base one.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            Determine what are the reactants of the overall reaction that has the following mechanism

            Step 1: A + B ➝ AB
            Step 2: AB + C ➝ CB + A
            Step 3: CB + D_2_ ➝ DB + CD
            Step 4: DB + C ➝ CD + B
            """,
                correctAnswer: QuizAnswerData(
                    answer: "C, D_2_",
                    explanation: """
                    The easies way to determine the overall reaction is by summing up all steps and cancel out all \
                    of those species that repeat themselves in both reactant and product sides:

                    A + B + AB +CB + D_2_ + DB + 2C ➝ AB + CB + A + DB + 2CD + B

                    Canceling, we get:

                    D_2_ + 2C ➝ 2CD.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A, B, C, D_2_",
                        explanation: """
                        Even though D_2_ is a product of the reaction, there are A + B in both \
                        sides of the overall reaction, making them actually not being part of the \
                        overall reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A, B, C",
                        explanation: """
                        Even though C is a reactant of the reaction, there are A + B in both sides \
                        of the overall reaction, making them actually not being part of the \
                        overall reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A, C, D_2_",
                        explanation: """
                        Even though C and D_2_ are present in the overall reaction, A is not \
                        because it's being consumed as it's produced.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                How does a catalyst affects a reaction without taking a part in it?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    It participates in the reaction, but is then recovered in the later steps of \
                    the reaction
                    """,
                    explanation: """
                    The catalyst, even though is not a reactant or a product, it participates in \
                    the reaction and can react in the mechanism steps, but in the later steps the \
                    catalyst is entirely recovered.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        It doesn't participate in the reaction. Just by being near the reactants it \
                        makes the reaction faster
                        """,
                        explanation: """
                        The catalyst does take part of the reaction. For it to lower the activation \
                        energy, it can participate in smaller steps to create a mechanism pathway that \
                        requires less energy, and it's then regenerated. Even in the case the catalyst \
                        doesn't directly participate in the reaction chemically, it can participate \
                        physically by serving as a surface in which the reactants can interact easier.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        It encourages collisions because it reduces the space the reactants have to \
                        move around
                        """,
                        explanation: """
                        The catalyst doesn't reduce the space of the reactants, on the contrary, \
                        they can sometimes provide space and serve as a surface to increase the \
                        surface area where the reaction takes place.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        It transfers its energy to the reactants, adding energy to the overall \
                        reaction and lowering the energy needed for it to occur
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
                question: """
            Consider two reactions (reaction A and reaction B). The black line (A) in the energy diagram \
            below represents reaction A and the red line (B) represents reaction B. What is a true statement?
            """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The reverse reaction of B has the same relative activation energy as the \
                    reverse reaction of A
                    """,
                    explanation: """
                    The reverse reaction of B has the same relative activation energy as the \
                    reverse reaction of A because the difference in energy between the line when \
                    the reaction is starting and the peak of the activation energy is the same for \
                    both reactions.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer:
                            "Both reactions are the same one but a catalyst was used for reaction B",
                        explanation: """
                        Cannot be true as a catalyst only lowers the activation energy, it doesn't lower the \
                        final energy of the reaction
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The forward reaction of B has a higher activation energy than the forward reaction of A
                        """,
                        explanation: "Reaction A actually has a higher activation energy than reaction B"
                    ),
                    QuizAnswerData(
                        answer: "The rate of reaction B is half of the rate of reaction A",
                        explanation: """
                        The rate of reaction A, since it has a higher activation energy, should \
                        actually be slower too
                        """
                    )
                ],
                difficulty: .hard,
                image: "energy-profile-reaction-profile-2"
            ),
            QuizQuestionData(
                question: """
                A reaction $(2A + B ➝ A_2_B)$ has the proposed mechanism:

                Step 1: A + B ➝ M (slow)
                Step 2: M + A ➝ A_2_B (fast)

                What is a true statement about this mechanism?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The rate law of the reaction is $rate = k[A][B]$ and the rate-determining step \
                    is bimolecular
                    """,
                    explanation: """
                    The rate determining step would be the slowest step, which in this case is Step 1 $(A + B ➝ M)$. \
                    A termolecular step would be the one with three reactants, since this one only has two \
                    (A and B), it is said that it's bimolecular.

                    On the other hand, the rate law equation is determined by the rate determining step, and since \
                    the slowest reaction is $A + B ➝ M$, then it's safe to say that the rate law equation is \
                    $Rate = k[A][B]$.

                    Since A and B are in fact reactants of the overall reaction, then the equation stays that way.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The rate law of the reaction is $rate=k[A][B]$ and the rate-determining \
                        step is termolecular
                        """,
                        explanation: """
                        A termolecular step would be the one with three reactants, and in this one \
                        there are only two (A and B).
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate law of the reaction is $rate=k[A]^2^[B]$ and the rate-determining \
                        step is bimolecular
                        """,
                        explanation: """
                        Even though it is a bimolecular step, $rate = k[A]^2^[B]$ would not be the \
                        rate law equation of the overall reaction. Only the collision between A \
                        and B counts since it's the slowest step, so that would be the \
                        rate-determining step.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate law of the reaction is $rate=k[A]^2^[B]$ and the rate determining step is termolecular
                        """,
                        explanation: """
                        Not only it's not only a termolecular step, but $rate = k[A]^2^[B]$ is not \
                        the rate law equation of the overall reaction.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                question: """
            A student conducted an experiment that consisted in testing 4 different catalyst in the same \
            reaction and monitor the temperature at which the reaction occurred to its completion. Which of \
            the four catalyst would be the most effective one?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "4",
                    explanation: """
                    The reaction in the 4th experiment occurred at a temperature of 360K which is \
                    the lowest of them all, meaning that the catalyst lowered the activation \
                    energy to the point at which that temperature was enough to make the reaction \
                    happen. That catalyst would be the most effective for that reaction in particular.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "1",
                        explanation: """
                        Compared to the rest of the experiments, this catalyst could only lower \
                        the activation energy to a point in which the reaction takes place at 400K.
                        """
                    ),
                    QuizAnswerData(
                        answer: "2",
                        explanation: """
                        Compared to the rest of the experiments, this catalyst could only lower \
                        the activation energy to a point in which the reaction takes place at 410K.
                        """
                    ),
                    QuizAnswerData(
                        answer: "3",
                        explanation: """
                        Compared to the rest of the experiments, this catalyst could only lower \
                        the activation energy to a point in which the reaction takes place at 380K.
                        """
                    )
                ],
                difficulty: .medium,
                table: QuizTable(
                    rows: [
                        ["Catalyst", "Temperature at which the reaction took place"],
                        ["1", "400K"],
                        ["2", "410K"],
                        ["3", "380K"],
                        ["4", "360K"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
                Consider the following energy diagram and determine, which reverse reaction has \
                the highest activation energy?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "E to C",
                    explanation: """
                    In the diagram, the difference between where the reaction starts with reactants (in this case, \
                    on the right for the reverse reactions) and the peak of the hump is the activation energy.

                    For G (reactants) to get to E, the activation energy is the difference between G and F, which since it \
                    is very small, it means it has a low activation energy.

                    For C to get to A (products), the activation energy is the difference between C and B, which \
                    since it is a little bit bigger, it means it has a higher activation energy than from G to E.

                    Finally, for E to get to C, the activation energy is the difference between E and D, which is \
                    the highest of all the reverse reactions. We get then that: E to C > C to A > G to E.

                    Notice how the activation energy doesn't depend on the product side of the hump, but only on the \
                    reactants side.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "C to A",
                        explanation: """
                        For C to get to A (products), the activation energy is the difference \
                        between C and B, which since it is a little bit bigger, it means it has a \
                        higher activation energy than from G to E.
                        """
                    ),
                    QuizAnswerData(
                        answer: "G to E",
                        explanation: """
                        For G (reactants) to get to E, the activation energy is the difference \
                        between G and F, which since it is very small, it means it has a low \
                        activation energy.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Cannot be determined",
                        explanation: """
                        The energy profile or diagram of a reaction mechanism would be enough to \
                        determine at least the activation energy of each step both forward or reverse.
                        """
                    )
                ],
                difficulty: .medium,
                image: "energy-profile-reaction-coordinate"
            ),
            QuizQuestionData(
                question: """
            In the reaction A + B ➝ C, that a molecule of A collides with a molecule B doesn't 100% mean \
            that a molecule of C will be produced. What are some factors that help to determine if a \
            collision of two molecules will be successful?
            """,
                correctAnswer:
                    QuizAnswerData(
                        answer: """
                        Molecules of A and B have to be properly oriented and to have enough energy that's \
                        enough to surpass the activation energy when the collision takes place.
                        """,
                        explanation: """
                        Would be the correct answer because both the orientation and the kinetic energy of the \
                        molecules are factors that are required for a successful collision to take place
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer:
                            "Molecules of A and B have to be properly oriented when the collision takes place",
                        explanation: """
                        Is true, but only the orientation won't be enough to guarantee a successful collision
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Molecules of A and B have to have enough energy that's enough to surpass the activation \
                        energy
                        """,
                        explanation: """
                        Is true, but the molecules having enough energy won't guarantee a successful collision
                        """
                    ),
                    QuizAnswerData(
                        answer: "Molecules of A and B have to be gaseous when the collision takes place",
                        explanation: """
                        Is not true, the molecules don't have to be in any particular state of matter for a \
                        successful collision to occur
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider a reaction represented by the energy diagram below. What is a true statement about this \
                reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "It has a three-step mechanism and it's an endothermic reaction",
                    explanation: """
                    At a first glance is noticeable that the reaction has three humps representing the activated \
                    complexes, meaning that it has three step (three elementary reactions that compose the overall \
                    reaction).

                    Reactants started at a lower energy in comparison to the energy of the final products, meaning \
                    that energy was consumed by the overall reaction to occur.

                    In other words, the reaction is endothermic because it absorbed energy instead of releasing it. \
                    Considering these things, this is the correct answer.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "It has a two-step mechanism and it's an endothermic reaction",
                        explanation: """
                        The three humps represent the activated complex, which means that it has a \
                        three step mechanism.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It has a three-step mechanism and it's an exothermic reaction",
                        explanation: """
                        The reactants start at a lower point of energy, so energy is actually \
                        absorbed when the reaction takes place.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It has a two-step mechanism and it's an exothermic reaction",
                        explanation: """
                        Try comparing the points of energy at which the diagram starts and end, \
                        and count how many activated complexes are in the overall reaction.
                        """
                    )
                ],
                difficulty: .easy,
                image: "energy-profile-reaction-profile-3"
            ),
            QuizQuestionData(
                question: """
                A student is decomposing hydrogen peroxide (as shown in the reaction below) and wants to speed \
                up the rate of decomposition. What should he do?

                H_2_O_2(g)_ ➝ H_2(g)_ + O_2(g)_
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Increase the temperature",
                    explanation: """
                    A way to increase the kinetic energy of the molecules, creating a higher frequency of collisions \
                    and increasing the changes that the collisions meet the energy requirements to be successful is \
                    by increasing the temperature.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Decrease the temperature",
                        explanation: """
                        Decreasing the temperature might actually lower the speed of the reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Decrease the surface area of the particles in solution",
                        explanation: """
                        Actually, increasing the surface area of the particles to increase the \
                        likelihood that resulting collisions would fulfil the requirement of \
                        proper orientation.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Decrease the stirring on the mixture",
                        explanation: """
                        Stirring the mixture always helps a reaction to keep going but it would \
                        not necessarily help speeding up the reaction or at least not \
                        significantly in this case.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                How are temperature and activation energy related to each other?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The higher the temperature, the more molecules with a higher kinetic energy that meet or exceed \
                    the amount of energy that's required for the reaction to take place
                    """,
                    explanation: """
                    A high temperature will result in molecules with higher kinetic energy that \
                    will result in more successful collisions.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The higher the temperature, the higher the number of collisions is, which leads to a lower \
                        amount of energy that's required for the reaction to take place
                        """,
                        explanation: """
                        Increasing the temperature will not lower the energy required for the \
                        reaction to take place.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The higher the temperature, the lower is the overall amount of energy required for the \
                        reaction to take place, allowing more reactants to turn into products
                        """,
                        explanation: """
                        Lowering the energy required would actually help more reactants to turn \
                        into products, but this would not be accomplished by increasing the \
                        temperature.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        A high temperature results in the creation of a new pathway that has lower \
                        energy requirements
                        """,
                        explanation: """
                        High temperatures don't create new pathways.
                        """
                    ),
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                Which one of these elementary reactions is probably the rate-determining one in the mechanism \
                for the overall reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "J + K + L ➝ M",
                    explanation: """
                    The rate-determining step would probably be $J + K + L ➝ M$. Of all the elementary reactions, \
                    this one is termolecular and has three reactants, which implies that a successful collision of 3 \
                    molecules has to take place for the reaction to occur.

                    Since the probabilities of this happening are lower, the chances of this reaction to be slower \
                    than the other ones is greater. Being the slowest of all the steps, this would be the \
                    rate-determining step.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A + B ➝ C + D",
                        explanation: """
                        A + B, two reactants colliding successfully is more likely to happen than \
                        some of these other scenarios.
                        """
                    ),
                    QuizAnswerData(
                        answer: "D ➝ E + F",
                        explanation: """
                        D, being only one reactant, should most likely be the fastest of the steps.
                        """
                    ),
                    QuizAnswerData(
                        answer: "G + H ➝ I",
                        explanation: """
                        G + H, two reactants colliding successfully is more likely to happen than \
                        some of these other scenarios.
                        """
                    )
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                Consider a reaction represented by the energy diagram below. What is a true statement about this \
                reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    It has a two-step mechanism that involves the formation of an intermediate and it's an \
                    endothermic reaction
                    """,
                    explanation: """
                    At a first glance it's noticeable that the reaction starts with the reactants \
                    being at a lower energy point than the products, meaning that the reaction is \
                    endothermic since it's going to absorb energy. For each step an activated \
                    complex is formed, but between both steps an intermediate is produced.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        It has a two-step mechanism that involves the formation of an intermediate \
                        and it's an exothermic reaction
                        """,
                        explanation: """
                        The reactants start at a lower point of energy than the products, so \
                        energy is being absorbed when the reaction takes place.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        It has a two-step mechanism that involves the formation of an activated complex and it's an \
                        endothermic reaction
                        """,
                        explanation: """
                        Not one, but two activated complex are formed in this mechanism \
                        (represented by the peaks).
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        It has a two-step mechanism that involves the formation of an activated complex and it's an \
                        exothermic reaction
                        """,
                        explanation: """
                        Not only two activated complex are formed but the reaction absorbs energy \
                        instead of releasing it.
                        """
                    )
                ],
                difficulty: .medium,
                image: "energy-profile-energy-diagram"
            ),
            QuizQuestionData(
                question: """
                The rate law equation can help determine the number of collisions and the success rate of the \
                collisions. What parts of the equation are related to these factors?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The number of collisions is related to the order of the reaction, while the \
                    success relates to the rate constant
                    """,
                    explanation: """
                    For elementary reactions the number of collisions is being represented in the \
                    rate law equation by the overall order of the reaction. The orders are related \
                    to the collisions, while the success rate of them is related to the rate \
                    constant k. The higher the success rate is, then the higher is the rate constant.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The number of collisions is related to the rate constant, while the success depends on the \
                        concentration of the reactants only
                        """,
                        explanation: """
                        The success is actually related to the rate constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The number of collisions depends on the concentration of the most active \
                        reactant only, while the success relates to the rate constant
                        """,
                        explanation: """
                        The number of collisions is actually related to the order of the reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The number of collisions is related and the success of the reaction can \
                        only be determined using a catalyst at high temperature
                        """,
                        explanation: """
                        Using a catalyst might affect the number and success of collision, but it \
                        is not required to for a rate law.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                question: """
                The position of a reaction is right now being represented by the point in the \
                energy diagram below. At that point, what could be happening?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Molecules of reactants colliding unsuccessfully because of their lack of kinetic energy, \
                    making them unable to form any complex
                    """,
                    explanation: """
                    This is the right answer, because at this point molecules colliding are lacking the energy \
                    to meet the energy  requirements
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Molecules of reactants barely colliding successfully, just starting to form an activated \
                        complex
                        """,
                        explanation:
                            "Molecules won't collide successfully at this point because of the lack of energy"
                    ),
                    QuizAnswerData(
                        answer: "An intermediate in stable conditions",
                        explanation: """
                        An intermediate is only stable within a reaction, and in an energy \
                        diagram, this ones is represented by a valley between two steps and \
                        activated complex, and this is a single step reaction with no intermediates.
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
                image: "energy-profile-reaction-progress"
            ),
        ]
    )
}
