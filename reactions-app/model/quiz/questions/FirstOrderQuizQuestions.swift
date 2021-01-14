//
// Reactions App
//
  

import Foundation

extension QuizQuestion {
    static let firstOrderQuestions = QuizQuestionsList([
        QuizQuestion(
            question: "If a reaction is of first order, it means the Rate is dependent on:",
            correctAnswer: "The concentration of one reactant",
            otherAnswers: [
                "The concentration of two or more reactants",
                "It depends",
                "It doesn't depend on anything"
            ],
            explanation: """
            If the overall order of the reaction is 1, that means that the rate of the reaction depends on \
            the concentration of the reactant, given its rate law: $Rate=k[A]$
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: "If the rate law for a reaction is $Rate=k[A]$, what order is the reaction?",
            correctAnswer: "First Order",
            otherAnswers: [
                "Zero Order",
                "Second Order",
                "It depends"
            ],
            explanation: "The rate law for first order reactions is $Rate=k[A]$ where A is the reactant",
            difficulty: .easy
        ),
        QuizQuestion(
            question: "Rate constant k for a first order reaction has the units of:",
            correctAnswer: "s^-1^",
            otherAnswers: [
                "M/s",
                "M^2^/s",
                "It depends"
            ],
            explanation: """
            Units for the rate constant are $M^(1-n)^/s$ where n is the order. When $n=0$, $M^(1-1)^/s=1/s$ \
            which is the same as s^-1^
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            If a reaction $(A + B to C)$ is first order for A and zero order for B, how do you write the \
            Rate law for this reaction?
            """,
            correctAnswer: "Rate = k[A][B]^0^",
            otherAnswers: [
                "Rate = k[A][B]",
                "Rate = k[A]^1^[B]^1^",
                "k[A]^1^[B]"
            ],
            explanation: """
            If the reaction is first order for A, that means that its exponent is 1 in the rate law \
            equation. If the reaction is zero order for B, that means that its exponent is 0. \
            $Rate = k[A]$ which is the same $Rate = k[A][B]^0^$
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: "If the rate constant k has the units of days^-1^, what order is the reaction?",
            correctAnswer: "First Order",
            otherAnswers: [
                "Zero Order",
                "Second Order",
                "It depends"
            ],
            explanation: """
            Units for the rate constant are $M^(1-n)^/s$ where n is the order. When $n = 0$, \
            $M^(1-1)^/s = 1/s$ which is the same s^-1^. When useful, it can be represented in any \
            $time^-1^$ unit, for example $days^-1^$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider the reaction A to B. The reaction started a long time ago. After 1 hour, there's only \
            12.5% of the initial amount of A left. What is the rate constant for this reaction?
            """,
            correctAnswer: "0.034667 min^-1^",
            otherAnswers: [
                "0.00057 min^-1^",
                "2.2 h^-1^",
                "0.034667 s^-1^"
            ],
            explanation: """
            The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After an hour passed (or 60 \
            minutes), there's only 12.5% of A remaining, or: $[A] = 0.125[A_0_]$. Replacing we get:

            ln(0.125[A_0_]) = ln[A_0_] - k(1).

            Solving for k, $k = (ln[Ao] - ln(0.125[A_0_]))$.

            Using logarithmic properties:

            k = ln([A_0_]/0.125[A_0_]) ➝
            k = ln(1/0.125) = 2.08 hours^-1^

            which is the same as:
            2.08 hours^-1^ \\* (1 hour/60 mins) = 0.034667 min^-1^.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: "What is false for first order reactions?",
            correctAnswer:
            QuizAnswer(
                answer: "The Concentration vs Time graph for it is a straight line",
                explanation: """
                It's false, a graph of [A] vs t will only result in a straight line for zero order reactions
                """
            ),
            otherAnswers: [
                QuizAnswer(
                    answer: "Rate constant k has the units of $1/time$",
                    explanation: """
                    It's true, units for the rate constant are $M^(1-n)^/s$ where n is the order. When $n=0$ \
                    $M^(1-1)^/s=1/s$ which is the same as s^-1^. Or, whichever measurement of $time^-1^$ \
                    which is the same as $1/time$
                    """
                ),
                QuizAnswer(
                    answer: "Half-life is independent of concentration of the species.",
                    explanation: """
                    It's true, half-life equation is $t_1/2_ = ln(2)/k$ so it doesn't depend on \
                    the initial concentration of the species.
                    """
                ),
                QuizAnswer(
                    answer: "Rate is dependant on the concentration of one reactant",
                    explanation: """
                    It's true, the rate law for first order reactions is $Rate=k[A]$ where A is the \
                    reactant, making the rate dependant on the concentration of it.
                    """
                )
            ],
            explanation: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            question:
                "What is the half-life for a first order reaction whose rate constant is 34.62 $h^-1^$?",
            correctAnswer: "72 s",
            otherAnswers: [
                "12 s",
                "36 s",
                "1 h"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. If k is \
            $34.62 h^-1^$, we only need to replace it in the equation:

            t_1/2_ = ln(2)/34.62 h^-1^ = 0.02 hours.

            To get that time in seconds, we need to convert it:

            0.02 hours \\* (60 mins / 1 hour) \\* (60 seconds / 1 min) = 72 seconds.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider the reaction A to B. The reaction started a long time ago. After a day and a half, \
            there's only 3/5 of the initial amount of A left. What is the rate for this reaction?
            """,
            correctAnswer: "Rate = 0.34 d^-1^ [A]",
            otherAnswers: [
                "Rate = 1.5 d^-1^ [A]",
                "Rate = 0.51 s^-1^ [A]",
                "Rate = 0.34 s^-1^ [A]"
            ],
            explanation: """
            The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After an a day and a half \
            passed (or 1.5 days), there's 3/5 of A remaining, or: $[A] = 0.6[A_0_]$.

            Replacing, we get: $ln(0.6[A_0_]) = ln[A_0_] - k(1.5)$. Solving for \
            $k = (ln[A_0_] - ln(0.6[A_0_]))/1.5$.

            Using logarithmic properties:

            k = ln([A_0_]/0.6[A_0_])/1.5 k = ln(1/0.6)/1.5 = 0.340 d^-1^.

            Since it's a first order equation, according to the rate law we get that: $Rate = 0.340d^-1^[A]$.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            The half-life for a first order reaction is 48s. What was the original concentration if, after 1 \
            minute, the reactant concentration is 0.3 M?
            """,
            correctAnswer: "0.713 M",
            otherAnswers: [
                "0.654 M",
                "1.4 M",
                "0.4 M"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. If t_1/2_ is 48 \
            seconds, we only need to replace it in the equation and solve for \
            $k = ln(2)/48s = 0.0144 seconds^-1^$.

            The equation for a first order reaction is $[A] = [A_0_]e^-kt^$. If we solve for \
            $[A_0_] = [A]/e^-kt^$, we only have to replace the values:

            [A_0_] = 0.3/e^(-0.0144)(60)^ = 0.713 M
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            For a reaction $(A to B)$, if a graph plotted with axis $ln[A] vs t$ produces a straight line, \
            what is the order of the equation, and what is the slope of the line?
            """,
            correctAnswer: "First Order and -k",
            otherAnswers: [
                "Zero Order and -([A_0_] - [A_t_])/(t_0_- t)",
                "Second Order and -ln[A_0_/A_t_]/(t_0_ - t)",
                QuizAnswer(
                    answer: "None of the above",
                    explanation: nil,
                    position: .D
                )
            ],
            explanation: """
            For a $ln[A] vs t$ graph, if the resultant line is a straight line, the reaction is a first \
            order reaction. The equation for the line is $ln[A] = -kt + ln[A_0_]$ where $ln[A] = y$, \
            $t = x$, $-k = m$ (slope) and $ln[A_0_] = b$ (cut in Y axis), making it $y = mx + b$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            If the Rate of a reaction $(A to B)$ is 0.02 $M/s$ when there is 0.01 M of A present, how much \
            of [A] would it take for the Rate to be 0.015 $M/s$ considering it is a first order reaction?
            """,
            correctAnswer: "0.0075 M",
            otherAnswers: [
                "0.075 M",
                "0.01 M",
                "0.015 M"
            ],
            explanation: """
            Following the rate law equation, $Rate = k[A]$. Replacing the first values, and solving for \
            $k = Rate/[A]$ ➝ $k = 0.020 M/s / 0.010 M = 2 s^-1^$.

            So for a Rate of $0.015 M/s$ we just replace and solve for $[A] = Rate/k$ ➝ \
            $[A] = 0.015 M/s / 2 s^-1^ = 0.0075 M$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            If a reaction $(A + B to C)$ is zero order for A and first order for B, how do you write the \
            Rate law for the reaction?
            """,
            correctAnswer: "Rate = k[A]^0^[B]^1^",
            otherAnswers: [
                "Rate = k[A][B]^1^",
                "Rate = k[A]^1^[B]^1^",
                "Rate = k[A][B]^0^"
            ],
            explanation: """
            If the reaction is zero order for A, that means that its exponent is 0 in the rate law equation. \
            If the reaction is first order for B, that means that its exponent is 1. $Rate = k[B]$ which is \
            the same $Rate = k[A]^0^[B]^1^$
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The half-life for a first order reaction is 36 mins. What was the original concentration if, \
            after 52 minutes, the reactant concentration is 0.2 M?
            """,
            correctAnswer: "0.544 M",
            otherAnswers: [
                "0.322 M",
                "1.088 M",
                "0.322 M"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. If $t_1/2_$ is 36 \
            mins, we only need to replace it and solve for k: $k = ln(2)/36mins = 0.0192 mins^-1^$.

            The equation for first order reactions is $[A] = [A_0_]e^-kt^$. If we solve for \
            $[A_0_] = [A]/e^-kt^$, we only have to replace the values: \
            $[A_0_] = 0.2/e^(-0.0192)(52)^ = 0.544 M$
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            If the rate constant k has units of $week^-1^$, what order is the reaction?
            """,
            correctAnswer: "First Order",
            otherAnswers: [
                "Zero Order",
                "Second Order",
                "It depends"
            ],
            explanation: """
            Units for the rate constant are $M^(1-n)^/s$ where n is the order. When $n = 0$, \
            $M^(1-1)^/s = 1/s$ which is the same as $s^-1^$. When useful, it can be represented in any \
            $time^-1^$ unit, for example $week^-1^$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The rate constant of a first order reaction is $0.0042/hours$. Which of the following is the \
            half-life of the reaction in days?
            """,
            correctAnswer: "Almost 7 days",
            otherAnswers: [
                "Almost 6 days",
                "4 days",
                "8 days"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. If k is \
            $0.0042 h^-1^$, we only need to replace it: $t_1/2_ = ln(2)/0.0042 h^-1^ = 165 hours$. \
            To get that time in days, we convert it: $165 hours \\* (1 day/24 hours) = 6.9 days$ which is \
            almost the same 7 days.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            For a reaction $(A to B)$, if a graph plotted with axis $[A] vs t$ produces a curved line, what \
            is the order of the equation and what is the slope of the line?
            """,
            correctAnswer: QuizAnswer(
                answer: "Any of the above except for Zero Order Reaction",
                explanation: nil,
                position: .D
            ),
            otherAnswers: [
                "Zero Order Reaction",
                "First Order Reaction",
                "Second Order Reaction"
            ],
            explanation: """
            For a [A] vs t graph, if the resultant line is a curved line, the reaction can be either first \
            or second order, or any order whatsoever except for zero.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            3/4 of a substance that's 100% composed by 131 I, decays in 16 days. What is the \
            half-life of 131 I?
            """,
            correctAnswer: "8 days",
            otherAnswers: [
                "4 days",
                "6 days",
                "24 days"
            ],
            explanation: """
            The radioactive decay is a first order process. Given the data, using first order equation \
            (where A is just 131 I in this case):

            $[A] = [A_0_]e-^kt^$.

            After 16 days, the remaining of 131 I is 12.5% (100% - 75%) of the initial value, or 0.25[A_0_].

            Replacing in the equation: $[A_0_]e-^k(24)^ = 0.25[A_0_]$. Applying natural log to each side we \
            get: $ln([A_0_]e-^k(16)^) = ln(0.25[A_0_])$.

            Using logarithmic properties:

            $ln([A_0_]) + ln(e-^k(16)^) = ln[0.25A_0_]$ ➝
            $ln([A_0_]) - k(16) = ln(0.25[A_0_])$.

            Clearing for k:

            $k = ln[A_0_] - ln(0.25[A_0_]) / 16$ ➝
            $k = ln([A_0_]/0.25[A_0_]) / 16 = k$ ➝
            $ln(1/0.25) / 16 = k$

            we get $k = 0.08666 d^-1^$. Now to determine half-life, we use the half-life equation \
            $t_1/2_ = ln(2) / 0.08666 d^-1^ = 8 days$.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            The graph below shows the results of a study of the reaction with reactants A (in excess) and B. \
            The concentrations of A and B were measured periodically over time for a few hours. According to \
            the results, which of the following can be concluded about the rate law for the reaction under \
            the conditions studied?
            """,
            correctAnswer: QuizAnswer(
                answer: "It is first order in [B]",
                explanation: """
                B can be inferred to be of first order by looking at how the concentration of it changed \
                from 0.40 to 0.20 in 2 hours ($0.10 M/h$) and then from 0.20 to 0.10 in 2 hours \
                ($0.05 M/h$). That means that on average the Rate was halved when the concentration of B was \
                halved too. To confirm this, you can apply first order equations of \
                $k = ln[A_0_] - ln[A] / t$ to calculate k using the data for each point, which will result \
                in the same k value, making it linear when plotting $ln[A] vs t$.
                """
            ),
            otherAnswers: [
                QuizAnswer(
                    answer: "It is zero order in [B]",
                    explanation:
                        "B cannot be of Zero Order because the concentration changes at a variable rate"
                ),
                QuizAnswer(
                    answer: "It is second order in [B]",
                    explanation: "B data doesn't align with second order equations"
                ),
                QuizAnswer(
                    answer: "It is first order in [A]",
                    explanation: """
                    A is in so much excess that it's concentration within the graph is apparently unchanged, \
                    so this would be false.
                    """
                )
            ],
            explanation: nil,
            difficulty: .medium,
            image: "first-order-a-b-concentration"
        ),
        QuizQuestion(
            question: """
            The table below experimental kinetics data extracted from this reaction:

            C_a_Cl_2_(aq) + 2A_g_NO_3_(aq) ➝ C_a_(NO_3_)_2_(aq) + 2A_g_Cl(s)

            What is the rate law equation?
            """,
            correctAnswer: "Rate = k[C_a_Cl_2_][A_g_NO_3_]",
            otherAnswers: [
                "Rate = k[C_a_Cl_2_]^2^[A_g_NO_3_]^0^",
                "Rate = k[C_a_Cl_2_]^1^[A_g_NO_3_]^0^",
                "Rate = k[C_a_Cl_2_]^2^[A_g_NO_3_]^2^"
            ],
            explanation: """
            When [C_a_Cl_2_] goes from 0.025 to 0.050 (it's doubled, goes up by a factor of 2), the Rate \
            goes from $8.33x10^-4^$ to $1.66x10^-3^$ (it's doubled, goes up by a factor of 2). $2^x^ = 2$ \
            where $x = 1$; the reaction is first order for [C_a_Cl_2_].

            When [A_g_NO_3_] goes from 0.025 to 0.050 (it's doubled, goes up up by a factor of 2), the Rate \
            goes from $1.66x10^-3^$ to $3.33x10^-3^$ (it's doubled, it goes up by a factor of 2). $2^x^ = 2$ \
            where $x = 1$; the reaction is first order for [AgNO_3_].
            """,
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
    ])
}
