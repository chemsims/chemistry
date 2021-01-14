//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let zeroOrderQuestions = QuizQuestionsList(
        [
        QuizQuestion(
            question: "In which unit is the Rate of a reaction written in?",
            correctAnswer: "M/s",
            otherAnswers: [
                "mol/s",
                "g/s",
                "M/min"
            ],
            explanation: """
            The rate (or speed) of a reaction is related to the change in concentration [A_0_] (Molarity) of either \
            a reactant or product over time (seconds). The rate then represents the speed of consumption of \
            the reactants, which is the same as the speed of formation of the products. The standard units \
            for rate are $Molarity/seconds$ ($M/s$).
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            A zero order reaction $(A to B)$ has a rate of 1 $M/s$. It starts with a concentration of A of \
            10 M, and after 5 seconds, there are 5 M of A left, and 5 M more of A are added. How much \
            time in seconds will it take for the 10 M to fully convert into B?
            """,
            correctAnswer: "10 seconds",
            otherAnswers: [
                "5 seconds",
                "15 seconds",
                "Cannot know because it depends on the concentration"
            ],
            explanation: """
                No calculations are needed since there's a lot of data to get the answer from. Given the \
                reaction is of zero order, the rate of 1 $M/s$ will always be the same. If the reaction \
                started with 10 M of A, and 5 M of A were consumed after 5 seconds of the reaction, this \
                just means that we can confirm that in fact the rate of the reaction is 1 $M/s$. With 5 M \
                of A left, and 5 M more of A added, there are 10 M of A now, and it will take 10 seconds \
                for it to be fully consumed.
                """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            A zero order reaction $(2A to B)$, has A disappearing at a Rate of 1.5 $M/s$. What is the rate \
            of appearance of B?
            """,
            correctAnswer: "0.75 M/s",
            otherAnswers: [
                "-0.75 M/s",
                "1.5 M/s",
                "3 M/s"
            ],
            explanation: """
            The rates of disappearance of reactants and appearance of products can be related to each other \
            based on the stoichiometry of the reaction.

            *$Rate = -[ΔA]/2Δt = [ΔB]/Δt$*, where $-[ΔA]/Δt = rate$ of disappearance of A and $[ΔB]/Δt = rate$ \
            of appearance of B. Replacing the equation then we get that: *$(1.5 M/s)/2 = rate$ of appearance \
            of B* ➝ $0.75 M/s = rate$ of appearance of B. In other words, for each M of B that's being \
            produced, there are 2 M of A that are being consumed.

            Note that -0.75 $M/s$ is not the correct answer because the rate of appearance is positive. \
            The reason for the rate of disappearance to be positive too, is that the negative sign (-) is \
            already taken into account within the expression $-[ΔA]/Δt$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            There is a reaction $(4A to B + C)$. The rate of disappearance of A can be written as \
            $Rate=-[∆A]/Δt$. This is equivalent to:
            """,
            correctAnswer: "4[ΔB]/Δt",
            otherAnswers: [
                "-1/4[ΔB]/Δt",
                "-[ΔC]/Δt",
                "[ΔB]/[Δt]"
            ],
            explanation: """
            The rates of disappearance of reactants and appearance of products can be related to each other \
            based on the stoichiometry of the reaction. *$Rate = -[ΔA]/4Δt = [ΔB]/Δt = [ΔC]/Δt$*. If we \
            multiply the whole expression by 4 to get rid of the denominator, we get the equation of: \
            *$-[ΔA]/Δt = 4[ΔB]/Δt$*.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            A zero order reaction $(A to B)$ started 1 minute ago. A currently has a concentration of 5 M \
            in the solution. After 30 seconds, there are 4 M of A left. Which of the following is the \
            initial concentration of $A ([A_0_])$?
            """,
            correctAnswer: "7 M",
            otherAnswers: [
                "5 M",
                "3.5 M",
                "2 M"
            ],
            explanation: """
            Since it's a zero order reaction, we can first determine the Rate (or k) by simply: $-ΔC/Δt$. \
            When there were 5 M of A, it was reduced to 4 M in 30 seconds. In other words, 1 M of A was \
            consumed in 30 seconds. We can replace in the equation:

            *$Rate = k = -(4M - 5M)/(90s - 60s) =$ 0.03333 $M/s$*.

            The equation for a zero order reaction is: $[A] = [A_0_] - kt$. Now we can use either data \
            point to solve for [A_0_]:

            *$[A_0_] = [A] + kt$ ➝ $[A_0_] = 5 + 0.03333(60) = 7 M$*.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: "Rate has the same value as k when:",
            correctAnswer: "The reaction is of zero order",
            otherAnswers: [
                "The reaction started with double the concentrations of reactants than products",
                "The reaction is of first order",
                "Never"
            ],
            explanation:
                "For zero order reactions, $Rate = k$ and it's of course constant, in units of $M/s$.",
            difficulty: .easy
        ),
        QuizQuestion(
            question: "Half-life is the time at which:",
            correctAnswer: "The reactant has halved its concentration",
            otherAnswers: [
                "The product has doubled its concentration",
                "A zero order reaction is halfway through",
                "The product has halved its concentration"
            ],
            explanation: """
            Half-life is the time at which the concentration of the reactant is half of what it initially \
            was when the reaction started. It's just a useful way to reference the time when \
            $[A] = 0.5[A_0_]$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Rate always has the same value regardless of the concentration of the reactants for a particular \
            reaction if:
            """,
            correctAnswer: "It's a zero order reaction",
            otherAnswers: [
                "It's a first order reaction",
                "It's a second order reaction",
                "Rate is never the same"
            ],
            explanation: """
            For a zero order reaction $Rate = k$, which in other words means it's constant. So the rate of \
            the reaction won't change with the concentration of the reactants.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question:
                "'The speed of a reaction is dependent on the concentration of the reactants' applies for:",
            correctAnswer: "First and second order reactions",
            otherAnswers: [
                "Zero order reactions",
                "First order reactions",
                "Second order reactions"
            ],
            explanation: """
            Speed or rate of a reaction depends on the concentration of the reactants for all types of \
            reactions except for zero order reactions.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            A reaction $(A to B)$ started 1 day ago. A currently has a concentration of 10 M in the \
            solution. After 5 hours, there are 8 M of A left. Which of the following is the time at which \
            the concentration of A will be half of what it was at the beginning of the reaction?
            """,
            correctAnswer: "A little more than a day",
            otherAnswers: [
                "5 hours",
                "15 hours",
                "20 hours"
            ],
            explanation: TextLineGenerator.makeLine(
                """
                Since it's a zero order reaction, we can first determine the Rate (or k) by simply: \
                $-ΔC/Δt$. When there were 10 M of A, it was reduced to 8 M in 5 hours. In other words, 2 M \
                of A was consumed in 5 hours. We can replace in the equation:

                *Rate = k = -(8M - 10M)/(29 - 24) = 0.4 M/h*.

                The equation for a zero order reaction is: $[A] = [A_0_] - kt$. Now we can use either data \
                point to solve for [A_0_]:

                *$[A_0_] = [A] + kt$ ➝ $[A_0_] = 10 + 0.4(24) = 19.6 M$*.

                Knowing that, the equation for half-life of zero order reaction is: $t_1/2_ = [A_0_]/2k$. \
                Replacing the values: *$t_1/2_ = 19.6/2(0.4) = 24.5 h$*.
                """
            ),
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            A reaction $(A to 3B)$ tool place. It started with only A, and it ended up being 8 M. Which of \
            the following was the initial concentration of A?
            """,
            correctAnswer: "2.666 M",
            otherAnswers: [
                "8 M",
                "24 M",
                "Need more info"
            ],
            explanation: """
            Based on the stoichiometry of the balanced equation, for each 1 M of A that's consumed, 3 M of B \
            are produced. If after all A was totally consumed, the product was 8 M of B, that means that a \
            third of that value has to be the initial concentration of A at the beginning of the reaction. \
            $8/3 = 2.666M$. There were 2.666 M of A when the reaction started.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            There is a reaction $(2A to 5B + C)$. The rate of appearance of B can be written as \
            $Rate=[ΔB]/Δt$. This is equivalent to:
            """,
            correctAnswer: "-5[ΔA]/2Δt",
            otherAnswers: [
                "2[ΔC]/5Δt",
                "-5[ΔC]/Δt",
                "5[ΔA]2/Δt"
            ],
            explanation: """
            The rates of disappearance of reactants and appearance of products can be related to each other \
            based on the stoichiometry of the reaction.

            Rate = -[ΔA]/2Δt = [ΔB]/5Δt = [ΔC]/Δt.

            If we multiply the whole expression by 5 to get rid of the denominator, we get the equation of: \
            $-5[ΔA]/2Δt = [ΔB]/Δt$
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: "What's another way to write the unit for the rate?",
            correctAnswer:
                QuizAnswer(
                    answer: "All of the above",
                    explanation: "They are all M/s written in other forms",
                    position: .D
                ),
            otherAnswers: [
                QuizAnswer(
                    answer: "Mol L^-1^ s^-1^",
                    explanation: "Mol L^-1^ s^-1^ is the same as Mol/L \\* s which is M/s"
                ),
                QuizAnswer(answer: "M s^-1^", explanation: "M s^-1^ is the same as M/s"),
                QuizAnswer(answer: "Mol/L s", explanation: "Mol/L s is the same as M/s")
            ],
            explanation: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            question: "The rate constant k has the units of",
            correctAnswer: "It can vary",
            otherAnswers: [
                "s^-1^",
                "M/s",
                "1/s"
            ],
            explanation: """
            The units of k can vary depending on the order of the reaction. It's normally determined by: \
            $M^(1-n)^/s$ where n is the order of the reaction.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: "If the rate of a reaction varies, it definitely:",
            correctAnswer: "Is not a zero order reaction",
            otherAnswers: [
                "Is a first order reaction",
                "Is a second order reaction",
                QuizAnswer(answer: "None of the above", explanation: nil, position: .D)
            ],
            explanation: "For a zero order reaction, $Rate = k$, so it's a constant.",
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            A reaction $(A to B)$ has started 12 hours ago. A has currently a concentration of 7 M in the \
            solution. After 3 hours, A has been reduced to 5 M. Which of the following is the time at \
            which the concentration of A will be 0?
            """,
            correctAnswer: "22.5 h",
            otherAnswers: [
                "11.25 h",
                "20,000 seconds",
                "15 h"
            ],
            explanation: """
            Since it's a zero order reaction, we can first determine the Rate (or k) by simply: $-ΔC/Δt$. \
            When there were 7 M of A, it was reduced to 5 M in 3 hours. In other words, 2 M of A was \
            consumed in 3 hours. We can replace in the equation:

            *$Rate = k = -(5M - 7M)/(15 - 12) = 0.667 M/h$*.

            The equation for a zero order reaction is: $[A] = [A_0_] - kt$. Now we can use either data point \
            to solve for [A_0_]:

            *$[A_0_] = [A] + kt$ ➝ $[A_0_] = 7 + 0.667(12) = 15 M$*.

            Knowing that, for the whole 15 M we can determine with the same equation how much time should \
            pass: *$t = [A_0_]/k$ ➝ $15/0.667 = 22.5 h$*.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            A drug's decomposition follow a zero-order kinetics with a rate constant of \
            $0.001 g mL^-1^ month^-1^$. The initial concentration is $100 mg mL^-1^$. Which of the following \
            corresponds to the shelf life (t10%)?
            """,
            correctAnswer: "10 months",
            otherAnswers: [
                "5 months",
                "4 months",
                "3 months"
            ],
            explanation: """
            Using the equation for a zero order reaction: $[A] = [A_0_] - kt$. We want to know the time at \
            which 10% of [A] has been consumed, or in other words: $[A] = 0.9[A_0_]$. We also need to adjust \
            the k units for them to be aligned with the other variables:

            0.001 g mL^-1^ month^-1^ \\* 1000mg/g = 1 g mL^-1^ month^-1^.

            Replacing in the equation: $0.9[A_0_] = [A_0_] - t$. Solving for t: \
            $t = 0.10[A_0_] = 0.10(100) = 10 months$.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: "For a zero order reaction, which of the following is false?",
            correctAnswer: QuizAnswer(
                answer: "The half-life may be represented by the expression $t_1/2_ = 0.69 / k$",
                explanation: """
                It's false because $t_1/2_ = 0.69/k$ is the half-life equation for first order reactions. \
                For zero order reactions, $t_1/2_ = [A_0_]/2k$
                """
            ),
            otherAnswers: [
                QuizAnswer(
                    answer: "The rate of degradation is independent of the concentration of the reactant(s)",
                    explanation: """
                    It's true, the rate of the reaction is constant regardless of the concentration of the \
                    reactant(s)
                    """
                ),
                QuizAnswer(
                    answer: """
                    A plot of the concentration remaining against time is a straight line with a gradient of \
                    -k
                    """,
                    explanation:
                        "It's true, a graph [A] vs t will result in a straight line for a zero order reaction"
                ),
                QuizAnswer(
                    answer: "The units of the rate constant (k) are M/s",
                    explanation: """
                    It's true, for a zero order reaction the rate constant's units are $M^(1-n)^/s$ and \
                    since $n = 0$, $M/s$.
                    """
                )

            ],
            explanation: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            question: "Which one of the following is the half equation for Zero Order reactions?",
            correctAnswer: "t_1/2_ = [A_0_] / 2k",
            otherAnswers: [
                "t_1/2_ = 0.69 / k",
                "t_1/2_ = [A_0_] / 2k",
                "t_1/2_ = ln(2) / k"
            ],
            explanation: """
            For zero order reactions, the half-life equation is $t_1/2_ = [A_0_]/2k$. Remember \
            half-life is the time at which $[A] = 0.5[A_0_]$. So replacing in the equation we get:

            $[A] = [A_0_] - kt$ ➝
            $0.5[A_0_] = [A_0_] - kt$ ➝
            $kt = [A_0_] - 0.5[A_0_]$ ➝
            $t = 0.5[A_0_]/k$

            which is the same as $t = [A_0_]/2k$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: "Rate always has the units of:",
            correctAnswer: "Concentration / time",
            otherAnswers: [
                "Concentration \\* time",
                "Time / concentration",
                "It varies"
            ],
            explanation: """
            The rate (or speed) of reaction is related to the change in concentration (Molarity) of either a \
            reactant or product over time (seconds). The rate then represents the speed of consumption of \
            the reactants or which is the same, the speed of formation of the products. The standard units \
            for rate are $Molarity/seconds$ ($M/s$).
            """,
            difficulty: .easy
        )
    ]
    )
}
