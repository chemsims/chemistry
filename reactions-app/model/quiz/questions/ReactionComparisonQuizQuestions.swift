//
// Reactions App
//
  

import Foundation

extension QuizQuestion {
    static let reactionComparisonQuizQuestions = QuizQuestionsList([
        QuizQuestion(
            question: """
            The rate at which the reactants disappear is equal to the rate of formation of the products \
            within a chemical system. What ways are there to determine the rate law for a reaction?
            """,
            correctAnswer: QuizAnswer(
                answer: "The rate law must be determined experimentally for each reaction",
                explanation:
                    "This is the correct answer, it has to be experimentally determined for each reaction"
            ),
            otherAnswers: [
                QuizAnswer(
                    answer: "The rate law for most common reactions can be found in a reference table",
                    explanation: "The rate law cannot be found in a reference table"
                ),
                QuizAnswer(
                    answer: "The rate law is always determined by the coefficients of the balanced equation",
                    explanation: """
                    The rate law is only determined by the coefficients of the balanced equation in the case \
                    of elementary single step reactions
                    """
                ),
                QuizAnswer(
                    answer: "The rate law is based on the use of a catalyst",
                    explanation: "The rate law cannot be solely determined by the use of a catalyst"
                )
            ],
            explanation: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            A student conducts an experiment that consists on making 10 mL of a 0.20 M violet solution react \
            with 10 mL of a 0.20 M base solution. After this, the student takes a sample of the resulting \
            solution and places it in a UV-Vis spectrophotometer, records the absorbance and plots some \
            graphs. What is the order of the reaction?
            """,
            correctAnswer: "First Order",
            otherAnswers: [
                "Zero Order",
                "Second Order",
                "Insufficient data"
            ],
            explanation: """
            For this first order reaction, the resultant Integrated Rate Law is $k = (ln[A_0_] – ln[A])/t$, \
            that’s why a graph plotting $(ln[A] vs t)$ is a straight line: \
            $(ln[A](y) = -kt(mx) + ln[A_0_](b)))$ with a slope of -k.
            """,
            difficulty: .easy,
            image: "reaction-comparison"
        ),
        QuizQuestion(
            question: """
            Units for the rate constant vary with the order and the rate law of the equation. For this rate \
            law $Rate = k[A]^3^[B]$ what would be the units for k, the rate constant?
            """,
            correctAnswer: "s^-1^M^-3^",
            otherAnswers: [
                "s^-1^M^-1^",
                "s^-1^M^-2^",
                "s^-1^"
            ],
            explanation: """
            For the rate law equation: $Rate = k[A]^3^[B]$, knowing that concentrations are in units of M, \
            and Rate in $M/s$, you can solve for k:

            $M/s = k(M)^3^(M)$ ➝
            $M/s = kM^4^$ ➝
            $k = M/(M^4^)(s)$ ➝
            $k = 1/(M^3^)(s)$

            which is the same as s^-1^M^-3^.

            A short way to know the units for the rate constant is by using M^(1-n)^/s where n is the \
            overall order of the equation. When $n = 4$, $M^(1-4)^/s = s^-1^M^-3^$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider a reaction: $A + 2B ➝ C$. Based on the table below, what would be the rate law of this \
            reaction?
            """,
            correctAnswer: "Rate = k[A]^2^",
            otherAnswers: [
                "Rate = k[A][B]",
                "Rate = k[A][B]^2^",
                "Rate = k[B]^2^"
            ],
            explanation: """
            When [A] goes from 0.230 to 0.460 (it's doubled, goes up by a factor of 2) while B remains \
            constant, the Rate goes from 0.0042 to 0.0168 (it goes up by a factor of 4). $2^x^ = 4$ where \
            $x = 2$; the reaction is second order for [A].

            When [B] goes from 0.230 to 0.460 (it goes up by a factor of 2) while A remains constant, the \
            Rate remains constant. If the rate doesn't vary with the concentration of B, it means the \
            reaction is zero order for [B].

            Writing the complete rate law equation: $Rate = k[A]^2^$.
            """,
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
        QuizQuestion(
            question: """
            Consider a multi-step reaction. The rate laws for the elementary reactions that are part of the \
            proposed mechanism are given. Which one would probably be the rate-determining step of the \
            overall reaction?
            """,
            correctAnswer: "Rate = k[F]^2^[G]",
            otherAnswers: [
                "Rate = k[A][B]",
                "Rate = k[C][D]",
                "Rate = k[E]^2^"
            ],
            explanation: """
            The rate-determining step would probably be $Rate = k[F]^2^[G]$. Of all the rate laws, this one \
            is of the highest order (third overall) and implies that a successful collision of 3 molecules \
            has to take place for the reaction to occur.

            Since the probabilities of this happening are lower, the chances of this reaction to be slower \
            than the other ones is greater. Being the slowest of all the steps, this would be the \
            rate-determining step.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.11 M^-1^s^-1^. How much time will \
            it take for the concentration of A to drop to 0.43 M considering that the reaction started \
            with 0.50 M?
            """,
            correctAnswer: "3 s",
            otherAnswers: [
                "4 s",
                "5 s",
                "6 s"
            ],
            explanation: """
            The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing k, [A_0_] and the \
            [A] at which it's going to drop, we just solve for time (t):

            $t = (1/[A] - 1/[A_0_])/k$ ➝
            $t = (1/0.43 - 1/0.50)/0.11 = 2.95 seconds$, or roughly 3 seconds.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The rate constant for a second order reaction $(A ➝ B)$ is 0.11 M^-1^s^-1^. How much of A would \
            be remaining after 12 seconds has passed? Considering the initial concentration of A is 0.94 M?
            """,
            correctAnswer: "0.42 M",
            otherAnswers: [
                "0.38 M",
                "0.36 M",
                "0.32 M"
            ],
            explanation: """
            The equation for a second order reaction is $1/[A] = 1/[A_0_] + kt$. Knowing k, [A_0_] and the \
            time, we just solve for [A]:

            $[A] = [A_0_]/([A_0_]kt + 1)$ ➝
            $[A] = 0.94/(0.94 \\* 0.11 \\* 12 + 1) = 0.42 M$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            For the reaction below, what would the rate law be?

            2CH_3_OH(g) + 3O_2_(g) ➝ 2CO_2_(g) + 4H_2_O(g)
            """,
            correctAnswer: QuizAnswer(
                answer: "Rate = k[CH_3_OH]^x^[O_2_]y",
                explanation:"""
                Rate = k[CH_3_OH]^x^[O2]^y^ is correct because there's no way to know the exponents without \
                more information. The rate law has to be determined experimentally for each reaction.
                """
            ),
            otherAnswers: [
                QuizAnswer(
                    answer: "Rate = k[CH_3_OH][O_2_]",
                    explanation: """
                    Rate = k[CH_3_OH][O_2_] assumes that the reaction is first order for each reactant \
                    without any information to back it up.
                    """
                ),
                QuizAnswer(
                    answer: "Rate = k[CH_3_OH][O_2_]^2^",
                    explanation: """
                    Rate = k[CH_3_OH]^x^[CO]^y^ has a product as an element for the equation, which is \
                    incorrect.
                    """
                ),
                QuizAnswer(
                    answer: "Rate = k[CH_3_OH]^2^[O_2_]^3^",
                    explanation: """
                    Rate = k[CH_3_OH]^2^[O_2_]^3^ assumes that the coefficients are the exponents for the \
                    equation, which would only be true if it was an elementary single step reaction, which \
                    rarely is the case.
                    """
                )
            ],
            explanation: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            Based on the information below, what is the constant rate for the reaction?

            The table below shows recorded concentration data for the following reaction:
            """,
            correctAnswer: "Rate = k[NO]^2^[Br_2_]",
            otherAnswers: [
                "Rate = k[NO][Br_2_]",
                "Rate = k[NO][Br_2_]^2^",
                "Rate = k[NO]^2^[Br_2_]^2^"
            ],
            explanation: """
            When [Br_2_] goes from 0.0132 to 0.0264 (it's doubled, goes up by a factor of 2) the Rate goes \
            from 4.30x10^-4^ to 8.55x10^-44^ (approximately double, it goes up by a factor of 2). $2^x^ = 2$ \
            where $x = 1$; the reaction is first order for [Br_2_].

            When [Br_2_] drops to 0.0066, if [NO] were maintained at 0.0176, then we could determine that \
            the Rate would have been 2.15x10^-4^ (half of 4.30x10^-4^) since we know it's of first order for \
            [Br_2_].

            In order for the Rate to be 8.60x10^-4^ when [NO] goes from 0.0176 to 0.0352 (it's doubled, goes \
            up by a factor of 2), it had to be quadrupled (go up by a factor of 4). $2^x^ = 4$. where \
            $x = 2$; the reaction is of second order for [NO].
            """,
            difficulty: .medium,
            table: QuizTable(
                rows: [
                    ["[NO] (M)", "[Br_2_]", "NOBr rate of appearance M/s"],
                    ["0.0176", "0.0132", "4.30x10^-4^"],
                    ["0.0176", "0.0264", "8.55x10^-4^"],
                    ["0.0352", "0.0066", "8.60x10^-4^"]
                ]
            )
        ),
        QuizQuestion(
            question: """
            Based on the information below, what is the constant rate for the reaction?

            The table below shows recorded concentration data for the following reaction:
            """,
            correctAnswer: "106 M^-2^s^-1^",
            otherAnswers: [
                "106 s^-1^",
                "55 M s^-1^",
                "55 M^-2^s^-1^"
            ],
            explanation: """
            The Rate Law for this reaction can be determined as $Rate = k[NO]^2^[Br_2_]$, so by replacing \
            the values using the data we get:

            $4.30x10^-4^ = k(0.0176^2^)(0.0132)$.

            Clearing for k:
            $k = (4.30x10^-4^)/((0.0176^2^)(0.0132)) = 106 M^-2^ s^-1^$
            """,
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
        QuizQuestion(
            question: """
            Based on the information below, how would you write the Rate Law equation for this reaction? \
            Take into account that the reaction is of third order for [H^+^]

            The table below shows recorded concentration data for the following reaction:

            8H^+^ + 4Cl^-^ + M_n_O^-^_4_ ➝ 2Cl_2_ + Mn^2+^ + 4H_2_O
            """,
            correctAnswer: "Rate = k[Cl^-^]^2^[MnO_4_][H^+^]^3^",
            otherAnswers: [
                "Rate = k[Cl^-^]^3^[MnO_4_]^2^[H^+^]^3^",
                "Rate = k[Cl^-^]^2^[MnO_4_]^2^[H^+^]^3^",
                "Rate = k[Cl^-^][MnO_4_][H^+^]^3^",
            ],
            explanation: """
            When [Cl^-^] goes from 0.0125 to 0.0375 (it's tripled, goes up by a factor of 3) the Rate goes \
            from 3.9x10^-13^ to 3.51x10^-12^ (nine times higher, it goes up by a factor of 9). $3^x^ = 9$ \
            where $x = 2$; the reaction is second order for [Cl^-^].

            When [MnO4^-^] goes from 0.0096 to 0.0048 (it's halved, goes up down by a factor of 2) the Rate \
            goes from 3.51x10^-12^ to 1.76x10^-12^ (it's halved, it goes down by a factor of 2). $2^x^ = 2$ \
            where $x = 1$; the reaction is first order for [MnO_4_^-^].
            """,
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
        QuizQuestion(
            question: """
            The Rate Law for a reaction $A + B ➝ C$ has been determined: $Rate = k[A]^2^[B]^3^$. Which of \
            the following is the overall order of the reaction?
            """,
            correctAnswer: "Fifth overall",
            otherAnswers: [
                "Second overall",
                "Third overall",
                "Fourth overall"
            ],
            explanation: """
            The reaction is second order in respect to A and third order in respect to B. It is said then \
            that since $2 + 3 = 5$, the reaction is of fifth order overall.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Consider the following mechanism for a reaction:

            A + B ➝ I (fast)
            I + A ➝ C + D (slow)

            Which is the rate law equation for the reaction?
            """,
            correctAnswer: "Rate = k[A]^2^[B]",
            otherAnswers: [
                "Rate = k[A][B]",
                "Rate = k[I][A]",
                "Rate = k[A][B][I]"
            ],
            explanation: """
            Many reactions proceed from reactants to products through a sequence of reactions (elementary \
            reactions, or steps). This sequence of reactions is called the reaction mechanism. The reaction \
            mechanism for elementary steps or reactions is very simple to write since it's determined by the \
            stoichiometry.

            For example, if we were going to write Step 1's rate law, it would be: $Rate = k[A][B]$. \
            Furthermore, the slowest step, in this case Step 2, is also called the rate-determining step, \
            because the overall reaction cannot go faster than the slowest of the steps.

            In other words, the rate for this reaction would be $Rate = k[I][A]$ but since I is only the \
            intermediate, then the actual rate law is: $Rate = k[A]^2^[B]$.
            """,
            difficulty: .hard
        ),
        QuizQuestion(
            question: """
            Consider an elementary reaction whose rate law is: $Rate = k[A]^2^[B]^2^$. Which are the \
            reactants of the balanced reaction?
            """,
            correctAnswer: "2A + 2B",
            otherAnswers: [
                "A + B",
                "A^2^ + B^2^",
                "The coefficients of the rate law are unrelated to the reactants in the balanced equation"
            ],
            explanation: """
            Just for elementary reactions like this, the coefficients of the balanced equation are in fact \
            the exponents of the concentration elements in the rate law equation. In this case since A and B \
            both have exponents of 2, then the coefficients in the balanced equations are 2 too: $2A + 2B$.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            What would be true about the order of a reaction?
            """,
            correctAnswer: QuizAnswer(
                answer: "Reaction order can only be determined by experiment",
                explanation:
                    "The correct answer is that the reaction order can only be determined experimentally"
            ),
            otherAnswers: [
                QuizAnswer(
                    answer: "Reaction order can only be a whole number",
                    explanation: """
                    For high school chemistry, most common reactions studied are of second order, first \
                    order, half order and zero order, that already means that it is not mandatory for the \
                    order of a reaction to be a whole number.
                    """
                ),
                QuizAnswer(
                    answer: """
                    Reaction order can be determined only by the coefficients of the balanced equation for \
                    the reaction
                    """,
                    explanation: """
                    Reaction order can be determined by the coefficients of the balanced equations only in \
                    the case of elementary single step reactions
                    """
                ),
                QuizAnswer(
                    answer: "Reaction order increases with increasing temperature",
                    explanation: """
                    Increasing the temperature does result in an increase of the rate of the reaction, but \
                    it doesn't affect the order of the reaction
                    """
                )
            ],
            explanation: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            question: """
            The rate of which type of reaction would remain the same if it was taking place within a closed \
            container at standard conditions and the concentrations of all reactants were doubled at the \
            same time?
            """,
            correctAnswer: "Zero Order",
            otherAnswers: [
                "First Order",
                "Second Order",
                "Third Order"
            ],
            explanation: """
            For a zero order reaction $Rate = k$, which in other words means it's constant. So the rate of \
            the reaction won't change with the concentration of the reactants.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Calculating the rate constant only knowing the half-life of a reaction, is only possible for \
            which type of reaction?
            """,
            correctAnswer: "First Order",
            otherAnswers: [
                "Zero Order",
                "Second Order",
                "Third Order"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$, meaning that we \
            only need to know the rate constant to calculate the half-life and vice-versa.
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The half-life of a first order reaction $(A ➝ B)$ is equal to 198 seconds. What percentage of \
            the reactant would be left after 390 seconds have passed?
            """,
            correctAnswer: "25.5%",
            otherAnswers: [
                "12%",
                "15.5%",
                "0.98%"
            ],
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
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            The half-life of a first order reaction $(A ➝ B)$ is equal to 232 seconds. What percentage of \
            the reactant would be left after 490 seconds have passed?
            """,
            correctAnswer: "23.1%",
            otherAnswers: [
                "15.5%",
                "25.5%",
                "3.78%"
            ],
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
            """,
            difficulty: .easy
        ),
        QuizQuestion(
            question: """
            Considering that radioactive decay is a first order process: half-life for the decay of I-131 \
            is 8 days, while for ruthenium-106 is 1 year. Which of the following statements would be correct?
            """,
            correctAnswer: """
            The rate constant for the decay of I-131 is greater to the rate constant for the decay of \
            ruthenium-106.
            """,
            otherAnswers: [
                """
                The rate constant for the decay of I-131 is equal to the rate constant for the decay of \
                ruthenium-106
                """,
                """
                The rate constant for the decay of I-131 is lower to the rate constant for the decay of \
                ruthenium-106
                """,
                "It's not possible to compare both rate constants with the given information"
            ],
            explanation: """
            The equation for half-life for a first order reaction is $t_1/2_ = ln(2)/k$. Solving for k, we \
            get: $k = ln(2) / t_1/2_$. The higher the half-life is, the smaller the rate constant k is.

            For ruthenium-106, its massively big half-life of 1 year is much greater than the 8 days \
            half-life of I-131 decay, making the ruthenium-106 rate constant much smaller.
            """,
            difficulty: .medium
        ),
    ])
}
