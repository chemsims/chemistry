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
/// QuizQuestionData(
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
/// QuizQuestionData(
///     question: "Which numbers are less than 5?",
///     correctAnswer: QuizAnswer(answer: "All of the above", position: QuizOption.D),
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
/// QuizQuestionData(
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
/// QuizQuestionData(
///     question: "What is the largest country in the world?",
///     correctAnswer: QuizAnswerData(
///         "Russia",
///         "The area of Russia is 17.1 million square km which is the largest in the world"
///     ),
///     otherAnswers: [
///         QuizAnswerData("Canada", "The area of Canada is 10 million square km"),
///         QuizAnswerData("USA", "The area of USA is 9.8 million square km")
///     ],
///     explanation: nil,
///     difficulty: .hard
/// )
/// ```
struct QuizQuestionData {
    let question: TextLine
    let correctAnswer: QuizAnswerData
    let otherAnswers: [QuizAnswerData]
    let explanation: TextLine?
    let difficulty: QuizDifficulty
    let image: String?
    let table: QuizTable?

    init(
        question: TextLine,
        correctAnswer: QuizAnswerData,
        otherAnswers: [QuizAnswerData],
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

    /// Creates a quiz question
    func createQuestion(questionId: Int) -> QuizQuestion {
        assert(otherAnswers.count < QuizOption.allCases.count)
        let protectedOptions = Set(([correctAnswer] + otherAnswers).compactMap(\.position))
        var options = QuizOption.allCases.filter { !protectedOptions.contains($0) }
        var answers = [QuizOption: QuizAnswer]()

        func add(_ answer: QuizAnswerData, _ option: QuizOption, id: Int) {
            assert(answers[option] == nil)
            options = options.filter { $0 != option }
            let a2 = QuizAnswer(
                answer: answer.answer,
                explanation: answer.explanation,
                id: id
            )
            answers[option] = a2
        }

        let correctOption = correctAnswer.position ?? options.randomElement()!
        add(correctAnswer, correctOption, id: -1)

        otherAnswers.enumerated().forEach { (index, answer) in
            let option = answer.position ?? options.randomElement()!
            add(answer, option, id: index)
        }

        return QuizQuestion(
            id: questionId,
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

/// Definition of a quiz answer
struct QuizAnswerData: ExpressibleByStringLiteral, Equatable {
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

/// Internal representation of a quiz question
struct QuizQuestion: Equatable {
    let id: Int
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
                let optionSegment = TextSegment(content: "\(option.rawValue)) ", emphasised: true)
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

/// Internal representation of a quiz answer
struct QuizAnswer: Equatable {
    let answer: TextLine
    let explanation: TextLine?
    let id: Int
}

struct QuizQuestionsList {

    init(_ questions: [QuizQuestionData]) {
        self.questions = questions
    }

    private let questions: [QuizQuestionData]

    func createQuestions() -> [QuizQuestion] {
        (0..<questions.count).map { i in
            questions[i].createQuestion(questionId: i)
        }
    }
}
