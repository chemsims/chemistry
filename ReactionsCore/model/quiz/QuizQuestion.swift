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
public struct QuizQuestionData {
    let id: String
    let question: TextLine
    let correctAnswer: QuizAnswerData
    let otherAnswers: [QuizAnswerData]
    let difficulty: QuizDifficulty
    let image: LabelledImage?
    let table: QuizTable?

    public init(
        id: String,
        question: String,
        questionLabel: String? = nil,
        correctAnswer: QuizAnswerData,
        otherAnswers: [QuizAnswerData],
        difficulty: QuizDifficulty,
        image: LabelledImage? = nil,
        table: QuizTable? = nil
    ) {
        self.id = id
        self.question = TextLine(question, label: Labelling.stringToLabel(questionLabel ?? question))
        self.correctAnswer = correctAnswer
        self.otherAnswers = otherAnswers
        self.difficulty = difficulty
        self.image = image
        self.table = table
    }

    /// Creates a quiz question
    func createQuestion() -> QuizQuestion {
        assert(otherAnswers.count < QuizOption.allCases.count)
        let protectedOptions = Set(([correctAnswer] + otherAnswers).compactMap(\.position))
        var options = QuizOption.allCases.filter { !protectedOptions.contains($0) }
        var answers = [QuizOption: QuizAnswer]()

        func add(_ answer: QuizAnswerData, _ option: QuizOption, id: String) {
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
        add(correctAnswer, correctOption, id: correctAnswerId)

        otherAnswers.enumerated().forEach { (index, answer) in
            let option = answer.position ?? options.randomElement()!
            add(answer, option, id: "\(incorrectAnswerId)-\(index + 1)")
        }

        return QuizQuestion(
            id: id,
            question: question,
            options: answers,
            correctOption: correctOption,
            difficulty: difficulty,
            image: image,
            table: table
        )
    }
}

/// Definition of a quiz answer
public struct QuizAnswerData: Equatable {
    public let answer: TextLine
    public let explanation: TextLine
    public let position: QuizOption?

    public init(
        answer: String,
        answerLabel: String? = nil,
        explanation: String,
        position: QuizOption? = nil,
        explanationLabel: String? = nil
    ) {
        self.answer = TextLine(
            answer,
            label: Labelling.stringToLabel(answerLabel ?? answer)
        )
        self.explanation = TextLine(
            explanation,
            label: Labelling.stringToLabel(explanationLabel ?? explanation)
        )
        self.position = position
    }
}

/// Internal representation of a quiz question
public struct QuizQuestion: Equatable {
    public let id: String
    public let question: TextLine
    public let options: [QuizOption: QuizAnswer]
    public let correctOption: QuizOption
    public let difficulty: QuizDifficulty
    public let image: LabelledImage?
    public let table: QuizTable?
}

/// Internal representation of a quiz answer
public struct QuizAnswer: Equatable {
    public let answer: TextLine
    public let explanation: TextLine
    public let id: String
}

public struct QuizQuestionsList<QuestionSet> {

    public let questionSet: QuestionSet
    public init(questionSet: QuestionSet, _ questions: [QuizQuestionData]) {
        self.questionSet = questionSet
        self.questions = questions
    }

    let questions: [QuizQuestionData]

    public func createQuestions() -> [QuizQuestion] {
        questions.map { $0.createQuestion() }
    }
}

private let correctAnswerId = "CORRECT-ANSWER"
private let incorrectAnswerId = "INCORRECT-ANSWER"
