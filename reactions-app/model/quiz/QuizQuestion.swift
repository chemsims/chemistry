//
// Reactions App
//
  

import Foundation

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

struct QuizQuestionOptions: Identifiable {
    let id = UUID()
    let question: String
    let options: [QuizOption:String]
    let correctOption: QuizOption
}

extension QuizQuestion {

    static let dummyQuestions = [q1, q2, q3]

    static let q1 = QuizQuestion(
        question: "What is 1 + 1?",
        correctAnswer: "2",
        incorrectAnswer1: "3",
        incorrectAnswer2: "4",
        incorrectAnswer3: "5"
    )

    static let q2 = QuizQuestion(
        question: "What is 2 + 2?",
        correctAnswer: "4",
        incorrectAnswer1: "5",
        incorrectAnswer2: "6",
        incorrectAnswer3: "7"
    )

    static let q3 = QuizQuestion(
        question: "What is 3 + 3?",
        correctAnswer: "6",
        incorrectAnswer1: "7",
        incorrectAnswer2: "8",
        incorrectAnswer3: "9"
    )
}
