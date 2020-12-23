//
// Reactions App
//
  

import Foundation

struct QuizQuestion2 {
    let question: TextLine
    let correctAnswer: QuizAnswer
    let otherAnswers: [QuizAnswer]
    let explanation: TextLine?
    let difficulty: QuizDifficulty
}

struct QuizAnswer: ExpressibleByStringLiteral {
    let answer: TextLine
    let explanation: TextLine?
    let position: QuizOption?

    init(answer: TextLine, explanation: TextLine?, position: QuizOption? = nil) {
        self.answer = answer
        self.explanation = explanation
        self.position = position
    }

    init(stringLiteral value: String) {
        self.init(answer: TextLine(stringLiteral: value), explanation: nil)
    }
}


struct QuizQuestion {
    let question: String
    let correctAnswer: String
    let incorrectAnswer1: String
    let incorrectAnswer2: String
    let incorrectAnswer3: String

    var randomOptions: QuizQuestionOptions {
        let correctOption = QuizOption.allCases.randomElement()!
        let otherOptions = QuizOption.allCases.filter { $0 != correctOption }.shuffled()
        let options = [
            correctOption: correctAnswer,
            otherOptions[0]: incorrectAnswer1,
            otherOptions[1]: incorrectAnswer2,
            otherOptions[2]: incorrectAnswer3
        ]
        return QuizQuestionOptions(
            question: question,
            options: options,
            correctOption: correctOption
        )
    }
}

struct QuizQuestionOptions {
    let question: String
    let options: [QuizOption:String]
    let correctOption: QuizOption
}

extension QuizQuestion {

    static var dummyQuestions: [QuizQuestion] {
        (1...20).map { i in
            question(num1: i, num2: i)
        }
    }

    static func question(num1: Int, num2: Int) -> QuizQuestion {
        let correctValue = num1 + num2
        return QuizQuestion(
            question: "What is \(num1) + \(num2)",
            correctAnswer: "\(correctValue)",
            incorrectAnswer1: "\(correctValue + 1)",
            incorrectAnswer2: "\(correctValue - 1)",
            incorrectAnswer3: "\(correctValue + 2)"
        )
    }
}
