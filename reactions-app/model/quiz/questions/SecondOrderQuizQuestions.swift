//
// Reactions App
//


import Foundation

extension QuizQuestionsList {

    static let secondOrderQuestions = QuizQuestionsList(
        questionSet: .secondOrder,
        [
            QuizQuestionData(
                question: """
                The rate constant for a second order reaction $(A ➝ B)$ is 0.178 M^-1^s^-1^. How \
                much time will it take for the concentration of A to drop to 0.21 M considering \
                that the reaction started with 0.84 M?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "20 s",
                    explanation: """
                    The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing \
                    k, [A_0_] and the [A] at which it's going to drop, we just solve for time $(t):

                    t = (1/[A] - 1/[A_0_])/k$ ➝
                    $t = (1/0.21 - 1/0.84)/0.178 = 20 seconds$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "15 s",
                        explanation: "After 15 seconds, the reactant A would drop to 0.26 M."
                    ),
                    QuizAnswerData(
                        answer: "10 s",
                        explanation: "After 10 seconds, the reactant A would drop to 0.34 M."
                    ),
                    QuizAnswerData(
                        answer: "5 s",
                        explanation: """
                        The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. After \
                        5 seconds, the reactant A would drop to 0.48 M.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                The rate constant for a second order reaction $(A ➝ B)$ is 0.44 M^-1^s^-1^. How \
                much time will it take for the concentration of A to drop to $0.05 M$ considering \
                that the reaction started with $0.54 M$?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "41 s",
                    explanation: """
                    The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing \
                    k, [A_0_] and the [A] at which it's going to drop, we just solve for time (t):

                    $t = (1/[A] - 1/[A_0_])/k$ ➝
                    $t = (1/0.05 - 1/0.54)/0.44 = 41 seconds$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "37 s",
                        explanation: "After 37 seconds, the reactant A would drop to 0.055 M."
                    ),
                    QuizAnswerData(
                        answer: "31 s",
                        explanation: "After 31 seconds, the reactant A would drop to 0.064 M."
                    ),
                    QuizAnswerData(
                        answer: "27 s",
                        explanation: """
                        The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. After \
                        27 seconds, the reactant A would drop to 0.073 M.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                The rate constant for a second order reaction $(A ➝ B)$ is 0.09 M^-1^s^-1^. How \
                much of A would be remaining after 25 seconds has passed? Considering the initial \
                concentration of A is 0.44 M
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.22 M",
                    explanation: """
                    The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing \
                    k, [A_0_] and the time, we just solve for [A]:

                    $[A] = [A_0_]/([A_0_]kt + 1)$ ➝
                    $[A] = 0.44/(0.44 \\* 0.09 \\* 25 + 1) = 0.22 M$
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.44 M",
                        explanation: """
                        The initial concentration of A is already 0.44 M so after 25 seconds, \
                        there must be less than that remaining.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.18 M",
                        explanation: """
                        The reactant would drop to 0.18 M of concentration only after around 36 \
                        seconds.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.28 M",
                        explanation: """
                        The reactant would drop to 0.28 M of concentration after around 14 seconds.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                What is the half-life for a first order reaction whose rate constant is 0.02875 h^-1^?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "1 day",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    If k is 0.02875 h^-1^, we only need to replace it: \
                    $t_1/2_ = ln(2)/0.02875 h^-1^ = 24 hours$, which is the same as 1 day.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "12 hours",
                        explanation: """
                        12 hours is not enough time for the reactant to drop to half of its \
                        initial concentration.
                        """
                    ),
                    QuizAnswerData(
                        answer: "36 hours",
                        explanation: """
                        After 36 hours there would be less than half of the reactant left.
                        """
                    ),
                    QuizAnswerData(
                        answer: "2 days",
                        explanation: """
                         2 days is too much time. The equation for half-life for a first order \
                        reaction is $t_1/2_ = ln(2)/k$. Try replacing the known values to \
                        calculate the half life.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider a reaction (A ➝ B) that has this rate law: $rate = k[A][B]^2^$. Which of \
                the following concentration ratios would lead to a higher rate of reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "[A] = 0.2 M, [B] = 0.8 M",
                    explanation: """
                    Since the reaction is 2nd order with respect to B (making it the highest order \
                    within the reaction), the change of the concentration of this species will \
                    affect the rate more than the other species. When [B] is really low, rate will \
                    be also, and on the contrary, if [B] is really high, rate will also be. This \
                    is just a way to infer the answer, but to confirm if this is the case with \
                    this reaction, we have the numeric values to replace in the rate law equation: \
                    $rate = (0.2)(0.8)^2^ = 0.128 M/s$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "[A] = 0.8 M, [B] = 0.2 M",
                        explanation: """
                        Those reactant concentrations would result in a reaction rate of \
                        0.032 $M/s$ which is too low compared to the rest. \
                        $Rate = (0.8)(0.2)^2^ = 0.032 M/s$
                        """
                    ),
                    QuizAnswerData(
                        answer: "[A] = 0.4 M, [B] = 0.4 M",
                        explanation: """
                        Those reactant concentrations would result in a reaction rate of 0.064 \
                        $M/s$ which is too low compared to the rest. \
                        $Rate = (0.4)(0.4)^2^ = 0.064 M/s$
                        """
                    ),
                    QuizAnswerData(
                        answer: "[A] = 0.5 M, [B] = 0.5 M",
                        explanation: """
                        Those reactant concentrations would result in a reaction rate of 0.0125 \
                        $M/s$ which is not the highest compared to the rest. \
                        $Rate = (0.5)(0.5)^2^ = 0.125 M/s$
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                Rate for radioactive decay remains unchanged regardless of environmental factors. \
                The nuclear waste from large nuclear plants lead to problems worldwide because of \
                this characteristic. What would be an accurate statement regarding radioactive \
                rate laws?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    Radioactive rate laws are first order reactions because the rate depends only \
                    on the material
                    """,
                    explanation: """
                    Radioactive decay is always a first order process. This is why the half-life \
                    of it is only dependent on the nature of the substance, creating a problem in \
                    which the rate of its decay cannot be sped up.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        Radioactive rate laws are zero order reactions because the rate doesn't \
                        depend on the material
                        """,
                        explanation: """
                        Radioactive rate laws are not of zero order reactions.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        Radioactive rate laws are second order reactions because the half-life of \
                        the substance depends on the interactions of it with other components
                        """,
                        explanation: """
                        Radioactive rate laws are not of second order reactions.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        For radioactive material, the overall rate order cannot be determined for \
                        decaying material because it changes when this is bonded to other compounds
                        """,
                        explanation: """
                        Radioactive decay is always of a predetermined order.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                According to the steady state approximation, what has to be true to determine the \
                rate law for the reaction that has the following reaction mechanism:

                $(Step 1) 2NO_(g)_ ⇌ N_2_O_2__(g)_$
                $(Step 2) N_2_O_2_ + O_2__(g)_ ➝ 2NO_2__(g)_$
                $Overall 2NO_(g)_ + O_2__(g)_ ➝ 2NO_2__(g)_$

                Take into account that it is not evident that the first elementary step is the \
                rate determining step.
                """,
                correctAnswer:
                    QuizAnswerData(
                        answer: """
                        The rate of formation of N_2_O_2_ is equal to the rate of disappearance of \
                        N_2_O_2_.
                        """,
                        explanation: """
                        By the steady state approximation, it is assumed that the concentration of \
                        the reaction intermediate stays constant. A reaction intermediate is a \
                        species that is formed from the reactants (or preceding intermediates) and \
                        reacts further to give the directly observed products of a chemical \
                        reaction.

                        This intermediate is immediately consumed after its production, which is \
                        why it doesn't appear in the overall chemical equation. The reaction \
                        intermediate for this reaction is N_2_O_2_, and if its concentration \
                        remains constant, that means that the rate of formation of N_2_O_2_ is the \
                        same as the rate of disappearance of N_2_O_2_.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The rate of formation of N_2_O_2_ is equal to the rate of disappearance \
                        of NO
                        """,
                        explanation: """
                        If the rate of formation of N_2_O_2_ was equal to the rate of \
                        disappearance of NO, that would not assure that concentration of the \
                        intermediate N_2_O_2_ to stay constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate of formation of N_2_O_2_ is equal to the rate of formation of NO_2_
                        """,
                        explanation: """
                        If the rate of formation of N_2_O_2_ was equal to the rate of formation of \
                        NO_2_, that would not assure that concentration of the intermediate \
                        N_2_O_2_ to stay constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate of formation of N_2_O_2_ is equal to the rate of disappearance of \
                        O_2_
                        """,
                        explanation: """
                        If the rate of formation of N_2_O_2_ was equal to the rate of \
                        disappearance of O_2_, that would not assure that concentration of the \
                        intermediate N_2_O_2_ to stay constant.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                A patient receives medications to treat his allergies. He takes 25 mg of this drug \
                twice a day, with a span of 12 hours in between in order for the drug to be \
                effective. This particular drug is metabolized as a first order process, whose \
                half-life is 8 hours. What would be the rate constant k for the process of \
                metabolization of this drug?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.058 h^-1^",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    If $t_1/2_$ is 12 hours, we only need to replace it:

                    $k = ln(2)/t_1/2_$ ➝ $k = ln(2)/12 = 0.039 h^-1^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.039 h^-1^",
                        explanation: """
                        A rate constant value of 0.039 h^-1^ would imply a half life of around \
                        18 hours.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1.0 mg/h",
                        explanation: """
                        1.0 mg/h is not even the units expected for a rate constant of a first \
                        order reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "10 mg \\* h",
                        explanation: """
                        10 mg\\*h are not even the units expected for a rate constant of a first \
                        order reaction.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider a reaction: $B + 2C + D ➝ E + F$. Based on the table below, what would be the \
                rate law of this reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[B]^2^[C][D]^3^",
                    explanation: """
                    When [B] goes from 0.002 to 0.004 (it's doubled, goes up by a factor of 2) \
                    while C and D remain constant, the rate goes from 0.5X to 2X (it goes up by a \
                    factor of 4). $2^x^ = 4$ where $x = 2$; the reaction is second order for [B].

                    When [C] goes from 0.008 to 0.002 (it goes down by a factor of 4) while B and \
                    D remain constant, the rate goes from 8X to 2X (it goes down by a factor of \
                    4). $4^x^ = 4$ where x = 1; the reaction is first order for [C].

                    When [D] goes from 0.002 to 0.004 (it's doubled, goes up by a factor of 2) \
                    while B and C remain constant, the rate goes from 2X to 16X (it goes up by a \
                    factor of 8). $2^x^ = 8$ where $x = 3$; the reaction is third order for [D].
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[B][C][D]",
                        explanation: """
                        When [B] goes from 0.002 to 0.004 (it's doubled, goes up by a factor of 2) \
                        while C and D remain constant, the rate goes from 0.5X to 2X (it goes up \
                        by a factor of 4). $2^x^ = 4$ where $x = 2$; the reaction is second order \
                        for [B].
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[B][C]^2^[D]^3^",
                        explanation: """
                        When [C] goes from 0.008 to 0.002 (it goes down by a factor of 4) while B \
                        and D remain constant, the rate goes from 8X to 2X (it goes down by a \
                        factor of 4). $4^x^ = 4$ where $x = 1$; the reaction is first order for [C].
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[B]2[C]2[D]",
                        explanation: """
                        When [D] goes from 0.002 to 0.004 (it's doubled, goes up by a factor of 2) \
                        while B and C remain constant, the rate goes from 2X to 16X (it goes up by \
                        a factor of 8). $2^x^ = 8$ where $x = 3$; the reaction is third order for \
                        [D].
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                table: QuizTable(
                    rows: [
                        ["[B] (M)", "[C] (M)", "[D] (M)", "Rate M/s"],
                        ["0.001", "0.002", "0.002", "0.5X"],
                        ["0.004", "0.008", "0.002", "8X"],
                        ["0.004", "0.002", "0.002", "2X"],
                        ["0.004", "0.002", "0.004", "16X"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
                What would be the rate law equation for a reaction that follows this reaction \
                mechanism?

                $Step 1 (fast) 2NO_(g)_ ⇌ N_2_O_2__(g)_$
                $Step 2 (slow) N_2_O_2__(g)_ + O_2_ ➝ 2NO_2__(g)_$
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[NO]^2^[O_2_]",
                    explanation: """
                    Many reactions proceed from reactants to products through a sequence of \
                    reactions (elementary reactions, or steps). This sequence of reactions is \
                    called the reaction mechanism. The reaction mechanism for elementary steps or \
                    reactions is very simple to write since it's determined by the stoichiometry.

                    For example, if we were going to write Step 1's rate law, it would be: \
                    $rate = k[NO]^2^$. Furthermore, the slowest step, in this case Step 2, is also \
                    called the rate-determining step, because the overall reaction cannot go \
                    faster than the slowest of the steps.

                    In other words, the rate for this reaction would be \
                    $rate = k[N_2_O_2_][O_2_]$ but since N_2_O_2_ is only the intermediate, then \
                    the actual rate law is: $rate = k[NO]^2^[O^2^]$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[NO]^2^/[O_2_]",
                        explanation: """
                        Rate laws only have reactants in the form of $rate = k[A][B][C]...$ \
                        without denominator.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[NO_2_]",
                        explanation: """
                        $Rate = k[NO]^2^$ would be the rate law for the step 1 reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[N_2_O_2_]",
                        explanation: """
                        N_2_O_2_ is not a reactant but a product of the overall reaction.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                Which type of elementary reaction steps would have a higher rate of reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "A reaction with only one reactant",
                    explanation: """
                    For elementary reactions, the rate is deeply related to the probability of \
                    collision of the molecules involved. The more molecules are needed to collide \
                    to form products, then the lower would be the probability for a successful \
                    collision to take place.

                    That's why the reaction with the highest rate would be the one with only one \
                    reactant, since it doesn't even need a collision to happen, making it much \
                    more probable to occur.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A reaction that occurs with three reactants",
                        explanation: """
                        Three reactants for an elementary reaction would imply that a successful \
                        collision of those would have to take place, and given the very low \
                        chances for it to happen, this results in a slow rate of reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A reaction where two reactants combine",
                        explanation: """
                        Two reactants for an elementary reaction would imply that a successful \
                        collision of those would have to take place, and given the low chances for \
                        it to happen, this results in a slow rate of reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A reaction where two reactants undergo double displacement",
                        explanation: """
                        For elementary reactions, the rate is deeply related to the probability of \
                        collision of the molecules involved. The more molecules are needed to \
                        collide to form products, then the lower would be the probability for a \
                        successful collision to take place.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                The rate of disappearance of bromine is -0.021 $M/s$ in this reaction: \
                $H_2(g)_ + Br_2(g)_ ➝ 2HBr_(aq)_$. What would be rate of formation for HBr?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.042 M/s",
                    explanation: """
                    The rates of disappearance of reactants and appearance of products can be \
                    related to each other based on the stoichiometry of the reaction.

                    $Rate = -[ΔH_2_]/Δt = -[ΔBr_2_]/Δt = [ΔHbr]/2Δt$.

                    If $[ΔBr_2_]/Δt = -0.021 M/s$, we only have to replace:

                    -[ΔBr_2_]/Δt = [ΔHbr]/2Δt ➝
                    -2(-0.021) = [ΔHbr]/Δt ➝
                    0.042 M/s = [ΔHbr]/Δt.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "-0.021 M/s",
                        explanation: """
                        The rate of appearance is given in positive values. Besides that, \
                        0.021 M/s would imply that the stoichiometry of the reaction is one to \
                        one, which is not the case since for each mole of Br2 that's consumed, \
                        there are 2 moles of HBr that are produced, so its formation should be \
                        going at a higher rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.021 M/s",
                        explanation: """
                        0.021 M/s would imply that the stoichiometry of the reaction is one to \
                        one, which is not the case since for each mole of Br2 that's consumed, \
                        there are 2 moles of HBr that are produced, so its formation should be \
                        going at a twice the rate
                        """
                    ),
                    QuizAnswerData(
                        answer: "-0.042 M/s",
                        explanation: "The rate of appearance is given in positive values."
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider the following zero order reaction: $AB + 2C ➝ AC + BC$. What is the rate \
                law for it?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k",
                    explanation: """
                    For zero order reactions, the rate is independent of the concentration of the \
                    reactants, so the rate law for all zero order reactions is $rate = k$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[AB]m",
                        explanation: """
                        $Rate = k[AB]m$ means that the reactant A affects the rate, and for zero \
                        order reactions the rate is independent of the concentration of any \
                        reactant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[AB][C]",
                        explanation: """
                        $Rate = k[AB][C]$ would mean that the reaction is of second order.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[AB]m[C]n",
                        explanation: """
                        $Rate = k[AB]m[C]n$ means that the reactants A and B affect the rate, and \
                        for zero order reactions the rate is independent of the concentration of \
                        any reactant.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                S2O8-2(aq) + 3I-(aq) to 2SO4(aq) + I3-(aq)

                Given the data collected experimentally in this table about the reaction above, \
                what is the rate law for the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[S2O8-2][3I-]2",
                    explanation: """
                    When [S2O8-2] goes from 0.15 to 0.30 (it's doubled, goes up by a factor of 2) \
                    while 3I- remains constant, the rate goes from $8.44x10^-4^$ to $1.69x10^-3^$ \
                    (it goes up by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first \
                    order for [S2O8-2]. When [3I-] goes from 0.15 to 0.60 (it goes up by a factor \
                    of 4) while S2O8-2 remains constant, the rate goes from  to $1.69x10^-3^$ to \
                    $2.7x10^-2^$ (it goes up by a factor of 16). $4^x^ = 16$ where $x = 2$; the \
                    reaction is second order for [3I-].
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[S2O8-2][3I-]",
                        explanation: """
                        When [3I-] goes from 0.15 to 0.60 (it goes up by a factor of 4) while \
                        S2O8-2 remains constant, the rate goes from to $1.69x10^-3^$ to \
                        $2.7x10^-2^$ (it goes up by a factor of 16). $4^x^ = 16$ where x = 2; \
                        the reaction is second order for [3I-].
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[S2O8-2]2[3I-]1",
                        explanation: """
                        When [S2O8-2] goes from 0.15 to 0.30 (it's doubled, goes up by a factor of \
                        2) while 3I- remains constant, the rate goes from $8.44x10^-4^$ to \
                        $1.69x10^-3^$ (it goes up by a factor of 2). $2^x^ = 2$ where x = 1; the \
                        reaction is first order for [S2O8-2].
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[S2O8-2]2[3I-]2",
                        explanation: """
                        Try comparing how much the change of concentration of both reactants \
                        affect the rate of the reaction.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium,
                table: QuizTable(
                    rows: [
                        ["E", "[S2O8-2](M)", "[3I-](M)", "Rate M/s"],
                        ["1", "0.15", "0.15", "8.44x10^-4^"],
                        ["2", "0.30", "0.15", "1.69x10^-3^"],
                        ["3", "0.30", "0.60", "2.7x10^-2^"],
                        ["4", "0.002", "0.004", "32X"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
                Consider the reaction below:

                $F_2__(g)_ + 2ClO_2__(g)_ ➝ 2FClO_2__(g)_$

                Experiments were performed to determine that its rate law is: \
                $rate = k[F_2_][ClO_2_]$. Which of the following would be expected?
                """,
                correctAnswer:
                    QuizAnswerData(
                        answer: """
                        As the concentration of fluorine gas is doubled, the rate of the reaction \
                        would be doubled
                        """,
                        explanation: """
                        According to the rate law equation, the reaction is first order with \
                        respect to F_2_, which means that the rate is directly proportional to it. \
                        If the concentration of F_2_ is doubled, the rate of the reaction would be \
                        doubled too.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        As the concentration of fluorine gas is doubled, the rate of the reaction \
                        would be quadrupled
                        """,
                        explanation: """
                        If this was the case, the reaction would be second order with respect to \
                        F_2_.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        As the concentration of fluorine gas is doubled, the rate of the reaction \
                        would be halved
                        """,
                        explanation: """
                        Given the nature of the rate law equation $rate = k[A][B][C]...$ notice \
                        that if any concentration increases, the rate would increase also and in \
                        no case it would decrease.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        As the concentration of fluorine gas is doubled, the rate of the reaction \
                        would not change
                        """,
                        explanation: """
                        If this was the case, the reaction would be zero order with respect to F_2_.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider the following graph, what would be the order for that reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Second order",
                    explanation: """
                    For this second order reaction, the resultant integrated rate law is \
                    $k = (1/[A] – 1/[A_0_])/t$, that’s why a graph plotting $(1/[A] vs t)$ is a \
                    straight line $(1/[A](y) = kt(mx) + 1/[A_0_](b))$ with a slope of k.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order",
                        explanation: """
                        For zero order reactions, plotting [A] vs t would result in a straight line.
                        """
                    ),
                    QuizAnswerData(
                        answer: "First order",
                        explanation: """
                        For first order reactions, plotting ln[A] vs t would result in a straight \
                        line
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third order",
                        explanation: """
                        Try considering the rate law equations of the different orders.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                image: "second-order-inverse-a"
            ),
            QuizQuestionData(
                question: """
                Consider a reaction that's $(A ➝ B)$ when [A] and [B] are doubled, the rate goes \
                up by a factor of eight. The rate law is $rate = k[A]x[B]^2^$. What's the rate \
                order with respect to [A]?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "First order",
                    explanation: """
                    Knowing that the reaction is second order with respect to [B], we know that if \
                    it was doubled while [A] remained constant, the rate would have to go up by a \
                    factor of 4. When [A] was doubled at the same time, the rate went up by a \
                    factor of 8. $X \\* 4 = 8$, where $X = 2$. In other words, doubling [A] made \
                    the rate go up by a factor of 2. $2^x^ = 2$ where $x = 1$; the reaction is \
                    first order for [A].
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        If this was the case, the rate would have gone up by a factor of 16.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third order",
                        explanation: """
                        If this was the case, the rate would have gone up by a factor of 32.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Cannot be determined with the given information",
                        explanation: """
                        It can be determined. Consider that according to the equation, the \
                        reaction is second order with respect to [B].
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Kinetic data was collected experimentally of the decomposition of A. The \
                concentration of A was measured through time while the reaction was taking place. \
                Based on the data in the table, what would be the order of the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "The decomposition of A is a first-order reaction",
                    explanation: """
                    We can give these tables the same treatment as we give to the graphs. Making 3 \
                    graphs with the provided data might be a way to find the answer, but to \
                    quickly determine the order of the reaction, we can look at the increment in \
                    each experiment.

                    From 0 to 30 seconds, [A] goes from 10.0 to 7.05 (difference of 2.95), ln[A] \
                    goes from 2.30 to 1.95 (difference of 0.35) and $1/[A]$ goes from 0.10 to \
                    0.14 (difference of 0.04).

                    From 30 to 60 seconds, [A] goes from 7.05 to 4.97 (difference of 2.38), ln[A] \
                    goes from 1.95 to 1.60 (difference of 0.35) and 1/[A] goes from 0.14 to 0.20 \
                    (difference of 0.06).

                    The only increment that remained the same in these last 30 seconds as in the \
                    first 30 seconds of the reaction is the value for $ln[A]$, which means that \
                    the increment is linear, so it's a first order reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The decomposition of A is a zero-order reaction",
                        explanation: """
                        If the decomposition of A was a zero order reaction, the increase of A \
                        would be linear, for example: For 0 seconds, 10 M. For 30 seconds, 7.05 M. \
                        For 60 seconds, 4.1 M (instead of 4.97).
                        """
                    ),
                    QuizAnswerData(
                        answer: "The decomposition of A is a second-order reaction",
                        explanation: """
                        If the decomposition of A was a second order reaction, the increase of \
                        $1/[A]$ would be linear, for example: For 0 seconds, 0.10. For 30 seconds, \
                        0.14. For 60 seconds, 0.18 (instead of 0.20).
                        """
                    ),
                    QuizAnswerData(
                        answer: "The decomposition of A is a third-order reaction",
                        explanation: """
                        Try finding which expression between [A], $ln[A]$ and $1/[A]$ changes \
                        linearly with time to determine the order.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                table: QuizTable(
                    rows: [
                        ["Time (s)", "[A]", "ln[A]", "1/[A]"],
                        ["0", "10.0", "2.30", "0.10"],
                        ["30", "7.05", "1.95", "0.14"],
                        ["60", "4.97", "1.60", "0.20"],
                        ["90", "3.50", "1.25", "0.29"],
                        ["120", "2.47", "0.90",  "0.40"]
                    ]
                )
            ),
            QuizQuestionData(
                question:
                    "Consider the following graph, what would be the order for that reaction?",
                correctAnswer: QuizAnswerData(
                    answer: "First order",
                    explanation: """
                    For this first order reaction, the resultant integrated rate law is \
                    $k = (ln[A_0_] – ln[A])/t$, that’s why a graph plotting $(ln[A] vs t)$ is a \
                    straight line $(ln[A](y) = -kt(mx) + ln[A_0_](b)))$ with a slope of -k.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order",
                        explanation: """
                        For zero order reactions, plotting [A] vs t would result in a straight line.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        For second order reactions, plotting $1/[A]$ vs t would result in a \
                        straight line.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third order",
                        explanation: """
                        Try considering the rate law equations of the different orders.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                image: "second-order-ln-a"
            ),
            QuizQuestionData(
                question: """
                A first-order reaction $(A to B)$ has a rate constant of 0.6 min^-1^. What \
                fraction of the reactant A would be left after 5 minutes?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "1/20",
                    explanation: """
                    The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After 5 \
                    minutes have passed, there's a fraction of A remaining, or: $[A] = X[A_0_]$. \
                    Replacing we get: $ln(X[A_0_]) = ln[A_0_] - (0.6)(5)$.

                    Moving all logarithmic expressions to one side: \
                    $(0.6)(5) = ln([A_0_]) - lnX[A_0_]$.

                    Using logarithmic properties: $(0.6)(5) = ln([A_0_]/X[A_0_])$. Canceling \
                    [A_0_] from the expression and solving numerically: $(3) = ln(1/X)$.

                    Applying exponential to both sides: $e^3^ = 1/X$. Finally solving for X: \
                    $X = 1/e^3^ = 0.05$, which is the same as 1/20.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "1/2",
                        explanation: """
                        After 5 minutes of the reaction, given that rate constant, there would be \
                        much less than 1/2 of A remaining.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1/4",
                        explanation: """
                        After 5 minutes of the reaction, given that rate constant, there would be \
                        less than 1/4 of A remaining.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1/12",
                        explanation: """
                        After 5 minutes of the reaction, given that rate constant, there would be \
                        less than 1/12 of A remaining. The equation for a first order reaction is \
                        $ln[A] = ln[A_0_] - kt$.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            )
        ]
    )
}
