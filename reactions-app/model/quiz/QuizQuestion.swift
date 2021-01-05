//
// Reactions App
//


import Foundation

/// Definition of a quiz question.
///
/// A correct answer, and a number of incorrect answers are provided. Note that any number of incorrect answers can be provided, however they must
/// not exceed the maximum allowable number of options (as defined by the length of QuizOption).
///
/// Usage
/// =====
/// The simplest way to create a quiz question is to use String literals, since most parameters can be expressed as a String.
/// For example,
/// ```
/// QuizQuestion(
///   question: "What is 1 + 1?",
///   correctAnswer: "2",
///   otherAnswers: ["1", "3", "4"],
///   explanation: "1 + 1 is always equal to 2",
///   difficulty: .easy
/// )
/// ```
///
/// Answer Order
/// ============
/// Answers are displayed in a random order by default. It is possible to assign an explicit position to an answer.
/// Two answers should not share the same position, and a runtime assertion will prevent this.
///
/// For example,
/// ```
/// QuizQuestion(
///     question: "Which numbers are less than 5?",
///     correctAnswer: QuizAnswer(answer: "All of the above", explanation: nil, position: QuizOption.D),
///     otherAnswers: ["1", "2", "3"],
///     explanation: "1, 2 and 3 are all less than 5",
///     difficulty: .easy
/// )
/// ```
///
/// Explanations
/// ============
/// There are two types of explanation available.
///  1. Those associated with the entire question
///  2. Those associated with a particular answer
///
/// Both types of explanation are optional, and any combination can be provided.
///
/// Below is an example using a single explanation for the entire question.
/// ```
/// QuizQuestion(
///     question: "What is tallest mountain in the world?",
///     correctAnswer: "Mount Everest",
///     otherAnswers: ["Mount Blanc", "Mount Fuji"],
///     explanation: "Mount Everest is 8,849m tall, which is the tallest in the world.",
///     difficulty: .medium
/// )
/// ```
///
/// Below is an example with a different explanation for each answer
/// ```
/// QuizQuestion(
///     question: "What is the largest country in the world?",
///     correctAnswer: QuizAnswer("Russia", "The area of Russia is 17.1 million square km which is the largest in the world"),
///     otherAnswers: [
///         QuizAnswer("Canada", "The area of Canada is 10 million square km"),
///         QuizAnswer("USA", "The area of USA is 9.8 million square km")
///     ],
///     explanation: nil,
///     difficulty: .hard
/// )
/// ```
struct QuizQuestion {
    let question: TextLine
    let correctAnswer: QuizAnswer
    let otherAnswers: [QuizAnswer]
    let explanation: TextLine?
    let difficulty: QuizDifficulty
    let image: String?
    let table: QuizTable?

    init(
        question: TextLine,
        correctAnswer: QuizAnswer,
        otherAnswers: [QuizAnswer],
        explanation: TextLine?,
        difficulty: QuizDifficulty,
        image: String? = nil,
        table: QuizTable? = nil
    ) {
        self.question = question
        self.correctAnswer = correctAnswer
        self.otherAnswers = otherAnswers
        self.explanation = explanation
        self.difficulty = difficulty
        self.image = image
        self.table = table
    }

    func randomDisplay() -> QuizQuestionDisplay {
        assert(otherAnswers.count < QuizOption.allCases.count)
        let protectedOptions = Set(([correctAnswer] + otherAnswers).compactMap(\.position))
        var options = QuizOption.allCases.filter { !protectedOptions.contains($0) }
        var answers = [QuizOption: QuizAnswer]()

        func add(_ answer: QuizAnswer, _ option: QuizOption) {
            assert(answers[option] == nil)
            options = options.filter { $0 != option }
            answers[option] = answer
        }

        let correctOption = correctAnswer.position ?? options.randomElement()!
        add(correctAnswer, correctOption)

        otherAnswers.forEach { answer in
            let option = answer.position ?? options.randomElement()!
            add(answer, option)
        }

        return QuizQuestionDisplay(
            question: question,
            options: answers,
            correctOption: correctOption,
            explanation: explanation,
            difficulty: difficulty,
            image: image,
            table: table
        )
    }
}

struct QuizQuestionDisplay {
    let question: TextLine
    let options: [QuizOption:QuizAnswer]
    let correctOption: QuizOption
    let explanation: TextLine?
    let difficulty: QuizDifficulty
    let image: String?
    let table: QuizTable?

    var hasExplanation: Bool {
        explanation != nil
    }

    func hasExplanation(option: QuizOption) -> Bool {
        options[option]?.explanation != nil
    }

    var longExplanation: [TextLine] {
        var explanations = [TextLine]()
        if let explanation = explanation {
            explanations.append(explanation)
        }

        options.keys.sorted().forEach { option in
            if let answer = options[option], let explanation = answer.explanation {
                let optionSegment = TextSegment(content: "\(option.rawValue))", emphasised: true)
                let answerSegment = answer.answer.content.map { $0.setEmphasised(true) }
                let newLineSegment = TextSegment(content: "\n", emphasised: false)
                let explanationSegment = explanation.content.map { $0.setItalic(true) }
                let segments: [TextSegment] = [optionSegment] + answerSegment + [newLineSegment] + explanationSegment
                explanations.append(TextLine(content: segments))
            }
        }
        return explanations
    }
}

struct QuizAnswer: ExpressibleByStringLiteral {
    let answer: TextLine
    let explanation: TextLine?
    let position: QuizOption?

    init(answer: TextLine, explanation: TextLine? = nil, position: QuizOption? = nil) {
        self.answer = answer
        self.explanation = explanation
        self.position = position
    }

    init(stringLiteral value: String) {
        self.init(answer: TextLine(stringLiteral: value), explanation: nil)
    }
}
