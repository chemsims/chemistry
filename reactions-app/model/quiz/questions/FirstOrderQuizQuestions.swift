//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let firstOrderQuestions = QuizQuestionsList(
        questionSet: .firstOrder,
        [
            QuizQuestionData(
                question: "If a reaction is of first order, it means the rate is dependent on:",
                correctAnswer: QuizAnswerData(
                    answer: "The concentration of one reactant",
                    explanation: """
                    If the overall order of the reaction is 1, that means that the rate of the \
                    reaction depends on the concentration of one reactant, given its rate law: \
                    $rate = k[A]$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The concentration of two or more reactants",
                        explanation: """
                        If the overall order of the reaction is 1, there cannot be two or more \
                        reactants affecting the rate of the reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It depends",
                        explanation: """
                        For first order reactions there is a predetermined number of reactants \
                        that will affect the rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It doesn't depend on anything",
                        explanation: """
                        If the overall order of the reaction is 1, the rate depends on the \
                        concentration of a reactant. Rate is only constant for zero order reactions.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question:
                    "If the rate law for a reaction is $rate = k[A]$, what order is the reaction?",
                correctAnswer: QuizAnswerData(
                    answer: "First order",
                    explanation: """
                    The rate law for first order reactions is rate = k[A] where A is the reactant.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order",
                        explanation: """
                        The rate law for second order reactions is $rate = k[A]^2^$ or \
                        $rate = k[A][B]$ where A and B are the reactants.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        The rate law for second order reactions is $rate = k[A]^2^$ or \
                        $rate = k[A][B]$ where A and B are the reactants.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It depends",
                        explanation: """
                        The rate law is a way to identify the order of the reaction and vice-versa.
                        """
                    ),
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "Rate constant k for a first order reaction has the units of:",
                correctAnswer: QuizAnswerData(
                    answer: "s^-1^",
                    explanation: """
                    Units for the rate constant are $M^(1-n)^/s$ where n is the order. When \
                    $n = 0$, $M^(1-1)^/s = 1/s$ which is the same as s^-1^.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "M/s",
                        explanation: """
                        The units of k are M/s only for zero order reactions.
                        """
                    ),
                    QuizAnswerData(
                        answer: "M^2^/s",
                        explanation: """
                        Units for the rate constant are $M^(1-n)^/s$ where n is the order. This \
                        means there's no way $M^2^/s$ is the unit for any rate constant k.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It depends",
                        explanation: """
                        The units of k do depend on which order the reaction is, but for each type \
                        of reaction there are predetermined k units.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                If a reaction $(A + B to C)$ is first order for A and zero order for B, how do you \
                write the rate law for this reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[A][B]^0^",
                    explanation: """
                    If the reaction is first order for A, that means that its exponent is 1 in the \
                    rate law equation. If the reaction is zero order for B, that means that its \
                    exponent is 0. $Rate = k[A]$ which is the same as $rate = k[A][B]^0^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[A][B]",
                        explanation: """
                        A rate law equation like $rate = k[A][B]$ would imply that the reaction is \
                        first order for A and first order for B.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[A]^1^[B]^1^",
                        explanation: """
                        $Rate = k[A]^1^[B]^1^$ is the same as $rate = k[A][B]$. That rate law \
                        would imply that the reaction is first order for A and first order for B.
                        """
                    ),
                    QuizAnswerData(
                        answer: "k[A]^1^[B]",
                        explanation: """
                        $Rate = k[A]^1^[B]$ is the same as $rate = k[A][B]$. That rate law would \
                        imply that the reaction is first order for A and first order for B.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question:
                    "If the rate constant k has the units of days^-1^, what order is the reaction?",
                correctAnswer: QuizAnswerData(
                    answer: "First order",
                    explanation: """
                    Units for the rate constant are $M^(1-n)^/s$ where n is the order. When \
                    $n = 0$, $M^(1-1)^/s = 1/s$ which is the same as s^-1^. When useful, it can be \
                    represented in any $time^-1^$ unit, for example $days^-1^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order",
                        explanation: """
                        Units for the rate constant are $M^(1-n)^/s$ where n is the order. When \
                        n = 0, $M^(1-0)^/s = M/s$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order",
                        explanation: """
                        Units for the rate constant are $M^(1-2)^/s$ where n is the order. When \
                        n = 0, $M^(1-2)^/s = 1/M \\* s$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It depends",
                        explanation: """
                        The units of k do depend on which order the reaction is, but for each type \
                        of reaction there are predetermined k units.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider the reaction A to B. The reaction started a long time ago. After 1 hour, \
                there's only 12.5% of the initial amount of A left. What is the rate constant for \
                this reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.034667 min^-1^",
                    explanation: """
                    The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After an \
                    hour passed (or 60 minutes), there's only 12.5% of A remaining, or: \
                    $[A] = 0.125[A_0_]$. Replacing we get:

                    ln(0.125[A_0_]) = ln[A_0_] - k(1).

                    Solving for k, $k = (ln[Ao] - ln(0.125[A_0_]))$.

                    Using logarithmic properties:

                    k = ln([A_0_]/0.125[A_0_]) ➝
                    k = ln(1/0.125) = 2.08 hours^-1^

                    which is the same as:
                    2.08 hours^-1^ \\* (1 hour/60 mins) = 0.034667 min^-1^.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.00057 min^-1^",
                        explanation: """
                        0.00057 s^-1^ is actually the correct answer, but be aware of the units.
                        """
                    ),
                    QuizAnswerData(
                        answer: "2.2 h^-1^",
                        explanation: """
                        The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After \
                        an hour passed (or 60 minutes), there's only 12.5% of A remaining, or: \
                        $[A] = 0.125[A_0_]$. Try replacing the values you know to calculate the \
                        constant k.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.034667 s^-1^",
                        explanation: """
                        0.034667 m^-1^ is actually the correct answer, but be aware of the units.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: "What is false for first order reactions?",
                correctAnswer:
                    QuizAnswerData(
                        answer: "The concentration vs time graph for it is a straight line",
                        explanation: """
                        It's false, a graph of [A] vs t will only result in a straight line for \
                        zero order reactions.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate constant k has the units of $1/time$",
                        explanation: """
                        It's true, units for the rate constant are $M^(1-n)^/s$ where n is the \
                        order. When $n = 0$ $M^(1-1)^/s = 1/s$ which is the same as s^-1^. Or, \
                        whichever measurement of $time^-1^$, which is the same as $1/time$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Half-life is independent of concentration of the species.",
                        explanation: """
                        It's true, the half-life equation is $t_1/2_ = ln(2)/k$ so it doesn't \
                        depend on the initial concentration of the species.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate is dependant on the concentration of one reactant",
                        explanation: """
                        It's true, the rate law for first order reactions is $rate=k[A]$ where A \
                        is the reactant, making the rate dependant on the concentration of it.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                What is the half-life for a first order reaction whose rate constant is 34.62 \
                $h^-1^$?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "72 s",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    If k is $34.62 h^-1^$, we only need to replace it in the equation:

                    t_1/2_ = ln(2)/34.62 h^-1^ = 0.02 hours.

                    To get that time in seconds, we need to convert it:

                    0.02 hours \\* $(60 mins / 1 hour)$ \\* $(60 seconds / 1 min)$ = 72 seconds.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "12 s",
                        explanation: """
                        12 seconds is too little time for the reactant to be halved given that \
                        rate constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "36 s",
                        explanation: """
                        The equation for half-life for a first order reaction is \
                        $t_1/2_ = ln(2)/k.$ Try replacing the values you know and calculate \
                        the half-life.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1 h",
                        explanation: """
                        After 1 hour, there would be far less than half of the reactant remaining \
                        (if any).
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Consider the reaction A to B. The reaction started a long time ago. After a day \
                and a half, there's only 3/5 of the initial amount of A left. What is the rate for \
                this reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = 0.34 d^-1^ [A]",
                    explanation: """
                    The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After a \
                    day and a half passed (or 1.5 days), there's 3/5 of A remaining, or: \
                    $[A] = 0.6[A_0_]$.

                    Replacing, we get: $ln(0.6[A_0_]) = ln[A_0_] - k(1.5)$. Solving for $k$, \
                    $k = (ln[A_0_] - ln(0.6[A_0_]))/1.5$.

                    Using logarithmic properties:

                    k = ln([A_0_]/0.6[A_0_])/1.5 ➝
                    k = ln(1/0.6)/1.5 ➝
                    k = 0.340 d^-1^

                    Since it's a first order equation, according to the rate law we get that: \
                    $rate = 0.340d^-1^[A]$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = 1.5 d^-1^ [A]",
                        explanation: """
                        1.5 days have passed since the reaction started.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = 0.51 s^-1^ [A]",
                        explanation: """
                        The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. Try \
                        replacing the known values to calculate k and therefore determine the rate \
                        law equation.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = 0.34 s^-1^ [A]",
                        explanation: """
                        0.340 d^-1^ is actually the correct answer, but be aware of the units.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                The half-life for a first order reaction is 48s. What was the original \
                concentration if, after 1 minute, the reactant concentration is 0.3 M?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.713 M",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    If t_1/2_ is 48 seconds, we only need to replace it in the equation and solve \
                    for $k = ln(2)/48s = 0.0144 seconds^-1^$.

                    The equation for a first order reaction is $[A] = [A_0_]e^-kt^$. If we solve \
                    for $[A_0_] = [A]/e^-kt^$, we only have to replace the values:

                    [A_0_] = 0.3/e^(-0.0144)(60)^ = 0.713 M.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.654 M",
                        explanation: """
                        The equation for half-life for a first order reaction is \
                        $t_1/2_ = ln(2)/k$, try replacing the known values to calculate the \
                        constant k first.
                        """
                    ),
                    QuizAnswerData(
                        answer: "1.4 M",
                        explanation: "1.4 M is far too much."
                    ),
                    QuizAnswerData(
                        answer: "0.4 M",
                        explanation: "0.4 M is far too little."
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                For a reaction $(A to B)$, if a graph plotted with axis $ln[A] vs t$ produces a \
                straight line, what is the order of the equation, and what is the slope of the line?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "First order and -k",
                    explanation: """
                    For a $ln[A] vs t$ graph, if the resultant line is a straight line, the \
                    reaction is a first order reaction. The equation for the line is \
                    $ln[A] = -kt + ln[A_0_]$ where $ln[A] = y$, $t = x$, $-k = m$ (slope) and \
                    $ln[A_0_] = b$ (cut in Y axis), making it $y = mx + b$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order and -([A_0_] - [A_t_])/(t_0_- t)",
                        explanation: """
                        A graph plotting [A] vs t would result in a straight line for zero order \
                        reactions with a slope of -k.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order and -ln[A_0_/A_t_]/(t_0_ - t)",
                        explanation: """
                        A graph plotting 1/[A] vs t would result in a straight line for seconds \
                        order reactions with a slope of k.
                        """
                    ),
                    QuizAnswerData(
                        answer: "None of the above",
                        explanation: "The answer is one of the above.",
                        position: .D
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                If the rate of a reaction $(A to B)$ is 0.02 $M/s$ when there is 0.01 M of A \
                present, how much of [A] would it take for the rate to be 0.015 $M/s$ considering \
                it is a first order reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.0075 M",
                    explanation: """
                    Replacing the first values, and solving for $k = rate/[A]$ ➝ \
                    $k = 0.020 M/s / 0.010 M = 2 s^-1^$.

                    So for a rate of $0.015 M/s$ we just replace and solve for $[A] = rate/k$ ➝ \
                    $[A] = 0.015 M/s / 2 s^-1^ = 0.0075 M$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.075 M",
                        explanation: """
                        Meaning that if the reactant's concentration is 0.075 M, the rate of the \
                        reaction at that point is 0.15 M/s.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.01 M",
                        explanation: """
                        Meaning that if the reactant's concentration is 0.010 M, the rate of the \
                        reaction at that point is 0.020 M/s.
                        """
                    ),
                    QuizAnswerData(
                        answer: "0.015 M",
                        explanation: """
                        Meaning that if the reactant's concentration is 0.015 M, the rate of the \
                        reaction at that point is 0.030 M/s.
                        """
                    )
                ],
                explanation: "Following the rate law equation, $rate = k[A]$. ",
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                If a reaction $(A + B to C)$ is zero order for A and first order for B, how do you \
                write the rate law for the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer:  "Rate = k[A]^0^[B]^1^",
                    explanation: """
                    If the reaction is zero order for A, that means that its exponent is 0 in the \
                    rate law equation. If the reaction is first order for B, that means that its \
                    exponent is 1. $Rate = k[B]$ which is the same $rate = k[A]^0^[B]^1^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[A][B]^1^",
                        explanation: """
                        A rate law of $rate = k[A][B]^1^$ which is the same as $rate = k[A][B]$, \
                        implies a reaction that's first order for A and first order for B.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[A]^1^[B]^1^",
                        explanation: """
                        A rate law of $rate = k[A]^1^[B]^1^$ which is the same as \
                        $rate = k[A][B]$, implies a reaction that's first order for A and first \
                        order for B.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[A][B]^0^",
                        explanation: """
                        A rate law of $rate = k[A][B]^0^$ which is the same as $rate = k[A]$, \
                        implies a reaction that's first order for A and zero order for B.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                The half-life for a first order reaction is 36 mins. What was the original \
                concentration if, after 52 minutes, the reactant concentration is 0.2 M?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.544 M",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    If $t_1/2_$ is 36 mins, we only need to replace it and solve for k: \
                    $k = ln(2)/36mins = 0.0192 mins^-1^$.

                    The equation for first order reactions is $[A] = [A_0_]e^-kt^$. If we solve for \
                    $[A_0_] = [A]/e^-kt^$, we only have to replace the values: \
                    $[A_0_] = 0.2/e^(-0.0192)(52)^ = 0.544 M$
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "0.322 M",
                        explanation: "0.322 M is too low."
                    ),
                    QuizAnswerData(
                        answer: "1.088 M",
                        explanation: "1.088 M is too high."
                    ),
                    QuizAnswerData(
                        answer: "0.322 M",
                        explanation: """
                        The equation for half-life for a first order reaction is \
                        $t_1/2_ = ln(2)/k$. Try replacing the known values to calculate the rate \
                        constant first.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                If the rate constant k has units of $week^-1^$, what order is the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "First Order",
                    explanation: """
                    Units for the rate constant are $M^(1-n)^/s$ where n is the order. When \
                    $n = 0$, $M^(1-1)^/s = 1/s$ which is the same as $s^-1^$. When useful, it can \
                    be represented in any $time^-1^$ unit, for example $week^-1^$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero Order",
                        explanation: """
                        Units for the rate constant are $M^(1-n)^/s$ where n is the order. When \
                        n = 0, $M^(1-0)^/s = M/s$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second Order",
                        explanation: """
                        Units for the rate constant are $M^(1-2)^/s$ where n is the order. When \
                        n = 0, $M^(1-2)^/s = 1/M \\* s$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It depends",
                        explanation: """
                        The units of k do depend on which order the reaction is, but for each type \
                        of reaction there are predetermined k units.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                The rate constant of a first order reaction is $0.0042/hours$. Which of the \
                following is the half-life of the reaction in days?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Almost 7 days",
                    explanation: """
                    The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. \
                    If k is $0.0042 h^-1^$, we only need to replace it: \
                    $t_1/2_ = ln(2)/0.0042 h^-1^ = 165 hours$. To get that time in days, we \
                    convert it: $165 hours \\* (1 day/24 hours) = 6.9 days$ which is almost the \
                    same 7 days.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Almost 6 days",
                        explanation: """
                        6 days is not enough time for the reactant to be halved from its initial \
                        value.
                        """
                    ),
                    QuizAnswerData(
                        answer: "4 days",
                        explanation: """
                        4 days is not even nearly enough time for the reactant to be halved from \
                        its initial value.
                        """
                    ),
                    QuizAnswerData(
                        answer: "8 days",
                        explanation: """
                        After 8 days there would be less than half of the reactant remaining.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                For a reaction $(A to B)$, if a graph plotted with axis $[A] vs t$ produces a \
                curved line, what is the order of the equation and what is the slope of the line?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Any of the above except for zero order reaction",
                    explanation: """
                    For a [A] vs t graph, if the resultant line is a curved line, the reaction can \
                    be either first or second order, or any order whatsoever except for zero.
                    """,
                    position: .D
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order reaction",
                        explanation: """
                        A [A] vs t graph, the resultant line is a straight line for zero order \
                        reactions.
                        """
                    ),
                    QuizAnswerData(
                        answer: "First order reaction",
                        explanation: """
                        A [A] vs t graph will result in a curved line for first order reactions, \
                        but it doesn't mean necessarily that it is a first order reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order reaction",
                        explanation: """
                        A [A] vs t graph will result in a curved line for second order reactions, \
                        but it doesn't mean necessarily that it is a second order reaction.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                3/4 of a substance that's 100% composed by Sodium-24 decays in 30 hours, what is \
                the half-life of Sodium-24?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "15 hours",
                    explanation: """
                    The radioactive decay is a first order process. Given the data, using first \
                    order equation (where A is just Sodium-24 in this case):

                    $[A] = [A_0_]e-^kt^$.

                    After 30 hours, the remaining of Sodium-24 is 25% (100% - 75%) of the initial \
                    value, or 0.25[A_0_].

                    Replacing in the equation: $[A_0_]e^-k(30)^ = 0.25[A_0_]$. Applying natural \
                    log to each side we get: $ln([A_0_]e^-k(30)^) = ln(0.25[A_0_])$.

                    Using logarithmic properties:

                    $ln([A_0_]) + ln(e-^k(30)^) = ln[0.25A_0_]$ ➝
                    $ln([A_0_]) - k(30) = ln(0.25[A_0_])$.

                    Clearing for k:

                    $k = ln[A_0_] - ln(0.25[A_0_]) / 30$ ➝
                    $k = ln([A_0_]/0.25[A_0_]) / 30 = k$ ➝
                    $ln(1/0.25) / 16 = k$

                    we get $k = 0.0462 h^-1^$. Now to determine half-life, we use the half-life \
                    equation $t_1/2_ = ln(2) / 0.0462 h^-1^ = 15 hours$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "4 hours",
                        explanation: """
                        Given that data, after 4 hours would not be enough to reduce the reactant \
                        to half of its initial concentration.
                        """
                    ),
                    QuizAnswerData(
                        answer: "18 hours",
                        explanation: """
                        Given that data, after 18 hours there would be less than half of the \
                        initial concentration of the reactant left.
                        """
                    ),
                    QuizAnswerData(
                        answer: "24 hours",
                        explanation: """
                        Take into account that the radioactive decay is a first order process. \
                        After 24 hours, the remaining of Sodium-24 is (100% - 75%) 25% of the \
                        initial value, or 0.25[A_0_].
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                The graph below shows the results of a study of the reaction with reactants A (in \
                excess) and B. The concentrations of A and B were measured periodically over time \
                for a few hours. According to the results, which of the following can be concluded \
                about the rate law for the reaction under the conditions studied?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "It is first order in [B]",
                    explanation: """
                    B can be inferred to be of first order by looking at how the concentration of \
                    it changed from 0.40 to 0.20 in 2 hours ($0.10 M/h$) and then from 0.20 to \
                    0.10 in 2 hours ($0.05 M/h$). That means that on average the rate was halved \
                    when the concentration of B was halved too.

                    To confirm this, you can apply first order equations of \
                    $k = ln[A_0_] - ln[A] / t$ to calculate k using the data for each point, which \
                    will result in the same k value, making it linear when plotting $ln[A] vs t$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "It is zero order in [B]",
                        explanation: """
                        B cannot be of zero order because the concentration changes at a variable rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It is second order in [B]",
                        explanation: "B data doesn't align with second order equations."
                    ),
                    QuizAnswerData(
                        answer: "It is first order in [A]",
                        explanation: """
                        A is in so much excess that it's concentration within the graph is \
                        apparently unchanged, so this would be false.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium,
                image: "first-order-a-b-concentration"
            ),
            QuizQuestionData(
                question: """
                The table below experimental kinetics data extracted from this reaction:

                C_a_Cl_2_(aq) + 2A_g_NO_3_(aq) ➝ C_a_(NO_3_)_2_(aq) + 2A_g_Cl(s)

                What is the rate law equation?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "Rate = k[C_a_Cl_2_][A_g_NO_3_]",
                    explanation: """
                    When $[C_a_Cl_2_]$ goes from 0.025 to 0.050 (it's doubled, goes up by a factor \
                    of 2), the rate goes from $8.33x10^-4^$ to $1.66x10^-3^$ (it's doubled, goes \
                    up by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first order \
                    for $[C_a_Cl_2_]$.

                    When $[A_g_NO_3_]$ goes from 0.025 to 0.050 (it's doubled, goes up up by a \
                    factor of 2), the rate goes from $1.66x10^-3^$ to $3.33x10^-3^$ (it's doubled, \
                    it goes up by a factor of 2). $2^x^ = 2$ where $x = 1$; the reaction is first \
                    order for $[AgNO_3_]$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Rate = k[C_a_Cl_2_]^2^[A_g_NO_3_]^0^",
                        explanation: """
                        When $[C_a_Cl_2_]$ goes from 0.025 to 0.050 (it's doubled, goes up by a \
                        factor of 2) the rate goes from $8.33x10^-4^$ to $1.66x10^-3^$ (it's \
                        doubled, goes up by a factor of 2). $2^x^ = 2$ where x = 1; the reaction \
                        is first order for $[C_a_Cl_2_]$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[C_a_Cl_2_]^1^[A_g_NO_3_]^0^",
                        explanation: """
                        When the concentration of $[A_g_NO_3_]$ changes from 0.025 M to 0.050 M, \
                        the rate also changes, so the reaction cannot be zero order for \
                        $[A_g_NO_3_]$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate = k[C_a_Cl_2_]^2^[A_g_NO_3_]^2^",
                        explanation: """
                        When $[A_g_NO_3_]$ goes from 0.025 to 0.050 (it's doubled, goes up up by a \
                        factor of 2) the rate goes from $1.66x10^-3^$ to $3.33x10^-3^$ (it's \
                        doubled, it goes up by a factor of 2). $2^x^ = 2$ where x = 1; the \
                        reaction is first order for $[A_g_NO_3_]$.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy,
                table: QuizTable(
                    rows: [
                        ["[C_a_Cl_2_] (M)", "[AgNO_3_] (M)", "Rate M/s"],
                        [ "0.025", "0.025", "8.33x10^-4^"],
                        ["0.050", "0.025", "1.66x10^-3^"],
                        ["0.050", "0.050", "3.33x10^-3^"]
                    ]
                )
            )
        ]
    )
}
