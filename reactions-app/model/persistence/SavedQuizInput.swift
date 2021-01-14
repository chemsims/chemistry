//
// Reactions App
//
  

import Foundation

protocol QuizPersistence {

    func saveAnswers(
        quiz: SavedQuiz,
        questions: [QuizQuestion]
    )

    func getAnswers(
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> SavedQuiz?
}

struct SavedQuiz {
    let questionSet: QuestionSet
    let difficulty: QuizDifficulty
    let answers: [Int:QuizAnswerInput]
}

fileprivate struct SavedPersistedQuiz {
    let difficulty: QuizDifficulty
    let answers: [Int: QuizAnswerPersistedInput]
}

fileprivate struct QuizAnswerPersistedInput {
    let firstAnswerId: Int
    let otherAnswersId: [Int]
}


enum QuestionSet: CaseIterable {
    case zeroOrder,
         firstOrder,
         secondOrder,
         reactionComparison,
         energyProfile
}

class InMemoryQuizPersistence: QuizPersistence {

    private var underlyingResults = [QuestionSet:SavedPersistedQuiz]()

    func saveAnswers(
        quiz: SavedQuiz,
        questions: [QuizQuestion]
    ) {
        underlyingResults[quiz.questionSet] = serialiseAnswers(quiz, questions: questions)
    }

    func getAnswers(
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> SavedQuiz? {
        let quiz = underlyingResults[questionSet]
        return quiz.map { q in
            deserialiseAnswers(q, questionSet: questionSet, questions: questions)
        }
    }
}

// MARK: Serialize
fileprivate extension InMemoryQuizPersistence {
    private func serialiseAnswers(
        _ quiz: SavedQuiz,
        questions: [QuizQuestion]
    ) -> SavedPersistedQuiz {
        var serializedAnswers = [Int:QuizAnswerPersistedInput]()

        quiz.answers.forEach { (questionId, answer) in
            if let serialized =
                serializeAnswer(questions: questions, questionId: questionId, answer: answer) {
                serializedAnswers[questionId] = serialized
            }
        }

        assert(serializedAnswers.count == quiz.answers.count)
        return SavedPersistedQuiz(difficulty: quiz.difficulty, answers: serializedAnswers)
    }

    private func serializeAnswer(
        questions: [QuizQuestion],
        questionId: Int,
        answer: QuizAnswerInput
    ) -> QuizAnswerPersistedInput? {
        let question = questions.first { $0.id == questionId }
        let firstId = question?.options[answer.firstAnswer]?.id
        let otherIds = answer.otherAnswers.compactMap { i in question?.options[i]?.id }

        assert(firstId != nil)
        assert(answer.otherAnswers.count == otherIds.count)

        return firstId.map {
            QuizAnswerPersistedInput(firstAnswerId: $0, otherAnswersId: otherIds)
        }
    }
}

// MARK: Deserialize
fileprivate extension InMemoryQuizPersistence {

    private func deserialiseAnswers(
        _ quiz: SavedPersistedQuiz,
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> SavedQuiz {

        var deserializedAnswers = [Int: QuizAnswerInput]()
        quiz.answers.forEach { (questionId, answer) in
            if let deserialized =
                deserializeAnswer(answer, questionId: questionId, questions: questions) {
                deserializedAnswers[questionId] = deserialized
            }
        }
        assert(deserializedAnswers.count == quiz.answers.count)
        return SavedQuiz(
            questionSet: questionSet,
            difficulty: quiz.difficulty,
            answers: deserializedAnswers
        )
    }

    private func deserializeAnswer(
        _ answer: QuizAnswerPersistedInput,
        questionId: Int,
        questions: [QuizQuestion]
    ) -> QuizAnswerInput? {
        let question = questions.first { $0.id == questionId }

        func getOption(_ id: Int) -> QuizOption? {
            question?.options.first { $1.id == id }?.key
        }

        let firstOption = getOption(answer.firstAnswerId)
        let otherOptions = answer.otherAnswersId.compactMap(getOption)

        assert(firstOption != nil)
        assert(answer.otherAnswersId.count == otherOptions.count)

        return firstOption.map { firstOption in
            QuizAnswerInput(firstAnswer: firstOption, otherAnswers: otherOptions)
        }
    }
}

fileprivate struct QuizResultsKey: Hashable {
    let difficulty: QuizDifficulty
    let questionSet: QuestionSet
}


