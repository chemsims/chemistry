//
// Reactions App
//

import Foundation

public struct SavedQuiz<QuestionSet> {
    public let questionSet: QuestionSet
    public let difficulty: QuizDifficulty
    public let answers: [String : QuizAnswerInput]

    public init(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        answers: [String : QuizAnswerInput]
    ) {
        self.questionSet = questionSet
        self.difficulty = difficulty
        self.answers = answers
    }
}

public struct QuizAnswerInput: Equatable {
    let firstAnswer: QuizOption
    let otherAnswers: [QuizOption]

    public init(firstAnswer: QuizOption, otherAnswers: [QuizOption] = []) {
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
