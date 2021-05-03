//
// Reactions App
//

import Foundation

public struct SavedQuiz<QuestionSet> {
    let questionSet: QuestionSet
    let difficulty: QuizDifficulty
    let answers: [String : QuizAnswerInput]
}

public struct QuizAnswerInput: Equatable {
    let firstAnswer: QuizOption
    let otherAnswers: [QuizOption]

    init(firstAnswer: QuizOption, otherAnswers: [QuizOption] = []) {
        self.firstAnswer = firstAnswer
        self.otherAnswers = otherAnswers
    }

    func appending(_ option: QuizOption) -> QuizAnswerInput {
        guard !allAnswers.contains(option) else {
            return self
        }
        return QuizAnswerInput(
            firstAnswer: firstAnswer,
            otherAnswers: otherAnswers + [option]
        )
    }

    var allAnswers: [QuizOption] {
        [firstAnswer] + otherAnswers
    }
}
