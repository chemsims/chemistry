//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let reactionComparisonQuizQuestions = QuizQuestionsList(
        questionSet: .reactionComparison,
        [
            QuizQuestionData(
                id: "COMPARISON-1",
                question: """
                For any given reaction, what would be the way to determine the rate of reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "The rate law has to be determined experimentally",
                    explanation: "The rate law has to be determined experimentally for each reaction."
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The rate law has to be determined by knowing at which temperature the reaction occurs.",
                        explanation: """
                        The rate law does depend on the temperature (since the constant k depends \
                        on the temperature) but that doesn't mean that only knowing it is enough \
                        to determine the rate law equation.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The rate law has to always be determined by using the coefficients of the balanced equation as the orders of each species. ",
                        explanation:
                            "The rate law is only determined by the coefficients of the balanced equation in the case of elementary single step reactions."
                    ),
                    QuizAnswerData(
                        answer: "The rate law has to be determined by knowing which catalysts are being used to increase the rate of the reaction.",
                        explanation: """
                        The rate law cannot be determined just by knowing the catalysts that are \
                        being used, even though these affect the rate of the reaction.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-2",
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
                difficulty: .easy,
                image: LabelledImage(
                    image: "reaction-comparison",
                    label: """
                    Three charts showing time in seconds on the x axis.
                    Chart 1 shows concentration of A, with a curved line that reduces as time increases.
                    Chart 2 shows ln a, with a straight line that reduces as time increases.
                    Chart 3 shows inverse A, with a curved line that increases as time increases.
                    """
                )
            ),
            QuizQuestionData(
                id: "COMPARISON-3",
                question: """
                Units for the rate constant vary with the order and the rate law of the equation. For this rate \
                law, $rate = k[A]^3^[B]$. What would be the units for k, the rate constant?
                """,
                questionLabel: """
                Units for the rate constant vary with the order and the rate law of the equation. For this rate \
                law, rate = k, times [A]^3^, times [B]. What would be the units for k, the rate constant?
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

                    which is the same as $s^-1^M^-3^$.

                    A short way to know the units for the rate constant is by using $M^(1-n)^/s$, \
                    where n is the overall order of the equation. When $n = 4$, \
                    $M^(1-4)^/s = s^-1^M^-3^$.
                    """,
                    explanationLabel: """
                    For the rate law equation: rate = k, times [A]^3^, times [B], knowing that concentrations \
                    are in units of M, and rate in $M/s$, you can solve for k:

                    $M/s = k, times M^3^, times M$ ➝
                    $M/s = k, times M^4^$ ➝
                    $k = M/, M to the power of 4 times s$ ➝
                    $k = 1/, M cubed times s$

                    which is the same as s^-1^M^-3^.

                    A short way to know the units for the rate constant is by using M^(1-n)^/s, \
                    where n is the overall order of the equation. When $n = 4$, \
                    $M^(1-4)^, /s, = s^-1^M^-3^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "s^-1^M^-1^",
                        explanation: """
                        Given that rate law equation, the reaction is of fourth order overall. If \
                        the units of the rate constant were s^-1^M^-1^, that would imply a second \
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
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-4",
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
                id: "COMPARISON-5",
                question: """
            Consider a multi-step reaction. The rate laws for the elementary reactions that are part of the \
            proposed mechanism are given. Which one would probably be the rate-determining step of the \
            overall reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[E][F]^2^",
                    answerLabel: "Rate = k times E, times F^2^",
                    explanation: """
                    The rate-determining step would probably be $rate = k[E][F]^2^$. Of all the \
                    rate laws, this one is of the highest order (third overall) and implies that a \
                    successful collision of 3 molecules has to take place for the reaction to \
                    occur. Since the probabilities of this happening are lower, the chances of \
                    this reaction to be slower than the other ones is greater. Being the slowest \
                    of all the steps, this would be the rate-determining step.
                    """,
                    explanationLabel: """
                    The rate-determining step would probably be $rate = k times E, times F^2^$. Of all the \
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
                        answerLabel: "Rate = k times A, times B",
                        explanation: """
                        A rate law equation as $rate = k[A][B]$ for an elementary step suggests \
                        that a successful collision between A and B has to take place. Compared to \
                        the rest, this would not be the slowest reaction or step.
                        """,
                        explanationLabel: """
                        A rate law equation as rate = k times A, times B, for an elementary step suggests \
                        that a successful collision between A and B has to take place. Compared to \
                        the rest, this would not be the slowest reaction or step.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[D]^2^",
                        answerLabel: "Rate = k, times [D]^2^",
                        explanation: """
                        A rate law equation as $rate = k[D]^2^$ for an elementary step suggests \
                        that a successful collision between two molecules of D has to take place. \
                        Compared to the rest, this would not be the slowest reaction or step.
                        """,
                        explanationLabel: """
                        A rate law equation as rate = k, times [D]^2^, for an elementary step suggests \
                        that a successful collision between two molecules of D has to take place. \
                        Compared to the rest, this would not be the slowest reaction or step.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-6",
                question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.11 M^-1^s^-1^. How much time will \
            it take for the concentration of A to drop to 0.43 M considering that the reaction started \
            with 0.50 M?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "3 seconds",
                    explanation: """
                    The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing \
                    k, [A_0_] and the [A] at which it's going to drop, we just solve for time (t):

                    $t = (1/[A] - 1/[A_0_])/k$ ➝
                    $t = (1/0.43 - 1/0.50)/0.11 = 2.95 seconds$, or roughly 3 seconds.
                    """,
                    explanationLabel: """
                    The equation for a second order reaction is, inverse A = inverse A0 + kt. Knowing \
                    k, [A_0_] and the [A] at which it's going to drop, we just solve for time (t):

                    t = inverse A - inverse A0, /k ➝
                    t = 1/0.43, - 1/0.50, /0.11, = 2.95 seconds, or roughly 3 seconds.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "4 seconds",
                        explanation: """
                        After 4 seconds the concentration of A would have already dropped to 0.41 M.
                        """
                    ),
                    QuizAnswerData(
                        answer: "5 seconds",
                        explanation: """
                        After 5 seconds the concentration of A would have already dropped to 0.39 M.
                        """
                    ),
                    QuizAnswerData(
                        answer: "6 seconds",
                        explanation: """
                        After 6 seconds the concentration of A would have already dropped to 0.38 M.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-7",
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
                    """,
                    explanationLabel: """
                    The equation for a second order reaction is, inverse A = inverse A0 + kt. Knowing \
                    k, [A_0_] and the time, we just solve for [A]:

                    [A] = [A_0_]/, \(Labels.openParen) [A_0_] times kt,  + 1, \(Labels.closedParen) ➝
                    [A] = 0.94/, \(Labels.openParen) (0.94 \\* 0.11 \\* 12, + 1, \(Labels.closedParen), = 0.42 M.
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
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-8",
                question: """
                For the reaction below, what would the rate law be?

                2NO_(g)_ + O_2__(g)_ ➝ 2NO_2__(g)_
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[NO]^m^[O_2_]^n^",
                    answerLabel: "Rate = k, times [NO]^m^, times [O_2_]^n^",
                    explanation: """
                    This is correct because there's no way to know the \
                    exponents without more information. The rate law has to be determined \
                    experimentally for each reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[NO][O_2_]",
                        answerLabel: "Rate = k times [NO] times [O_2_]",
                        explanation: """
                        This assumes that the reaction is first order for each \
                        reactant without any information to back it up.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[NO][O_2_]^2^",
                        answerLabel: "Rate = k times [NO], times [O_2_]^2^",
                        explanation: """
                        This has a product as an element for the equation, \
                        which is incorrect.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[NO]^2^[O_2_]^3^",
                        answerLabel: "Rate = k, times [NO]^2^, times [O_2_]^3^",
                        explanation: """
                        This assumes that the coefficients are the \
                        exponents for the equation, which would only be true if it was an \
                        elementary single step reaction.
                        """
                    )
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                id: "COMPARISON-9",
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
                id: "COMPARISON-10",
                question: """
                Consider a reaction that took place at very high temperatures, in which the \
                reactants are NO and H_2_. Based on the information in the table below, what is \
                the constant rate for the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "2.02x10^-24^ M^-2^s^-1^",
                    explanation: """
                    The rate law for this reaction can be determined as $rate = k[NO]^2^[H_2_]$, \
                    so by replacing the values using the data we get:

                    $8.26x10^-4^ = k(0.0176^2^)(0.0132)$.

                    Clearing for k:

                    k = $(8.26x10^-30^)/((0.0176^2^)(0.0132))$ = $2.02x10^-24^ M^-2^ s^-1^$.
                    """,
                    explanationLabel: """
                    The rate law for this reaction can be determined as, rate = k, times [NO]^2^, times [H_2_], \
                    so by replacing the values using the data we get:

                    8.26x10^-4^ = k, times 0.0176^2^, times 0.0132.

                    Clearing for k:

                    k = 8.26x10^-30^, /, 0.0176^2^ times 0.0132, = $2.02x10^-24^ M^-2^ s^-1^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "2.02x10^-24^ s^-1^",
                        explanation: """
                        2.02 would be the correct value but be aware of the units.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1.01x10^-24^ s^-1^",
                        explanation: """
                        Since both concentrations affect the rate of the reaction, it cannot be a \
                        first order reaction, so the units couldn't possible be s^-1^.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1.01x10^-24^ M^-2^s^-1^",
                        explanation: """
                        Try determining first the rate law equation for the reaction given the \
                        data provided.
                        """
                    )
                ],
                difficulty: .easy,
                table: QuizTable(
                    rows: [
                        ["[NO] (M)", "[H_2_]", "Rate of reaction (M/s)"],
                        ["0.0176", "0.0132", "8.26x10^-30^"],
                        ["0.0176", "0.0264", "1.65x10^-29^"],
                        ["0.0352", "0.0066", "1.65x10^-29^"]
                    ]
                )
            ),
            QuizQuestionData(
                id: "COMPARISON-11",
                question: """
                Consider a reaction that's: 3A + 2B + 5C ➝ 2D + E + F.

                Determine what the rate constant would be for the reaction given the data shown in \
                the table below.

                Take into account that the reaction is order 2 with respect to C, and the \
                concentration of it remains as 0.0125 M throughout all the experiments conducted.
                """,
                questionLabel:  """
                Consider a reaction that's: 3A + 2B + 5C, to, 2D + E + F.

                Determine what the rate constant would be for the reaction given the data shown in \
                the table below.

                Take into account that the reaction is order 2 with respect to C, and the \
                concentration of it remains as 0.0125 M throughout all the experiments conducted.
                """,
                correctAnswer: QuizAnswerData(
                    answer: "3.33x10^-3^ M^-4^ s^-1^",
                    explanation: """
                    When [A] goes from 0.0125 to 0.0375 (it's tripled, it goes up by a factor of \
                    3) the rate of appearance of D goes from $3.9x10^-13^$ to $3.51x10^-12^$ (nine \
                    times higher, it goes up by a factor of 9). $3^x^ = 9$ where $x = 2$; the \
                    reaction is second order for [A].

                    When [B] goes from 0.0096 to 0.0048 (it's halved, it goes down by a factor \
                    of 2) the rate goes from $3.51x10^-12^$ to $1.76x10^-12^$ (it's halved, it \
                    goes down by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first \
                    order for [B]. The rate law result is, $rate = k[A]^2^[B][C]^2^$.

                    Now we just replace the values to determine k, but take into account that \
                    rate of reaction = 2 \\* rate of appearance of C, because $rate = [ΔD]/2Δt$, \
                    where $-[ΔD]/Δt$ is the rate of appearance of D.

                    Replacing, we get:

                    $2 \\* 3.9x10^-13^ =$ $k(0.0125)^2^(0.0096)(0.0125)^2^$.

                    Solving for k:

                    k = $2 \\* 3.9x10^-13^$ / $(0.0125)^2^(0.0096)(0.0125)^2^$
                    k = 3.33x10^-3^ M^-4^ s^-1^.
                    """,
                    explanationLabel: """
                    When [A] goes from 0.0125 to 0.0375 (it's tripled, it goes up by a factor of \
                    3) the rate of appearance of D goes from $3.9x10^-13^$ to $3.51x10^-12^$ (nine \
                    times higher, it goes up by a factor of 9). $3^x^ = 9$ where $x = 2$; the \
                    reaction is second order for [A].

                    When [B] goes from 0.0096 to 0.0048 (it's halved, it goes down by a factor \
                    of 2) the rate goes from $3.51x10^-12^$ to $1.76x10^-12^$ (it's halved, it \
                    goes down by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first \
                    order for [B]. The rate law result is, rate = k, times [A]^2^, times [B], times [C]^2^.

                    Now we just replace the values to determine k, but take into account that \
                    rate of reaction = 2 \\* rate of appearance of C, because $rate = [ΔD]/2Δt$, \
                    where $-[ΔD]/Δt$ is the rate of appearance of D.

                    Replacing, we get:

                    2 \\* 3.9x10^-13^ = k, times 0.0125^2^, times 0.0096, times 0.0125^2^.

                    Solving for k:

                    k = 2 \\* 3.9x10^-13^ / (0.0125^2^ times 0.0096 times 0.0125^2^)
                    k = 3.33x10^-3^ M^-4^ s^-1^.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "5.2x10^-7^ M^-4^ s^-1^",
                        explanation: """
                        You may have gotten $5.2x10^-7^$ M^-4^ s^-1^ as a result because you forgot to \
                        include [C]2 in the rate law equation when calculating the rate constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1.66x10^-3^ M^-4^ s^-1^",
                        explanation: """
                        You may have gotten $1.66x10^-3^$ M^-4^ s^-1^ as a result because you \
                        forgot that the rate of reaction is not the same as the rate of appearance \
                        of D. Think of how these relate to each other to determine the rate constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "2.6x10^-7^ M^-4^ s^-1^",
                        explanation: """
                        Remember that the reaction is order 2 with respect to C, and is part of \
                        the rate law equation as [C]2. Also, take into account that the rate of \
                        reaction = $[ΔD]/2Δt$, where [ΔD]/Δt is rate of appearance of D, the \
                        measured value in the tables.
                        """
                    ),
                ],
                difficulty: .medium,
                table: QuizTable(
                    rows: [
                        ["[A] (M)", "[B] (M)", "Rate of appearance of D"],
                        ["0.0125", "0.0096",  "3.9x10^-13^"],
                        ["0.0375", "0.0096", "3.51x10^-12^"],
                        ["0.0375", "0.0048",  "1.76x10^-12^"]
                    ]
                )
            ),
            QuizQuestionData(
                id: "COMPARISON-12",
                question: """
                Consider this reaction: $A + 5B + 2C + 3D ➝ Products$. The rate law equation has \
                been determined to be, $rate = k[A][B]^2^[D]$. Knowing this, what would the \
                overall order of the reaction be?
                """,
                questionLabel: """
                Consider this reaction: A + 5B, + 2C, + 3D, to Products. The rate law equation has \
                been determined to be, rate = k times [A], times [B]^2^, times [D]. Knowing this, what would the \
                overall order of the reaction be?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Fourth overall",
                    explanation: """
                    The reaction is first order with respect to A, second order with respect to B, \
                    zero order with respect to C and first order with respect to D. The sum of the \
                    individual orders go as: $1 + 2 + 0 + 1 = 4$, so the reaction is of fourth \
                    order overall.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Second overall",
                        explanation: """
                        The reaction is second order with respect to B so it would be impossible \
                        for the overall reaction order to be 2 since A and D are also affecting the rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third overall",
                        explanation: """
                        Remember the sum of the exponents (individual orders) in the rate law \
                        equation is the overall order of the reaction
                        """
                    ),
                    QuizAnswerData(
                        answer: "Fifth overall",
                        explanation: """
                        Remember that since C doesn't appear in the rate law equation, it means \
                        it's zero order with respect to it.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-13",
                question: """
                Consider the reaction of which the mechanism (steps of the overall reaction) is this:

                X + Y + Z ➝ XY (fast)
                XY + Z ➝ A + B (slow)

                What would be the rate law equation for the overall reaction?
                """,
                questionLabel: """
                Consider the reaction of which the mechanism (steps of the overall reaction) is this:

                X + Y + Z, to XY (fast)
                XY + Z, to A + B (slow)

                What would be the rate law equation for the overall reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[X][Y][Z]^2^",
                    explanation: """
                    Many reactions proceed from reactants to products through a sequence of \
                    reactions (elementary reactions, or steps). This sequence of reactions is \
                    called the reaction mechanism.

                    The reaction mechanism for elementary steps or reactions is very simple to \
                    write since it's determined by the stoichiometry. For example, if we were \
                    going to write step 1's rate law, it would be: $rate = k[X][Y][Z]$. \
                    Furthermore, the slowest step, in this case step 2, is also called the \
                    rate-determining step, because the overall reaction cannot go faster than \
                    the slowest of the steps.

                    In other words, the rate for this reaction would be $rate = k[XY][Z]$, but \
                    since I is only the intermediate, then the actual rate law is: \
                    $rate = k[X][Y][Z]^2^$
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[X][Y][Z]",
                        explanation: """
                        $Rate = k[X][Y][Z]$ would be the rate law equation for the elementary \
                        step 1 (fast step) of the reaction mechanism.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[XY][Z]",
                        explanation: """
                        $Rate = k[XY][Z]$ would be the rate law equation for the elementary step 2 \
                        (slow step) of the reaction mechanism, which even though it's the \
                        rate-determining step, XY itself is an intermediate and not a reactant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[X][Y][XY]",
                        explanation: """
                        XY is not a reactant of the overall reaction. To know the overall \
                        reaction, sum all the elementary steps and cancel the reactants/products \
                        appearing in both sides of the equation.
                        """
                    )
                ],
                difficulty: .hard
            ),
            QuizQuestionData(
                id: "COMPARISON-14",
                question: """
                Consider a reaction that follows these elementary steps:

                Step 1: [ ]A + [ ]B ➝ C
                Step 2: D + E ➝ F
                Step 3: F ➝ G

                Considering that the rate law equation for the step 1 reaction is \
                $rate = k[A]^2^[B]^3^$, how would the reactants side of the balanced equation \
                look like (with the [ ] filled with the values of the coefficients)?
                """,
                questionLabel: """
                Consider a reaction that follows these elementary steps:

                Step 1: blank A, +, blank B, to C
                Step 2: D + E, to F
                Step 3: F to G

                Considering that the rate law equation for the step 1 reaction is \
                $rate = k, times [A]^2^, times [B]^3^$, how would the reactants side of the balanced equation \
                look like (with the blanks filled with the values of the coefficients)?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "2A + 3B",
                    explanation: """
                    Just for elementary reactions like this, the coefficients of the balanced \
                    equation are in fact the exponents of the concentration elements in the rate \
                    law equation. In this case since A has an exponent of 2 and B has an exponent \
                    of 3, then the coefficients in the balanced equations are 2 and 3 \
                    respectively: $2A + 3B$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "A + B",
                        answerLabel: "'A' + B",
                        explanation: """
                        Even though A and B are the reactants of the reaction, the coefficients \
                        are important.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A^2^ + B^3^",
                        answerLabel: "'A'^2^ + B^3^",
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
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-15",
                question: """
            What would be true about the order of a reaction?
            """,
                correctAnswer: QuizAnswerData(
                    answer: "Only conducting an experiment can the reaction order be determined for a given reaction",
                    explanation: """
                    For a given reaction, the order can only be determined experimentally.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "When knowing the balanced equation, it's possible to determine the reaction order by replacing the exponents of the equation with the coefficient values.",
                        explanation: """
                        Reaction order can be determined by the coefficients of the balanced equations only in the case of elementary single step reactions.
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        When the temperature increases within a chemical system, the order of the reaction increases as well.
                        """,
                        explanation: """
                        Increasing the temperature does result in an increase of the rate of the \
                        reaction, but it doesn't affect the order of the reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The reaction orders (exponents in the rate law equation) can only be whole numbers.",
                        explanation: """
                        For high school chemistry, most common reactions studied are of second \
                        order, first order, half order and zero order; that already means that is \
                        not mandatory for the order of a reaction to be a whole number.
                        """
                    )
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                id: "COMPARISON-16",
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
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-17",
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
                        $t_1/2_ = [A_0_]/(2 \\* k)$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        For second order reactions, the equation for half-life is \
                        $t_1/2_ = 1/([A_0_] \\* k)$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Third order",
                        explanation: """
                        Try considering what are the equations of half-life for the different orders.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-18",
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
                    """,
                    explanationLabel: """
                    First it is important to determine k. The equation for half-life for a first order reaction is \
                    $t_1/2_ = ln(2)/k$. If t_1/2_ is 198 seconds, we only need to replace it and solve for k: \
                    $k = ln(2)/198 = 0.0035 seconds^-1^$.

                    The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After 390 seconds have \
                    passed, there's a fraction of A remaining, or: $[4A] = X[A_0_]$.

                    Replacing we get: $ln(X[A_0_]) = (ln[A_0_]) - (0.0035)(390)$.

                    Moving all logarithmic expressions to one side: $(0.0035)(390) = ln([A_0_]) - lnX[A_0_]$.

                    Using logarithmic properties: $(0.0035)(390) = ln([A_0_]/X[A_0_])$. Cancelling [A_0_] from the \
                    expression and solving numerically: $(1.365) = ln(1/X)$.

                    Applying exponential to both sides: $e^1.365^ = 1/X$.

                    Finally, solving for X: $X = 1/e^1.365^ = 0.255$ which is the same as 25.5%.
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
                        In order for 15.5% of A to be left, around 1,321 seconds should have passed.
                        """
                    )
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-19",
                question: """
                The half-life of a first order reaction $(A ➝ B)$ is equal to 232 seconds. What percentage of \
                the reactant would be left after 490 seconds have passed?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "23.1%",
                    explanation: """
                    First it is important to determine k. The equation for half-life for a first order reaction is \
                    $t_1/2_ = ln(2)/k$. If t_1/2_ is 232 seconds, we only need to replace it and solve for k:

                    $k = ln(2)/232 = 0.00298 seconds^-1^$.

                    The equation for a first order reaction is, $ln[A] = ln[A_0_] - kt$. After 490 seconds have \
                    passed, there's a fraction of A remaining, or: $[A] = X[A_0_]$.

                    Replacing, we get: $ln(X[A_0_]) = ln[A_0_] - (0.00298)(490)$.

                    Moving all logarithmic expressions to one side: $(0.00298)(490) = ln[A_0_] - ln(X[A_0_])$.

                    Using logarithmic properties: $(0.00298)(490) = ln([A_0_]/X[A_0_])$. Cancelling [A_0_] from the \
                    expression and solving numerically: $(1.464) = ln(1/X)$.

                    Applying exponential to both sides: $e^1.464^ = 1/X$.

                    Finally, solving for X: $X = 1/e^1.464^ = 0.231$ which is the same as 23.1%.
                    """,
                    explanationLabel: """
                    First it is important to determine k. The equation for half-life for a first order reaction is \
                    $t_1/2_ = ln(2)/k$. If t_1/2_ is 232 seconds, we only need to replace it and solve for k:

                    $k = ln(2)/232 = 0.00298 seconds^-1^$.

                    The equation for a first order reaction is, $ln[A] = ln[A_0_] - kt$. After 490 seconds have \
                    passed, there's a fraction of A remaining, or: $[A] = X[A_0_]$.

                    Replacing, we get: $ln(X[A_0_]) = (ln[A_0_]) - (0.00298)(490)$.

                    Moving all logarithmic expressions to one side: $(0.00298)(490) = ln[A_0_] - ln(X[A_0_])$.

                    Using logarithmic properties: $(0.00298)(490) = ln([A_0_]/X[A_0_])$. Cancelling [A_0_] from the \
                    expression and solving numerically: $(1.464) = ln(1/X)$.

                    Applying exponential to both sides: $e^1.464^ = 1/X$.

                    Finally, solving for X: $X = 1/e^1.464^ = 0.231$ which is the same as 23.1%.
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
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "COMPARISON-20",
                question: """
                Considering that radioactive decay is a first order process: half-life for the \
                decay of bismuth-212 is 60 seconds, while for cobalt-60 it's 5.3 years. Which of \
                the following statements would be correct?
                """,
                correctAnswer: QuizAnswerData(
                    answer: """
                    The rate constant for the decay of bismuth-212 is greater to the rate constant \
                    for the decay of cobalt-60
                    """,
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    Solving for k, we get: $k = ln(2) / t_1/2_$. The higher the half-life is, the \
                    smaller the rate constant k is.

                    For cobalt-60, its massive half-life of 5.3 years is much greater than the 60 \
                    second half-life of bismuth-212 decay, making the cobalt-60 rate constant much \
                    smaller.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The rate constant for the decay of bismuth-212 is equal to the rate \
                        constant for the decay of cobalt-60.
                        """,
                        explanation: """
                        The decay of bismuth-212 and cobalt-60 don't have the same constant given \
                        that their half-lifes are different
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        The rate constant for the decay of bismuth-212 is lower to the rate \
                        constant for the decay of cobalt-60.
                        """,
                        explanation: """
                        The rate constant is directly proportional to the rate of the reaction \
                        itself. Since half-life is the time the reaction takes to make the \
                        reactant half of its initial concentration, the higher it is the slower \
                        the reaction is too. Given the data provided, the half-life of bismuth-212 \
                        is smaller than the one of cobalt-60 by a lot.
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
                difficulty: .medium
            ),
        ]
    )
}
