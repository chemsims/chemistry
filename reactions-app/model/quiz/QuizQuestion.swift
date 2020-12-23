//
// Reactions App
//


import Foundation

struct QuizQuestion {
    let question: TextLine
    let correctAnswer: QuizAnswer
    let otherAnswers: [QuizAnswer]
    let explanation: TextLine?
    let difficulty: QuizDifficulty

    func randomDisplay() -> QuizQuestionDisplay {
        assert(otherAnswers.count < QuizOption.allCases.count)

        var options = QuizOption.allCases
        var answers = [QuizOption: TextLine]()
        func add(_ answer: QuizAnswer, _ option: QuizOption) {
            assert(answers[option] == nil)
            options = options.filter { $0 != option }
            answers[option] = answer.answer
        }

        if let correctOption = correctAnswer.position {
            options = options.filter { $0 != correctOption }
        }

        otherAnswers.forEach { answer in
            let option = answer.position ?? options.randomElement()!
            add(answer, option)
        }
        let correctOption = correctAnswer.position ?? options.randomElement()!
        add(correctAnswer, correctOption)

        return QuizQuestionDisplay(
            question: question,
            options: answers,
            correctOption: correctOption,
            explanation: nil
        )
    }
}

struct QuizQuestionDisplay {
    let question: TextLine
    let options: [QuizOption:TextLine]
    let correctOption: QuizOption
    let explanation: TextLine?
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
