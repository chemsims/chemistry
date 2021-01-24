//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let reactionComparisonQuizQuestions = QuizQuestionsList(
        questionSet: .reactionComparison,
        [
            QuizQuestionData(
                question: """
                The rate at which the reactants disappear is equal to the rate of formation of the \
                products within a chemical system. What ways are there to determine the rate law \
                for a reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "The rate law must be determined experimentally for each reaction",
                    explanation:
                        " It has to be experimentally determined for each reaction."
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The rate law for most common reactions can be found in a reference table",
                        explanation: "The rate law cannot be found in a reference table"
                    ),
                    QuizAnswerData(
                        answer: "The rate law is always determined by the coefficients of the balanced equation",
                        explanation: """
                    The rate law is only determined by the coefficients of the balanced equation in the case \
                    of elementary single step reactions
                    """
                    ),
                    QuizAnswerData(
                        answer: "The rate law is based on the use of a catalyst",
                        explanation: "The rate law cannot be solely determined by the use of a catalyst"
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            A student conducts an experiment that consists on making 10 mL of a 0.20 M violet solution react \
            with 10 mL of a 0.20 M base solution. After this, the student takes a sample of the resulting \
            solution and places it in a UV-Vis spectrophotometer, records the absorbance and plots some \
            graphs. What is the order of the reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "First order",
                    explanation: """
                    For this first order reaction, the resultant integrated rate law is \
                    $k = (ln[A_0_] – ln[A])/t$, that’s why a graph plotting $(ln[A] vs t)$ is a \
                    straight line: $(ln[A](y) = -kt(mx) + ln[A_0_](b)))$ with a slope of -k.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order",
                        explanation: """
                        The graph plotting [A] vs t results in a curved line. If it was a zero \
                        order reaction, it would be a straight line.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        The graph plotting $1/[A]$ vs t results in a curved line. If it was a zero \
                        order reaction, it would be a straight line.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Insufficient data",
                        explanation: """
                        There is enough data to determine the order of the reaction.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                image: "reaction-comparison"
            ),
            QuizQuestionData(
                question: """
            Units for the rate constant vary with the order and the rate law of the equation. For this rate \
            law $rate = k[A]^3^[B]$ what would be the units for k, the rate constant?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "s^-1^M^-3^",
                    explanation: """
                    For the rate law equation: $rate = k[A]^3^[B]$, knowing that concentrations \
                    are in units of M, and rate in $M/s$, you can solve for k:

                    $M/s = k(M)^3^(M)$ ➝
                    $M/s = kM^4^$ ➝
                    $k = M/(M^4^)(s)$ ➝
                    $k = 1/(M^3^)(s)$

                    which is the same as s^-1^M^-3^.

                    A short way to know the units for the rate constant is by using M^(1-n)^/s \
                    where n is the overall order of the equation. When $n = 4$, \
                    $M^(1-4)^/s = s^-1^M^-3^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "s^-1^M^-1^",
                        explanation: """
                        Given that rate law equation, the reaction is of fourth order overall. If \
                        the units of the rate constant were s-1M-1, that would imply a second \
                        order reaction instead.
                        """
                    ),
                    QuizAnswerData(
                        answer: "s^-1^M^-2^",
                        explanation: """
                        Given that rate law equation, the reaction is of fourth order overall. If \
                        the units of the rate constant were $s^-1^M^-2^$, that would imply a third \
                        order reaction instead.
                        """
                    ),
                    QuizAnswerData(
                        answer: "s^-1^",
                        explanation: """
                        Given that rate law equation, the reaction is of fourth order overall. If \
                        the units of the rate constant were $s^-1^$, that would imply a first \
                        order reaction instead.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider a reaction: $3A + 5B ➝ 4C + D$. Based on the table below, what would be \
                the rate law of this reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[A]^2^",
                    explanation: """
                    When [A] goes from 0.230 to 0.460 (it's doubled, goes up by a factor of 2) \
                    while B remains constant, the rate goes from 0.0042 to 0.0168 (it goes up by a \
                    factor of 4). $2^x^ = 4$ where $x = 2$; the reaction is second order for [A].

                    When [B] goes from 0.230 to 0.460 (it goes up by a factor of 2) while A \
                    remains constant, the rate remains constant. If the rate doesn't vary with the \
                    concentration of B, it means the reaction is zero order for [B]. Writing the \
                    complete rate law equation: $rate = k[A]^2^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[A][B]",
                        explanation: """
                        When [A] goes from 0.230 to 0.460 (it's doubled, goes up by a factor of 2) \
                        while B remains constant, the rate goes from 0.0042 to 0.0168 (it goes up \
                        by a factor of 4). $2^x^ = 4$ where $x = 2$; the reaction is second order \
                        for [A].
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[A][B]^2^",
                        explanation: """
                        When [B] goes from 0.230 to 0.460 (it goes up by a factor of 2) while A \
                        remains constant, the rate remains constant. If the rate doesn't vary with \
                        the concentration of B, it means the reaction is zero order for [B]. \
                        Writing the complete rate law equation: $rate = k[A]^2^$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[B]^2^",
                        explanation: """
                        When the concentration of B changes, the rate doesn't vary, so [B] is not \
                        affecting the rate.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                table: QuizTable(
                    rows: [
                        ["[A] (M)", "[B] (M)", "Rate M/s"],
                        ["0.230", "0.230", "0.0042"],
                        ["0.460", "0.230", "0.0168"],
                        ["0.230", "0.460", "0.0042"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
            Consider a multi-step reaction. The rate laws for the elementary reactions that are part of the \
            proposed mechanism are given. Which one would probably be the rate-determining step of the \
            overall reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[E][F]^2^",
                    explanation: """
                    The rate-determining step would probably be $rate = k[E][F]^2^$. Of all the \
                    rate laws, this one is of the highest order (third overall) and implies that a \
                    successful collision of 3 molecules has to take place for the reaction to \
                    occur. Since the probabilities of this happening are lower, the chances of \
                    this reaction to be slower than the other ones is greater. Being the slowest \
                    of all the steps, this would be the rate-determining step.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[C]",
                        explanation: """
                        A rate law equation as $rate = k[C]$ for an elementary step suggests that \
                        there's no need for a collision to happen for the reaction to take place. \
                        Compared to the rest, this would most likely be the fastest reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[A][B]",
                        explanation: """
                        A rate law equation as $rate = k[A][B]$ for an elementary step suggests \
                        that a successful collision between A and B has to take place. Compared to \
                        the rest, this would not be the slowest reaction or step.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[D]^2^",
                        explanation: """
                        A rate law equation as $rate = k[D]^2^$ for an elementary step suggests \
                        that a successful collision between two molecules of D has to take place. \
                        Compared to the rest, this would not be the slowest reaction or step.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.11 M^-1^s^-1^. How much time will \
            it take for the concentration of A to drop to 0.43 M considering that the reaction started \
            with 0.50 M?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "3 s",
                    explanation: """
                    The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing \
                    k, [A_0_] and the [A] at which it's going to drop, we just solve for time (t):

                    $t = (1/[A] - 1/[A_0_])/k$ ➝
                    $t = (1/0.43 - 1/0.50)/0.11 = 2.95 seconds$, or roughly 3 seconds.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "4 s",
                        explanation: """
                        After 4 seconds the concentration of A would have already dropped to 0.41 M.
                        """
                    ),
                    QuizAnswerData(
                        answer: "5 s",
                        explanation: """
                        After 5 seconds the concentration of A would have already dropped to 0.39 M.
                        """
                    ),
                    QuizAnswerData(
                        answer: "6 s",
                        explanation: """
                        After 6 seconds the concentration of A would have already dropped to 0.38 M.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.11 M^-1^s^-1^. How much of A would \
            be remaining after 12 seconds has passed? Considering the initial concentration of A is 0.94 M?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "0.42 M",
                    explanation: """
                    The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing \
                    k, [A_0_] and the time, we just solve for [A]:

                    $[A] = [A_0_]/([A_0_]kt + 1)$ ➝
                    $[A] = 0.94/(0.94 \\* 0.11 \\* 12 + 1) = 0.42 M$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.38 M",
                        explanation: """
                        For the concentration of A to drop to 0.38 M, around 14 seconds should pass.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.36 M",
                        explanation: """
                        For the concentration of A to drop to 0.36 M, around 16 seconds should pass.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.32 M",
                        explanation: """
                        For the concentration of A to drop to 0.32 M, around 19 seconds should pass.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                For the reaction below, what would the rate law be?

                2CH_3_OH(g) + 3O_2_(g) ➝ 2CO_2_(g) + 4H_2_O(g)
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[CH_3_OH]^x^[O_2_]y",
                    explanation: """
                    Rate = k[CH_3_OH]^x^[O2]^y^ is correct because there's no way to know the \
                    exponents without more information. The rate law has to be determined \
                    experimentally for each reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[CH_3_OH][O_2_]",
                        explanation: """
                        Rate = k[CH_3_OH][O_2_] assumes that the reaction is first order for each \
                        reactant without any information to back it up.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[CH_3_OH][O_2_]^2^",
                        explanation: """
                        Rate = k[CH_3_OH]^x^[CO]^y^ has a product as an element for the equation, \
                        which is incorrect.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[CH_3_OH]^2^[O_2_]^3^",
                        explanation: """
                        Rate = k[CH_3_OH]^2^[O_2_]^3^ assumes that the coefficients are the \
                        exponents for the equation, which would only be true if it was an \
                        elementary single step reaction, which rarely is the case.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                Based on the information below, what is the constant rate for the reaction?

                The table below shows recorded concentration data for the following reaction:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[NH_3_]^2^[HCl]",
                    explanation: """
                    When [HCl] goes from 0.0132 to 0.0264 (it's doubled, goes up by a factor of 2) \
                    the rate goes from $4.30x10^-4^$ to $8.55x10^-44^$ (approximately double, it \
                    goes up by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first \
                    order for [HCl].

                    When [HCl] drops to 0.0066, if [NH_3_] were maintained at 0.0176, then we could \
                    determine that the rate would have been $2.15x10^-4^$ (half of $4.30x10^-4^$) \
                    since we know it's of first order for [HCl]. In order for the rate to be \
                    $8.60x10^-4^$ when [NH_3_] goes from 0.0176 to 0.0352 (it's doubled, goes up \
                    by a factor of 2), it had to be quadrupled (go up by a factor of 4). \
                    $2^x^ = 4$. where $x = 2$; the reaction is of second order for [NH_3_].
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer:  "Rate = k[NH_3_][HCl]",
                        explanation: """
                        Try comparing how the reactants concentrations affect the rate of \
                        appearance of NH_4_Cl.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[NH_3_][HCl]^2^",
                        explanation: """
                        Given the data, the concentrations affect the rate but not in this \
                        proportions.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[NH_3_]^2^[HCl]^2^",
                        explanation: """
                        When [HCl] goes from 0.0132 to 0.0264 (it's doubled, goes up by a factor \
                        of 2) the rate goes from 4.30x10^-4^ to 8.55x10^-44^ (approximately \
                        double, it goes up by a factor of 2). $2^x^ = 2$ where $x = 1$; the \
                        reaction is first order for [BHCl].
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium,
                table: QuizTable(
                    rows: [
                        ["[NH_3_] (M)", "[HCl]", "NH_4_CI rate of appearance M/s"],
                        ["0.0176", "0.0132", "4.30x10^-4^"],
                        ["0.0176", "0.0264", "8.55x10^-4^"],
                        ["0.0352", "0.0066", "8.60x10^-4^"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
                Based on the information below, what is the constant rate for the reaction?

                The table below shows recorded concentration data for the following reaction:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "106 M^-2^s^-1^",
                    explanation: """
                    The rate law for this reaction can be determined as $rate = k[NO]^2^[Br_2_]$, \
                    so by replacing the values using the data we get:

                    $4.30x10^-4^ = k(0.0176^2^)(0.0132)$.

                    Clearing for k:
                    $k = (4.30x10^-4^)/((0.0176^2^)(0.0132)) = 106 M^-2^ s^-1^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "106 s^-1^",
                        explanation: """
                        106 would be the correct value but be aware of the units.
                        """
                    ),
                    QuizAnswerData(
                        answer: "55 M s^-1^",
                        explanation: """
                        Since both concentrations affect the rate of the reaction, it cannot be a \
                        zero order reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "55 M^-2^s^-1^",
                        explanation: """
                        Try determining first the rate law equation for the reaction given the \
                        data provided.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                table: QuizTable(
                    rows: [
                        ["[NO] (M)", "[Br_2_]", "NOBr rate of appearance M/s"],
                        ["0.0176", "0.0132", "4.30x10^-4^"],
                        ["0.0176", "0.0264", "8.55x10^-4^"],
                        ["0.0352", "0.0066", "8.60x10^-4^"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
            Based on the information below, how would you write the rate Law equation for this reaction? \
            Take into account that the reaction is of third order for [H^+^]

            The table below shows recorded concentration data for the following reaction:

            8H^+^ + 4Cl^-^ + M_n_O^-^_4_ ➝ 2Cl_2_ + Mn^2+^ + 4H_2_O
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[Cl^-^]^2^[MnO_4_][H^+^]^3^",
                    explanation: """
                    When [Cl^-^] goes from 0.0125 to 0.0375 (it's tripled, goes up by a factor of \
                    3) the rate goes from 3.9x10^-13^ to 3.51x10^-12^ (nine times higher, it goes \
                    up by a factor of 9). $3^x^ = 9$ where $x = 2$; the reaction is second order \
                    for [Cl^-^].

                    When [MnO4^-^] goes from 0.0096 to 0.0048 (it's halved, goes up down by a \
                    factor of 2) the rate goes from 3.51x10^-12^ to 1.76x10^-12^ (it's halved, it \
                    goes down by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first \
                    order for [MnO_4_^-^].
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[Cl^-^]^3^[MnO_4_]^2^[H^+^]^3^",
                        explanation: """
                        Try comparing how the reactants concentrations of Cl^-^ and MnO_4_ affect \
                        the rate of the reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[Cl^-^]^2^[MnO_4_]^2^[H^+^]^3^",
                        explanation: """
                        When [MnO4^-^] goes from 0.0096 to 0.0048 (it's halved, goes up down by a \
                        factor of 2) the rate goes from 3.51x10^-12^ to 1.76x10^-12^ (it's halved, \
                        it goes down by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is \
                        first order for [MnO4^-^].
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[Cl^-^][MnO_4_][H^+^]^3^",
                        explanation: """
                        When [Cl^-^] goes from 0.0125 to 0.0375 (it's tripled, goes up by a factor \
                        of 3) the rate goes from 3.9x10^-13^ to 3.51x10^-12^ (nine times higher, \
                        it goes up by a factor of 9). $3^x^ = 9$ where $x = 2$; the reaction is \
                        second order for [Cl^-^].
                        """
                    ),
                ],
                explanation: nil,
                difficulty: .medium,
                table: QuizTable(
                    rows: [
                        ["[Cl^-^] (M)", "[MnO_4_] (M)", "Rate M/s"],
                        ["0.0125", "0.0096",  "3.9x10^-13^"],
                        ["0.0375", "0.0096", "3.51x10^-12^"],
                        ["0.0375", "0.0048",  "1.76x10^-12^"]
                    ]
                )
            ),
            QuizQuestionData(
                question: """
            The rate Law for a reaction $A + B ➝ C$ has been determined: $rate = k[A]^2^[B]^3^$. Which of \
            the following is the overall order of the reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Fifth overall",
                    explanation: """
                    The reaction is second order in respect to A and third order in respect to B. \
                    It is said then that since $2 + 3 = 5$, the reaction is of fifth order overall.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Second overall",
                        explanation: """
                        The reaction is second order with respect to A so it would be impossible \
                        for the overall reaction order to be 2 since B is also affecting the rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third overall",
                        explanation: """
                        The reaction is third order with respect to B so it would be impossible \
                        for the overall reaction order to be 3 since A is also affecting the rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Fourth overall",
                        explanation: """
                        The overall order of a reaction is the sum of the individual orders.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            Consider the following mechanism for a reaction:

            A + B ➝ I (fast)
            I + A ➝ C + D (slow)

            Which is the rate law equation for the reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[A]^2^[B]",
                    explanation: """
                    Many reactions proceed from reactants to products through a sequence of \
                    reactions (elementary reactions, or steps). This sequence of reactions is \
                    called the reaction mechanism. The reaction mechanism for elementary steps or \
                    reactions is very simple to write since it's determined by the stoichiometry.

                    For example, if we were going to write Step 1's rate law, it would be: \
                    $rate = k[A][B]$. Furthermore, the slowest step, in this case Step 2, is also \
                    called the rate-determining step, because the overall reaction cannot go \
                    faster than the slowest of the steps.

                    In other words, the rate for this reaction would be $rate = k[I][A]$ but since \
                    I is only the intermediate, then the actual rate law is: $rate = k[A]^2^[B]$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[A][B]",
                        explanation: """
                        $Rate = k[A][B]$ would be the rate law equation for the elementary step 1 \
                        (fast step) of the reaction mechanism.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[I][A]",
                        explanation: """
                        $Rate = k[I][A]$ would be the rate law equation for the elementary step 2 \
                        (slow step) of the reaction mechanism, which even though is the \
                        rate-determining step, I itself is an intermediate and not a reactant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[A][B][I]",
                        explanation: """
                        I is not a reactant of the overall reaction. To know the overall reaction, \
                        sum all the elementary steps and cancel the reactants/products appearing \
                        in both sides of the equation.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .hard
            ),
            QuizQuestionData(
                question: """
            Consider an elementary reaction whose rate law is: $rate = k[A]^2^[B]^2^$. Which are the \
            reactants of the balanced reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "2A + 2B",
                    explanation: """
                    Just for elementary reactions like this, the coefficients of the balanced \
                    equation are in fact the exponents of the concentration elements in the rate \
                    law equation. In this case since A and B both have exponents of 2, then the \
                    coefficients in the balanced equations are 2 too: $2A + 2B$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A + B",
                        explanation: """
                        Even though A and B are the reactants of the reaction, the coefficients \
                        are important.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A^2^ + B^2^",
                        explanation: """
                        The coefficients of the reactions are the number values on the left of the \
                        species, which in this case are A and B.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The coefficients of the rate law are unrelated to the reactants in the balanced equation",
                        explanation: """
                        The coefficients are related when it comes to elementary steps or elementary reactions.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            What would be true about the order of a reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Reaction order can only be determined by experiment",
                    explanation: """
                    The correct answer is that the reaction order can only be determined \
                    experimentally.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Reaction order can only be a whole number",
                        explanation: """
                    For high school chemistry, most common reactions studied are of second order, first \
                    order, half order and zero order, that already means that it is not mandatory for the \
                    order of a reaction to be a whole number.
                    """
                    ),
                    QuizAnswerData(
                        answer: """
                    Reaction order can be determined only by the coefficients of the balanced equation for \
                    the reaction
                    """,
                        explanation: """
                    Reaction order can be determined by the coefficients of the balanced equations only in \
                    the case of elementary single step reactions.
                    """
                    ),
                    QuizAnswerData(
                        answer: "Reaction order increases with increasing temperature",
                        explanation: """
                    Increasing the temperature does result in an increase of the rate of the reaction, but \
                    it doesn't affect the order of the reaction.
                    """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
            The rate of which type of reaction would remain the same if it was taking place within a closed \
            container at standard conditions and the concentrations of all reactants were doubled at the \
            same time?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Zero order",
                    explanation: """
                    For a zero order reaction $rate = k$, which in other words means it's constant. So the rate of \
                    the reaction won't change with the concentration of the reactants.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "First order",
                        explanation: """
                        The rate of first order reactions is affected by the concentration of one \
                        reactant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        The rate of first order reactions is affected by the concentration of one \
                        or two reactants.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third order",
                        explanation: """
                        The rate of first order reactions is affected by the concentration of one \
                        or more reactants.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            Calculating the rate constant only knowing the half-life of a reaction, is only possible for \
            which type of reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "First order",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$, \
                    meaning that we only need to know the rate constant to calculate the half-life and vice-versa.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order",
                        explanation: """
                        For zero order reactions, the equation for half-life is \
                        $t_1/2_ = [A_0_]/2\\*k$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        For second order reactions, the equation for half-life is \
                        $t_1/2_ = 1/[A_0_]\\*k$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third order",
                        explanation: """
                        Try considering what are the equations of half-life for the different orders.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
            The half-life of a first order reaction $(A ➝ B)$ is equal to 198 seconds. What percentage of \
            the reactant would be left after 390 seconds have passed?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "25.5%",
                    explanation: """
                    First it is important to determine k. The equation for half-life for a first order reaction is \
                    $t_1/2_ = ln(2)/k$. If t_1/2_ is 198 seconds, we only need to replace it and solve for k: \
                    $k = ln(2)/198 = 0.0035 seconds^-1^$.

                    The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After 390 seconds have \
                    passed, there's a fraction of A remaining, or: $[4A] = X[A_0_]$.

                    Replacing we get: $ln(X[A_0_]) = ln[A_0_] - (0.0035)(390)$.

                    Moving all logarithmic expressions to one side: $(0.0035)(390) = ln([A_0_]) - lnX[A_0_]$.

                    Using logarithmic properties: $(0.0035)(390) = ln([A_0_]/X[A_0_])$. Cancelling [A_0_] from the \
                    expression and solving numerically: $(1.365) = ln(1/X)$.

                    Applying exponential to both sides: $e^1.365^ = 1/X$.

                    Finally solving for X: $X = 1/e^1.365^ = 0.255$ which is the same as 25.5%.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "12%",
                        explanation: """
                        In order for 12% of A to be left, around 605 seconds should have passed.
                        """
                    ),
                    QuizAnswerData(
                        answer: "15.5%",
                        explanation: """
                        In order for 15.5% of A to be left, around 532 seconds should have passed.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.98%",
                        explanation: """
                        In order for 15.5% of A to be left, around 1321 seconds should have passed.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                The half-life of a first order reaction $(A ➝ B)$ is equal to 232 seconds. What percentage of \
                the reactant would be left after 490 seconds have passed?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "23.1%",
                    explanation: """
                    First is important to determine k. The equation for half-life for a first order reaction is \
                    $t_1/2_ = ln(2)/k$. If t_1/2_ is 232 seconds, we only need to replace it and solve for k: \
                    $k = ln(2)/232 = 0.00298 seconds^-1^$.

                    The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After 490 seconds have \
                    passed, there's a fraction of A remaining, or: $[A] = X[A_0_]$.

                    Replacing we get: $ln(X[A_0_]) = ln[A_0_] - (0.00298)(490)$.

                    Moving all logarithmic expressions to one side: $(0.00298)(490) = ln([A_0_]) - lnX[A_0_]$.

                    Using logarithmic properties: $(0.00298)(490) = ln([A_0_]/X[A_o_])$. Cancelling [A_0_] from the \
                    expression and solving numerically: $(1.464) = ln(1/X)$.

                    Applying exponential to both sides: $e^1.464^ = 1/X$.

                    Finally solving for X: $X = 1/e^1.464^ = 0.231$ which is the same as 23.1%.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "15.5%",
                        explanation: """
                        In order for 15.5% of A to be left, around 625 seconds should have passed.
                        """
                    ),
                    QuizAnswerData(
                        answer: "25.5%",
                        explanation: """
                        In order for 25.5% of A to be left, around 458 seconds should have passed.
                        """
                    ),
                    QuizAnswerData(
                        answer: "3.78%",
                        explanation: """
                        In order for 3.78% of A to be left, around 1099 seconds should have passed.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Considering that radioactive decay is a first order process: half-life for the \
                decay of Bismuth-212 is 60 seconds, while for Cobalt-60 it's 5.3 years. Which of \
                the following statements would be correct?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The rate constant for the decay of Bismuth-212 is greater to the rate constant \
                    for the decay of Cobalt-60
                    """,
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    Solving for k, we get: $k = ln(2) / t_1/2_$. The higher the half-life is, the \
                    smaller the rate constant k is.

                    For Cobalt-60, its massive half-life of 5.3 years is much greater than the 60 \
                    second half-life of Bismuth-212 decay, making the Cobalt-60 rate constant much \
                    smaller.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The rate constant for the decay of Bismuth-212 is equal to the rate \
                        constant for the decay of Cobalt-60.
                        """,
                        explanation: """
                        The decay of Bismuth-212 and Cobalt-60 don't have the same constant given \
                        that their half-lifes are different
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate constant for the decay of Bismuth-212 is lower to the rate \
                        constant for the decay of Cobalt-60.
                        """,
                        explanation: """
                        The rate constant is directly proportional to the rate of the reaction \
                        itself. Since half-life is the time the reaction takes to make the \
                        reactant half of its initial concentration, the higher it is the slower \
                        the reaction is too. Given the data provided, the half-life of Bismuth-212 \
                        is smaller than the one of Cobalt-60 by a lot.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It's not possible to compare both rate constants with the given information",
                        explanation: """
                        Only for first order reactions, half-life is sufficient data to determine \
                        the rate constant of a reaction.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
        ]
    )
}
