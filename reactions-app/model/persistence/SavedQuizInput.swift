//
// Reactions App
//
  

import Foundation

fileprivate struct SavedQuizAnswer {
    let difficulty: QuizDifficulty
}

enum QuestionSet {
    case zeroOrder,
         firstOrder,
         secondOrder,
         reactionComparison,
         energyProfile
}

protocol Foo {

    func saveDifficulty(difficulty: QuizDifficulty, questionSet: QuestionSet)

    func getDifficulty(questionSet: QuestionSet) -> QuizDifficulty?

    func saveResults(
        difficulty: QuizDifficulty,
        questionSet: QuestionSet,
        results: [Int: QuizAnswerInput]
    )

    func getResults(difficulty: QuizDifficulty, questions: QuestionSet) -> [Int:QuizAnswerInput]
}
