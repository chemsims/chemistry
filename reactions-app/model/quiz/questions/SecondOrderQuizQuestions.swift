//
// Reactions App
//
  

import Foundation

extension QuizQuestion {

    static let secondOrderQuestions = [
        QuizQuestion(
            question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.178 M^-1^s^-1^. How much time will \
            it take for the concentration of A to drop to 0.21 M considering that the reaction started \
            with 0.84 M?
            """,
            correctAnswer: "20 s",
            otherAnswers: [
                "15 s",
                "10 s",
                "5 s"
            ],
            explanation: """
            The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing k, [A_0_] and the \
            [A] at which it's going to drop, we just solve for time $(t):

            t = (1/[A] - 1/[A_0_])/k$ ➝
            $t = (1/0.21 - 1/0.84)/0.178 = 20 seconds$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.44 M^-1^s^-1^. How much time will it \
            take for the concentration of A to drop to $0.05 M$ considering that the reaction started with \
            $0.54 M$?
            """,
            correctAnswer: "41 s",
            otherAnswers: [
                "37 s",
                "31 s",
                "27 s"
            ],
            explanation: """
            The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing k, [A_0_] and the \
            [A] at which it's going to drop, we just solve for time (t):

            $t = (1/[A] - 1/[A_0_])/k$ ➝
            $t = (1/0.05 - 1/0.54)/0.44 = 41 seconds$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.09 M^-1^s^-1^. How much of A would \
            be remaining after 25 seconds has passed? Considering the initial concentration of A is 0.44 M
            """,
            correctAnswer: "0.22 M",
            otherAnswers: [
                "0.44 M",
                "0.18 M",
                "0.28 M"
            ],
            explanation: """
            The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing k, [A_0_] and the \
            time, we just solve for [A]:

            $[A] = [A_0_]/([A_0_]kt + 1)$ ➝
            $[A] = 0.44/(0.44 \\* 0.09 \\* 25 + 1) = 0.22 M$
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question:"What is the half-life for a first order reaction whose rate constant is 0.02875 h^-1^?",
            correctAnswer: "1 day",
            otherAnswers: [
                "12 hours",
                "36 hours",
                "2 days"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. If k is 0.02875 \
            h^-1^, we only need to replace it: $t_1/2_ = ln(2)/0.02875 h^-1^ = 24 hours$, which is the same \
            as 1 day.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider a reaction (A ➝ B) that has this rate law: $Rate = k[A][B]^2^$. Which of the following \
            concentration ratios would lead to a higher rate of reaction?
            """,
            correctAnswer: "[A] = 0.2 M, [B] = 0.8 M",
            otherAnswers: [
                "[A] = 0.8 M, [B] = 0.2 M",
                "[A] = 0.4 M, [B] = 0.4 M",
                "[A] = 0.5 M, [B] = 0.5 M"
            ],
            explanation: """
            Since the reaction is 2nd order with respect to B (making it the highest order within the \
            reaction), the change of the concentration of this species will affect the rate more than the \
            other species. When [B] is really low, Rate will also be, and on the contrary, if [A] is really \
            high, Rate will also be. This is just a way to infer the answer, but to confirm if this is the \
            case with this reaction, we have the numeric values to replace in the Rate Law equation:

            Rate = (0.2)(0.8)^2^ = 0.128 M/s
            Rate = (0.8)(0.2)^2^ = 0.032 M/s
            Rate = (0.4)(0.4)^2^ = 0.064 M/s
            Rate = (0.5)(0.5)^2^ = 0.125 M/s
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            Rate for radioactive decay remains unchanged regardless of environmental factors. The nuclear \
            waste from large nuclear plants lead to problems worldwide because of this characteristic. What \
            would be an accurate statement regarding radioactive rate laws?
            """,
            correctAnswer: """
            Radioactive rate laws are first order reactions because the rate depends only on the material
            """,
            otherAnswers: [
                """
                Radioactive rate laws are zero order reactions because the rate doesn't depend on the material
                """,
                """
                Radioactive rate laws are second order reactions because the half-life of the substance \
                depends on the interactions of it with other components
                """,
                """
                For radioactive material, the overall rate order cannot be determined for decaying material \
                because it changes when this is bonded to other compounds
                """
            ],
            explanation: """
            Radioactive decay is always a first order process. This is why half-life of it is only dependent \
            on the nature of the substance, creating a problem in which the rate of its decay cannot be sped \
            up
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            According to the steady state approximation, what has to be true to determine the rate law for \
            the reaction that has the following reaction mechanism:

            $(Step 1) 2NO_(g)_ ⇌ N_2_O_2__(g)_$
            $(Step 2) N_2_O_2_ + O_2__(g)_ ➝ 2NO_2__(g)_$
            $Overall 2NO_(g)_ + O_2__(g)_ ➝ 2NO_2__(g)_$

            Take into account that it is not evident that the first elementary step is the rate determining \
            step.
            """,
            correctAnswer:
                "The rate of formation of N_2_O_2_ is equal to the rate of disappearance of N_2_O_2_",
            otherAnswers: [
                "The rate of formation of N_2_O_2_ is equal to the rate of disappearance of NO",
                "The rate of formation of N_2_O_2_ is equal to the rate of formation of NO_2_",
                "The rate of formation of N_2_O_2_ is equal to the rate of disappearance of O_2_"
            ],
            explanation: """
            By the steady state approximation, it is assumed that the concentration of the reaction \
            intermediate stays constant. A reaction intermediate is a species that is formed from the \
            reactants (or preceding intermediates) and reacts further to give the directly observed products \
            of a chemical reaction.

            This intermediate is immediately consumed after its production, which is why it doesn't appear \
            in the overall chemical equation. The reaction intermediate for this reaction is N_2_O_2_, and \
            if its concentration remains constant, that means that the rate of formation of N_2_O_2_ is the \
            same as the rate of disappearance of N_2_O_2_.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            A patient receives medications to treat his allergies. He takes 25 mg of this drug twice a day, \
            with a span of 12 hours in between in order for the drug to be effective. This particular drug \
            is metabolized as a first order process, whose half-life is 8 hours. What would be the rate \
            constant k for the process of metabolization of this drug?
            """,
            correctAnswer: "0.058 h^-1^",
            otherAnswers: [
                "0.039 h^-1^",
                "1.0 mg/h",
                "10 mg \\* h"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. If $t_1/2_$ is 12 \
            hours, we only need to replace it:

            $k = ln(2)/t_1/2_$ ➝ $k = ln(2)/12 = 0.039 h^-1^$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider a reaction: $2A+B+C ➝ 2D$. Based on the table below, what would be the rate law of this \
            reaction?
            """,
            correctAnswer: " Rate = k[A]2[B][C]^3^",
            otherAnswers: [
                "Rate = k[A][B][C]",
                "Rate = k[A][B]^2^[C]^3^",
                "Rate = k[A]^2^[B]^2^[C]"
            ],
            explanation: """
            When [A] goes from 0.002 to 0.004 (it's doubled, goes up by a factor of 2) while B and C remain \
            constant, the Rate goes from X to 4X (it goes up by a factor of 4). $2^x^ = 4$ where $x = 2$; \
            the reaction is second order for [A].

            When [B] goes from 0.004 to 0.002 (it's halved, goes down by a factor of 2) while A and C remain \
            constant, the Rate goes from 8X to 4X (it's halved, it goes down by a factor of 2). $2^x^ = 2$ \
            where $x = 1$; the reaction is first order for [B].

            When [C] goes from 0.002 to 0.004 (it's doubled, goes up by a factor of 2) while A and B remain \
            constant, the Rate goes from 4X to 32X (it goes up by a factor of 8). $2^x^ = 8$ where $x = 3$; \
            the reaction is third order for [C].
            """,
            difficulty: .easy,
            table: QuizTable(
                rows: [
                    ["Experiment number", "[A]", "[B]", "[C]", "Rate of disappearance (M/s)"],
                    ["1", "0.1", "0.1", "0.1", "x"],
                    ["2", "0.2", "0.2", "0.1", "8x"],
                    ["3", "0.2", "0.1", "0.1", "4x"],
                    ["4", "0.2", "0.1", "0.2", "32x"]
                ]
            )
        ),
        QuizQuestion(
            question: """
            What would be the rate law equation for a reaction that follows this reaction mechanism?

            $Step 1 (fast) 2NO_(g)_ ⇌ N_2_O_2__(g)_$
            $Step 2 (slow) N_2_O_2__(g)_ + O_2_ ➝ 2NO_2__(g)_$
            """,
            correctAnswer: "Rate = k[NO]^2^[O_2_]",
            otherAnswers: [
                "Rate = k[NO]^2^",
                "Rate = [NO_2_]^2^/[NO]^2^[O_2_]",
                "Rate = k[N_2_O_2_][O_2_]"
            ],
            explanation: """
            Many reactions proceed from reactants to products through a sequence of reactions (elementary \
            reactions, or steps). This sequence of reactions is called the reaction mechanism. The reaction \
            mechanism for elementary steps or reactions is very simple to write since it's determined by the \
            stoichiometry.

            For example, if we were going to write Step 1's rate law, it would be: $Rate = k[NO]^2^$. `
            Furthermore, the slowest step, in this case Step 2, is also called the rate-determining step, \
            because the overall reaction cannot go faster than the slowest of the steps.

            In other words, the rate for this reaction would be $Rate = k[N_2_O_2_][O_2_]$ but since \
            N_2_O_2_ is only the intermediate, then the actual rate law is: $Rate = k[NO]^2^[O^2^]$.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            Which type of elementary reaction steps would have a higher rate of reaction?
            """,
            correctAnswer: "A reaction with only one reactant",
            otherAnswers: [
                "A reaction that occurs with three reactants",
                "A reaction where two reactants combine",
                "A reaction where two reactants undergo double displacement"
            ],
            explanation: """
            For elementary reactions, the rate is deeply related to the probability of collision of the \
            molecules involved. The more molecules are needed to collide to form products, then the lower \
            would be the probability for a successful collision to take place.

            That's why the reaction with the highest rate would be the one with only one reactant, since it \
            doesn't even need a collision to happen, making it much more probable to occur.
            """,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            The rate of disappearance of bromine is -0.021 $M/s$ in this reaction: \
            $H_2(g)_ + Br_2(g)_ ➝ 2HBr_(aq)_$. What would be rate of formation for HBr?
            """,
            correctAnswer: "0.042 M/s",
            otherAnswers: [
                "-0.021 M/s",
                "0.021 M/s",
                "-0.042 M/s"
            ],
            explanation: """
            The rates of disappearance of reactants and appearance of products can be related to each other \
            based on the stoichiometry of the reaction.

            $Rate = -[ΔH_2_]/Δt = -[ΔBr_2_]/Δt = [ΔHbr]/2Δt$.

            If $[ΔBr_2_]/Δt = -0.021 M/s$, we only have to replace:

            -[ΔBr_2_]/Δt = [ΔHbr]/2Δt ➝
            -2(-0.021) = [ΔHbr]/Δt ➝
            0.042 M/s = [ΔHbr]/Δt.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider the following zero order reaction: $A + B ➝ C + D$. What is the rate law for it?
            """,
            correctAnswer: "Rate = k",
            otherAnswers: [
                "Rate = k[A]x",
                "Rate = k[A][B]",
                "Rate = k[A]x[B]y"
            ],
            explanation: """
            For zero order reactions, the rate is independent of the concentration of the reactants, so the \
            rate law for all zero order reactions is $Rate = k$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            2NO_(g)_ + O_2__(g)_ to NO_2__(g)_

            Given the data collected experimentally in this table about the reaction above, what is the rate \
            law for the reaction?
            """,
            correctAnswer: "Rate = k[NO][O_2_]^2^",
            otherAnswers: [
                "Rate = k[NO][O_2_]",
                "Rate = k[NO]^2^[O_2_]^1^",
                "Rate = k[NO]^2^[O_2_]^2^"
            ],
            explanation: """
            When [NO] goes from 0.15 to 0.30 (it's doubled, goes up by a factor of 2) while O_2_ remain \
            constant, the Rate goes from 8.44x10^-4^ to 1.69x10^-3^ (it goes up by a factor of 2). \
            $2^x^ = 2$ where $x = 1$; the reaction is first order for [NO].

            When [O2] goes from 0.15 to 0.60 (it goes up by a factor of 4) while NO remains constant, the \
            Rate goes from 1.69x10^-3^ to 2.7x10^-2^ (it goes up by a factor of 16). $4^x^ = 16$ where \
            $x = 2$; the reaction is second order for [O_2_].
            """,
            difficulty: .medium,
            table: QuizTable(
                rows: [
                    ["Experiment", "[NO] (M)", "[O_2_] (M)", "Rate M/s"],
                    ["1", "0.15", "0.15", "8.44x10^-4^"],
                    ["2", "0.30", "0.15", "1.69x10^-3^"],
                    ["3", "0.30", "0.60", "2.7x10^-2^"],
                    ["4", "0.002", "0.004", "32X"]
                ]
            )
        ),
        QuizQuestion(
            question: """
            Consider the reaction below:

            $F_2__(g)_ + 2ClO_2__(g)_ ➝ 2FClO_2__(g)_$

            Experiments were performed to determine that its rate law is: $Rate = k[F_2_][ClO_2_]$. Which of \
            the following would be expected?
            """,
            correctAnswer:
                "As the concentration of fluorine gas is doubled, the rate of the reaction would be doubled",
            otherAnswers: [
                """
                As the concentration of fluorine gas is doubled, the rate of the reaction would be quadrupled
                """,
                "As the concentration of fluorine gas is doubled, the rate of the reaction would be halved",
                "As the concentration of fluorine gas is doubled, the rate of the reaction would not change"
            ],
            explanation: """
            According to the rate law equation, the reaction is first order with respect to F_2_, which \
            means that the rate is directly proportional to it. If the concentration of F_2_ is doubled, the \
            rate of the reaction would be doubled too.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider the following graph, what would be the order for that reaction?
            """,
            correctAnswer: "Second Order",
            otherAnswers: [
                "Zero Order",
                "First Order",
                "Third Order"
            ],
            explanation: """
            For this second order reaction, the resultant Integrated Rate Law is $k = (1/[A] – 1/[A_0_])/t$, \
            that’s why a graph plotting $(1/[A] vs t)$ is a straight line \
            $(1/[A](y) = kt(mx) + 1/[A_0_](b))$ with a slope of k.
            """,
            difficulty: .easy,
            image: "second-order-inverse-a"
        ),
        QuizQuestion(
            question: """
            Consider a reaction that's $(A ➝ B)$ when [A] and [B] are doubled, the rate goes up by a factor \
            of eight. The rate law is $Rate = k[A]x[B]^2^$. What's the rate order with respect to [A]?
            """,
            correctAnswer: "First Order",
            otherAnswers: [
                "Second Order",
                "Third Order",
                "Cannot be determined with the given information"
            ],
            explanation: """
            Knowing that the reaction is second order with respect to [B], we know that if it was doubled \
            while [A] remained constant, the rate would have to go up by a factor of 4. When [A] was doubled \
            at the same time, the rate went up by a factor of 8. $X \\* 4 = 8$, where $X = 2$. In other \
            words, doubling [A] made the rate go up by a factor of 2. $2^x^ = 2$ where $x = 1$; the reaction \
            is first order for [A].
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Kinetic data was collected experimentally of the decomposition of A. The concentration of A was \
            measured through time while the reaction was taking place. Based on the data in the table, what \
            would be the order of the reaction?
            """,
            correctAnswer: "The decomposition of A is a second-order reaction",
            otherAnswers: [
                "The decomposition of A is a zero-order reaction",
                "The decomposition of A is a first-order reaction",
                "The decomposition of A is a third-order reaction"
            ],
            explanation: """
            We can give these tables the same treatment as we give to the graphs. Making 3 graphs with the \
            provided data might be a way to find the answer, but to quickly determine the order of the \
            reaction, we can look at the increment in each experiment.

            From 0 to 30 seconds, [A] goes from 10.0 to 7.05 (difference of 2.95), ln[A] goes from 2.30 to \
            1.95 (difference of 0.35) and $1/[A]$ goes from 0.10 to 0.14 (difference of 0.04).

            From 30 to 60 seconds, [A] goes from 7.05 to 4.97 (difference of 2.38), ln[A] goes from 1.95 to \
            1.60 (difference of 0.35) and 1/[A] goes from 0.14 to 0.20 (difference of 0.06).

            The only increment that remained the same in these last 30 seconds as in the first 30 seconds of \
            the reaction is the value for ln[A], which means that the increment is linear, so it's a first \
            order reaction.
            """,
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
        QuizQuestion(
            question: "Consider the following graph, what would be the order for that reaction?",
            correctAnswer: "First Order",
            otherAnswers: [
                "Zero Order",
                "Second Order",
                "Third Order"
            ],
            explanation: """
            For this first order reaction, the resultant Integrated Rate Law is $k = (ln[A_0_] – ln[A])/t$, \
            that’s why a graph plotting $(ln[A] vs t)$ is a straight line \
            $(ln[A](y) = -kt(mx) + ln[A_0_](b)))$ with a slope of -k.
            """,
            difficulty: .easy,
            image: "second-order-ln-a"
        ),
        QuizQuestion(
            question: """
            A first-order reaction $(A to B)$ has a rate constant of 0.6 min^-1^. What fraction of the \
            reactant A would be left after 5 minutes?
            """,
            correctAnswer: "1/20",
            otherAnswers: [
                "1/2",
                "1/4",
                "1/12"
            ],
            explanation: """
            The equation for a first order reaction is $ln[A] = ln[A_0_] - kt$. After 5 minutes have passed, \
            there's a fraction of A remaining, or: $[A] = X[A_0_]$. Replacing we get: \
            $ln(X[A_0_]) = ln[A_0_] - (0.6)(5)$.

            Moving all logarithmic expressions to one side: $(0.6)(5) = ln([A_0_]) - lnX[A_0_]$.

            Using logarithmic properties: $(0.6)(5) = ln([A_0_]/X[A_0_])$. Canceling [A_0_] from the \
            expression and solving numerically: $(3) = ln(1/X)$.

            Applying exponential to both sides: $e^3^ = 1/X$. Finally solving for X: $X = 1/e^3^ = 0.05$, \
            which is the same as 1/20.
            """,
            difficulty: .easy
        )
    ]
}
