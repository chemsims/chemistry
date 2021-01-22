//
// Reactions App
//


import Foundation

extension QuizQuestionsList {
    static let zeroOrderQuestions = QuizQuestionsList(
        questionSet: .zeroOrder,
        [
            QuizQuestionData(
                question: "In which unit is the rate of a reaction written in?",
                correctAnswer:
                    QuizAnswerData(
                        answer: "M/s",
                        explanation: """
                        The rate (or speed) of reaction is related to the change in concentration \
                        (molarity or moles over liter) of either a reactant or product over time \
                        (seconds). The rate then represents the speed of consumption of the \
                        reactants, which is the same as the speed of formation of the products. \
                        The standard units for rate are molarity/seconds $(M/s)$.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "mol/s",
                        explanation: """
                        In some cases the rate could be expressed in terms of moles over time \
                        (seconds), but it's not usually portrayed this way.
                        """
                    ),
                    QuizAnswerData(
                        answer: "g/s",
                        explanation: """
                        For chemical reactions, there is a conservation of moles rather than mass, \
                        so mass as a unit is not so useful in this case.
                        """
                    ),
                    QuizAnswerData(
                        answer: "M/min",
                        explanation: """
                        The rate (or speed) of reaction is related to the change in concentration \
                        (molarity or moles over liter) of either a reactant or product over time. \
                        Even though it's possible to use minutes instead of seconds whenever is \
                        convenient, it's not the usual unit to represent the rate.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                A zero order reaction $(A to B)$ has a rate of 1 $M/s$. It starts with a \
                concentration of A of 10 M, and after 5 seconds, there are 5 M of A left, and 5 M \
                more of A are added. How much time in seconds will it take for the 10 M to fully \
                convert into B?
                """,
                correctAnswer:
                    QuizAnswerData(
                        answer: "10 seconds",
                        explanation: """
                        Given the reaction is of zero order, the rate of 1 $M/s$ will always be \
                        the same. If the reaction started with 10 M of A, and 5 M of A were \
                        consumed after 5 seconds of the reaction, this just means that we can \
                        confirm that in fact the rate of the reaction is 1 $M/s$. With 5 M of A \
                        left, and 5 M more of A added, there are 10 M of A now, and it will take \
                        10 seconds for it to be fully consumed.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "5 seconds",
                        explanation: """
                        If 5 seconds pass, only 5 M of A would be consumed, having 5 M of A still \
                        left to be consumed.
                        """
                    ),
                    QuizAnswerData(
                        answer: "15 seconds",
                        explanation: """
                        All of A would be consumed long before 15 seconds pass.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Cannot know because it depends on the concentration",
                        explanation: """
                        Because it's a zero order reaction, the rate of 1 $M/s$ will remain \
                        constant no matter the concentration of A.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                A zero order reaction $(2A to B)$, has A disappearing at a rate of 1.5 $M/s$. What \
                is the rate of appearance of B?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "0.75 M/s",
                    explanation: """
                    Replacing the equation then we get that: $(1.5 M/s)/2 =$ rate of appearance of \
                    $B ➝ 0.75 M/s =$ rate of appearance of B. In other words, for each 1 M of B \
                    that's being produced, there are 2 M of A that are being consumed.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "-0.75 M/s",
                        explanation: """
                        So -0.75 $M/s$ is not the correct answer because the rate of appearance is \
                        positive. The reason for the rate of disappearance to be positive too, is \
                        that the negative sign (-) is already taken into account within the \
                        expression $-[ΔA]/Δt$.
                        """
                    ),
                    QuizAnswerData(
                        answer:  "1.5 M/s",
                        explanation: """
                        Notice the factor (2) in the denominator, that's because for each 2 moles \
                        of A that are consumed, 1 mole of B is produced. So 1.5 $M/s$ is not the \
                        correct answer because that's the rate of disappearance of A, so in one \
                        second 1.5 M of A are consumed, but in that same second, in order for that \
                        to happen, only half the amount of B is produced.
                        """
                    ),
                    QuizAnswerData(
                        answer: "3 M/s",
                        explanation: """
                        Notice the factor (2) in the denominator and not in the numerator. The \
                        rate of a reaction is based on 1 mole or M, so because of the \
                        stoichiometry of the reaction, the rate of the reaction will be half of \
                        the rate of disappearance of A, so that's why the value 2 is in the \
                        denominator instead of the numerator.
                        """
                    )
                ],
                explanation: """
                The rates of disappearance of reactants and appearance of products can be related \
                to each other based on the stoichiometry of the reaction. \
                $Rate = -[ΔA]/2Δt = [ΔB]/Δt$ where $-[ΔA]/Δt =$ rate of disappearance of A and \
                $[ΔB]/Δt$ = rate of appearance of B.


                """,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                There is a reaction $(4A to B + C)$. The rate of disappearance of A can be written \
                as $rate=-[∆A]/Δt$. This is equivalent to:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "4[ΔB]/Δt",
                    explanation: """
                    Easily enough, if we solve for $-[ΔA]/Δt$ in the equation \
                    $-[ΔA]/4Δt = [ΔB]/Δt$, we get that $-[ΔA]/Δt = 4[ΔB]/Δt$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "-1/4[ΔB]/Δt",
                        explanation: """
                        So $-1/4[ΔB]/Δt$ is not the correct answer because that'd be equivalent to \
                        $[ΔA]/16Δt$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "-[ΔC]/Δt",
                        explanation: """
                        So $-[ΔC]/Δt$ is not the correct answer because that'd be equivalent to \
                        $[ΔA]/4Δt$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "[ΔB]/[Δt]",
                        explanation: """
                        So [ΔB]/Δt is not the correct answer because that'd be equivalent to \
                        $-[ΔA]/4Δt$.
                        """
                    )
                ],
                explanation: """
                The rates of disappearance of reactants and appearance of products can be related \
                to each other based on the stoichiometry of the reaction. \
                $Rate = -[ΔA]/4Δt = [ΔB]/Δt = [ΔC]/Δt$ where $-[ΔA]/Δt =$ rate of disappearance of \
                A and $[ΔB]/Δt =$ rate of appearance of B and $[ΔC]/Δt =$ the rate of appearance \
                of C.


                """,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                A zero order reaction $(A to B)$ started 1 minute ago. A currently has a \
                concentration of 5 M in the solution. After 30 seconds, there are 4 M of A left. \
                Which of the following is the initial concentration of $A ([A_0_])$?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "7 M",
                    explanation: """
                    Since it's a zero order reaction, we can first determine the rate (or k) by \
                    simply: $-ΔC/Δt$. When there were 5 M of A, it was reduced to 4 M in 30 \
                    seconds. In other words, 1 M of A was consumed in 30 seconds. We can replace \
                    in the equation:

                    $Rate = k = -(4M - 5M)/(90s - 60s) = 0.03333 M/s$.

                    The equation for a zero order reaction is: $[A] = [A_0_] - kt$. Now we can use \
                    either data point to solve for $[A_0_]$:

                    $[A_0_] = [A] + kt$ ➝ $[A_0_] = 5 + 0.03333(60) = 7 M$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "5 M",
                        explanation: """
                        It's incorrect, 5 M is the concentration of A after one minute has passed, \
                        so that implies that the reaction started with more than that.
                        """
                    ),
                    QuizAnswerData(
                        answer: "3.5 M",
                        explanation: """
                        It's incorrect, 3.5 M, after 1 minute and a half of the reaction there's \
                        still 4 M of A left, meaning that it's impossible for it to have started \
                        with 3.5 M which is less than that.
                        """
                    ),
                    QuizAnswerData(
                        answer: "2 M",
                        explanation: """
                        It's incorrect, 2 M is a far too little amount of A, it's impossible that \
                        it started with 2 M since A is consuming over time, so if after 1 minute \
                        there's 5 M of A, that means that it must have started with at least more \
                        than that.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: "Rate has the same value as k when:",
                correctAnswer:
                    QuizAnswerData(
                        answer: "The reaction is of zero order",
                        explanation: """
                        For zero order reaction, $rate = k$, meaning that it's constant in units \
                        of $M/s$.
                        """
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The reaction started with double the concentrations of reactants than \
                        products
                        """,
                        explanation: """
                        The ratio of concentration of reactants and products is irrelevant to \
                        whether the k has or doesn't have the same value as the rate.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The reaction is of first order",
                        explanation: """
                        A first order reaction could at some point in time have a rate of \
                        reaction that's the same as k in theory, but the rate is variable and \
                        it'll change quickly depending on the concentration.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Never",
                        explanation: """
                        Wrong, there are some types of reactions where the rate is always equal to \
                        the rate constant k.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "Half-life is the time at which:",
                correctAnswer: QuizAnswerData(
                    answer: "The reactant has halved its concentration",
                    explanation: """
                    Half-life is the time at which the concentration of the reactant is half of \
                    what it initially was when the reaction started. It's just a useful way to \
                    reference the time when $[A] = 0.5[A_0_]$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "The product has doubled its concentration",
                        explanation: """
                        Wrong, this is not the definition of half-life, although this could be \
                        true in the case that the reaction starts with an amount of product that's \
                        half of the initial amount of reactant. This would only apply for \
                        reactions where the reactant and the product are stoichiometrically 1 to \
                        1 in any case.
                        """
                    ),
                    QuizAnswerData(
                        answer: "A zero order reaction is halfway through",
                        explanation: """
                        Wrong, half-life is a concept that applies to all kinds of reactions \
                        (zero, first and second order reactions).
                        """
                    ),
                    QuizAnswerData(
                        answer: "The product has halved its concentration",
                        explanation: """
                        Wrong, the product is being formed rather than being consumed.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                Rate always has the same value regardless of the concentration of the reactants \
                for a particular reaction if:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "It's a zero order reaction",
                    explanation: """
                    For a zero order reaction $rate = k$, which in other words means it's constant. \
                    So the rate of the reaction won't change with the concentration of the reactants.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "It's a first order reaction",
                        explanation: """
                        For a first order reaction $rate = k[A]$, which in other words means that \
                        it varies with the concentration of A or the reactant in question.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It's a second order reaction",
                        explanation: """
                        For a second order reaction rate could be $k[A]^2^$ or $k[A][B]$, which \
                        means that it varies with the concentration of A or both A and B, or the \
                        reactants in question.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Rate is never the same",
                        explanation: "Rate is always the same for some types of reactions."
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                'The speed of a reaction is dependent on the concentration of the reactants' \
                applies for:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "First and second order reactions",
                    explanation: """
                    Speed or rate of a reaction depends on the concentration of the reactants for \
                    all types of reactions except for zero order reactions.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Zero order reactions",
                        explanation: """
                        It doesn't apply for Zero Order reactions, because the speed or rate of \
                        the reaction doesn't depend on the concentration of the reactants, and it \
                        stays constant.
                        """
                    ),
                    QuizAnswerData(
                        answer: "First order reactions",
                        explanation: """
                        It does apply for First Order reactions, because for these $rate = k[A]$. \
                        But it doesn't apply only for these types of reactions.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Second order reactions",
                        explanation: """
                        It does apply for second order reactions, because for these \
                        $rate = k[A]^2^$ or $k[A][B]$. But it doesn't apply only for these types \
                        of reactions.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                A reaction $(A to B)$ started 1 day ago. A currently has a concentration of 10 M \
                in the solution. After 5 hours, there are 8 M of A left. Which of the following is \
                the time at which the concentration of A will be half of what it was at the \
                beginning of the reaction?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "A little more than a day",
                    explanation: """
                    Since it's a zero order reaction, we can first determine the rate (or k) by \
                    simply: $-ΔC/Δt$. When there were 10 M of A, it was reduced to 8 M in 5 hours. \
                    In other words, 2 M of A was consumed in 5 hours. We can replace in the \
                    equation:

                    $Rate = k = -(8M - 10M)/(29 - 24) = 0.4 M/h$.

                    The equation for a zero order reaction is: $[A] = [A_0_] - kt$. Now we can use \
                    either data point to solve for $[A_0_]$:

                    [A_0_] = [A] + kt ➝
                    [A_0_] = 10 + 0.4(24) = 19.6 M

                    Knowing that, the equation for half-life of zero order reaction is: \
                    $t_1/2_ = [A_0_]/2k$. Replacing the values: $t_1/2_ = 19.6/2(0.4) = 24.5 h$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "5 hours",
                        explanation: """
                        The time at which the reactant is half its initial amount is \
                        called half-life. Half-life for zero order equations is \
                        $t_1/2_ = [A_0_]/2k$, so you'd have to first determine what the value of k \
                        is. But we know that in 5 hours, 10 M of A were reduced to 8 M of A, so \
                        only 2 M of A were consumed in that period of time. Since it's a zero \
                        order reaction, the rate is always the same, so if the initial \
                        concentration of A is more than 10 M and after 5 hours only 2 M of A were \
                        consumed, it'd be impossible for 5 hours to be the correct answer.
                        """
                    ),
                    QuizAnswerData(
                        answer: "15 hours",
                        explanation: """
                        The time at which the reactant if half its initial amount is called \
                        half-life. Half-life for zero order equations is $t_1/2_ = [A_0_]/2k$, so \
                        you'd have to first determine what the value of k is. We could easily know \
                        that 15 hours is an unlikely answer because the reaction started 1 day ago \
                        and there are still 10 M of A at some point. Knowing that in 5 hours it \
                        only consumed 2 M, the initial amount of A must have been much larger than \
                        10 M. By that logic, 15 hours would only consume 6 M, which is barely a \
                        little more than half of 10 M.
                        """
                    ),
                    QuizAnswerData(
                        answer: "20 hours",
                        explanation: """
                        The time at which the reactant if half its initial amount is called \
                        half-life. Half-life for zero order equations is $t_1/2_ = [A_0_]/2k$, so \
                        you'd have to first determine what the value of k is. 20 hours would still \
                        not be enough time for the reactant to be consumed until the point it's \
                        half of the amount it started with.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                A reaction $(A to 3B)$ tool place. It started with only A, and it ended up being \
                8 M. Which of the following was the initial concentration of A?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "2.666 M",
                    explanation: """
                    Based on the stoichiometry of the balanced equation, for each 1 M of A that's \
                    consumed, 3 M of B are produced. If after all A was totally consumed, the \
                    product was 8 M of B, that means that a third of that value has to be the \
                    initial concentration of A at the beginning of the reaction. $8/3 = 2.666 M$. \
                    So there were 2.666 M of A when the reaction started.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "8 M",
                        explanation: """
                        This would be true for a reaction that stoichiometrically was 1 to \
                        1, but in this case for each mole of A that's consumed, 3 moles of B are \
                        produced. So if at the end of the reaction there are 8 M of B, it means \
                        that less than that was the initial amount of A.
                        """
                    ),
                    QuizAnswerData(
                        answer: "24 M",
                        explanation: """
                        For each mole of A that's consumed, 3 moles of B are produced. So \
                        if at the end of the reaction there are 8 M of B, it means that less than \
                        that was the initial amount of A, and 24 M is way too much.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Need more info",
                        explanation: "There's enough info give an answer."
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                There is a reaction $(2A to 5B + C)$. The rate of appearance of B can be written \
                as $rate=[ΔB]/Δt$. This is equivalent to:
                """,
                correctAnswer: QuizAnswerData(
                    answer: "-5[ΔA]/2Δt",
                    explanation: """
                    If we multiply the whole expression by 5 to get rid of the denominator, we get \
                    the equation of: $-5[ΔA]/2Δt = [ΔB]/Δt$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "2[ΔC]/5Δt",
                        explanation: """
                        So $2[ΔC]/5Δt$ is not the correct answer because that'd be equivalent to \
                        $2[ΔB]/25Δt$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "-5[ΔC]/Δt",
                        explanation: """
                        So $-5[ΔC]/Δt$ is not the correct answer because that'd be equivalent to \
                        $-[ΔB]/Δt$.
                        """
                    ),
                    QuizAnswerData(
                        answer: "5[ΔA]2/Δt",
                        explanation: """
                        So $5[ΔA]/2Δt$ is not the correct answer because that'd be equivalent to \
                        $-[ΔB]/Δt$.
                        """
                    )
                ],
                explanation: """
                The rates of disappearance of reactants and appearance of products can be related \
                to each other based on the stoichiometry of the reaction. \
                $Rate = -[ΔA]/2Δt = [ΔB]/5Δt = [ΔC]/Δt$.
                """,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "What's another way to write the unit for the rate?",
                correctAnswer:
                    QuizAnswerData(
                        answer: "All of the above",
                        explanation: "They are all M/s written in other forms.",
                        position: .D
                    ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Mol L^-1^ s^-1^",
                        explanation: "Mol L^-1^ s^-1^ is the same as Mol/L \\* s which is M/s."
                    ),
                    QuizAnswerData(answer: "M s^-1^", explanation: "M s^-1^ is the same as M/s."),
                    QuizAnswerData(answer: "Mol/L s", explanation: "Mol/L s is the same as M/s.")
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "The rate constant k has the units of",
                correctAnswer: QuizAnswerData(
                    answer: "It can vary",
                    explanation: """
                    The units of k can vary depending on the order of the reaction. It's normally \
                    determined by: $M^(1-n)^/s$ where n is the order of the reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "s^-1^",
                        explanation: "The units of k are $s^-1^$ only for first order reactions."
                    ),
                    QuizAnswerData(
                        answer: "M/s",
                        explanation: "The units of k are M/s only for zero order reactions."
                    ),
                    QuizAnswerData(
                        answer: "1/s",
                        explanation: """
                        $1/s$ is the same thing as $s^-1^$, and k has those units only for first \
                        order reactions.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "If the rate of a reaction varies, it definitely:",
                correctAnswer: QuizAnswerData(
                    answer: "Is not a zero order reaction",
                    explanation: """
                    For a zero order reaction, $rate = k$, so it's constant. If the reaction \
                    varies, it definitely isn't a zero order reaction.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Is a first order reaction",
                        explanation: """
                        For a first order reaction, the rate varies with the concentration of one \
                        reactant, but that doesn't mean that if the rate varies the reaction is \
                        automatically a first order reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Is a second order reaction",
                        explanation: """
                        For a second order reaction, the rate varies with the concentration of one \
                        or two reactants, but that doesn't mean that if the rate varies, the \
                        reaction is automatically a second order reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "None of the above",
                        explanation: "The answer is one of the above",
                        position: .D
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: """
                A reaction $(A to B)$ has started 12 hours ago. A currently has a concentration of \
                7 M in the solution. After 3 hours, A has been reduced to 5 M. Which of the \
                following is the time at which the concentration of A will be 0?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "22.5 h",
                    explanation: """
                    Since it's a zero order reaction, we can first determine the rate (or k) by \
                    simply: $-ΔC/Δt$. When there were 7 M of A, it was reduced to 5 M in 3 hours. \
                    In other words, 2 M of A was consumed in 3 hours. We can replace in the \
                    equation:

                    $Rate = k = -(5M - 7M)/(15 - 12) = 0.667 M/h$.

                    The equation for a zero order reaction is: $[A]$ = $[A_0_] - kt$. Now we can \
                    use either data point to solve for $[A_0_]$:

                    [A_0_] = [A] + kt ➝ [A_0_] = 7 + 0.667(12) = 15 M.

                    Knowing that, for the whole 15 M we can determine with the same equation how \
                    much time should pass: $t = [A_0_]/k$ ➝ $15/0.667 = 22.5 h$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "11.25 h",
                        explanation: """
                        After 11.25 hours, there would still be around 7.5 M of A left.
                        """
                    ),
                    QuizAnswerData(
                        answer: "20,000 seconds",
                        explanation: """
                        After 20 000 seconds, there would still be around 11.3 M of A left.
                        """
                    ),
                    QuizAnswerData(
                        answer: "15 h",
                        explanation: """
                        After 15 hours, there would still be around 5 M of A left.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: """
                A drug's decomposition follow a zero order kinetics with a rate constant of \
                $0.001 g mL^-1^ month^-1^$. The initial concentration is $100 mg mL^-1^$. Which of \
                the following corresponds to the shelf life (t10%)?
                """,
                correctAnswer: QuizAnswerData(
                    answer: "10 months",
                    explanation: """
                    Using the equation for a zero order reaction: $[A] = [A_0_] - kt$. We want to \
                    know the time at which 10% of [A] has been consumed, or in other words: \
                    $[A] = 0.9[A_0_]$. We also need to adjust the k units for them to be aligned \
                    with the other variables:

                    0.001 g mL^-1^ month^-1^ \\* 1000mg/g = 1 g mL^-1^ month^-1^.

                    Replacing in the equation: $0.9[A_0_] = [A_0_] - t$. Solving for t: \
                    $t = 0.10[A_0_] = 0.10(100) = 10 months$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "5 months",
                        explanation: "After 5 months only 5% of the drug has decomposed."
                    ),
                    QuizAnswerData(
                        answer: "4 months",
                        explanation: "After 4 months only 4% of the drug has decomposed."
                    ),
                    QuizAnswerData(
                        answer: "3 months",
                        explanation: "After 3 months only 3% of the drug has decomposed."
                    )
                ],
                explanation: nil,
                difficulty: .medium
            ),
            QuizQuestionData(
                question: "For a zero order reaction, which of the following is false?",
                correctAnswer: QuizAnswerData(
                    answer: "The half-life may be represented by the expression $t_1/2_ = 0.69 / k$",
                    explanation: """
                    It's false because $t_1/2_ = 0.69/k$ is the half-life equation for first order \
                    reactions. For zero order reactions, $t_1/2_ = [A_0_]/2k$
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: """
                        The rate of degradation is independent of the concentration of the \
                        reactant(s)
                        """,
                        explanation: """
                        It's true, the rate of the reaction is constant regardless of the \
                        concentration of the reactant(s).
                        """
                    ),
                    QuizAnswerData(
                        answer: """
                        A plot of the concentration remaining against time is a straight line with \
                        a gradient of -k
                        """,
                        explanation: """
                        It's true, a graph [A] vs t will result in a straight line for a zero \
                        order reaction.
                        """
                    ),
                    QuizAnswerData(
                        answer: "The units of the rate constant (k) are M/s",
                        explanation: """
                        It's true, for a zero order reaction the rate constant's units are \
                        $M^(1-n)^/s$ and since $n = 0$, $M/s$.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "Which one of the following is the half equation for zero order reactions?",
                correctAnswer: QuizAnswerData(
                    answer: "t_1/2_ = [A_0_]/2k",
                    explanation: """
                    For zero order reactions, the half-life equation is $t_1/2_ = [A_0_]/2k$. \
                    Remember half-life is the time at which $[A] = 0.5[A_0_]$. So replacing in the \
                    equation we get:

                    $[A] = [A_0_] - kt$ ➝
                    $0.5[A_0_] = [A_0_] - kt$ ➝
                    $kt = [A_0_] - 0.5[A_0_]$ ➝
                    $t = 0.5[A_0_]/k$

                    which is the same as $t = [A_0_]/2k$.
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "t_1/2_ = 0.69/k",
                        explanation: """
                        For first order reactions, half-life equation is t1/2 = 0.69/k.
                        """
                    ),
                    QuizAnswerData(
                        answer: "t_1/2_ = 1/[A_0_] \\* 2k",
                        explanation: """
                        For second order reactions, half-life equation is 1/[A_0_]\\*k.
                        """
                    ),
                    QuizAnswerData(
                        answer: "t_1/2_ = ln(2)/k",
                        explanation: """
                        For first order reactions, half-life equation is \
                        $t_1/2_ = ln(2)/k$ which is the same as $t_1/2_ = 0.69/k$.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            ),
            QuizQuestionData(
                question: "Rate always has the units of:",
                correctAnswer: QuizAnswerData(
                    answer: "Concentration / time",
                    explanation: """
                    The rate (or speed) of reaction is related to the change in concentration \
                    (molarity) of either a reactant or product over time (seconds). The rate then \
                    represents the speed of consumption of the reactants or which is the same, the \
                    speed of formation of the products. The standard units for rate are \
                    $molarity/seconds$ ($M/s$).
                    """
                ),
                otherAnswers: [
                    QuizAnswerData(
                        answer: "Concentration \\* time",
                        explanation: """
                        The rate of reaction represents the speed of consumption of \
                        reactants in $M/s$, so concentration \\* time would be M \\* s.
                        """
                    ),
                    QuizAnswerData(
                        answer: "Time / concentration",
                        explanation: """
                        The rate of reaction represents the speed of consumption of \
                        reactants in $M/s$, so time/concentration would be s/M.
                        """
                    ),
                    QuizAnswerData(
                        answer: "It varies",
                        explanation: """
                        The rate constant k units vary, but not the units for the rate \
                        which are always M/s or any concentration/time unit.
                        """
                    )
                ],
                explanation: nil,
                difficulty: .easy
            )
        ]
    )
}
