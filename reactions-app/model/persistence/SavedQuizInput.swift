//
// Reactions App
//
  

import Foundation

fileprivate struct SavedQuizAnswer {
    let difficulty: QuizDifficulty
}

enum QuestionSet: CaseIterable {
    case zeroOrder,
         firstOrder,
         secondOrder,
         reactionComparison,
         energyProfile
}

protocol QuizPersistence {

    func setDifficulty(for questionSet: QuestionSet, difficulty: QuizDifficulty)

    func getDifficulty(for questionSet: QuestionSet) -> QuizDifficulty?

    func saveAnswers(
        difficulty: QuizDifficulty,
        questionSet: QuestionSet,
        questions: [QuizQuestion],
        answers: [Int: QuizAnswerInput]
    )

    func getAnswers(
        difficulty: QuizDifficulty,
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> [Int:QuizAnswerInput]
}

class InMemoryQuizPersistence: QuizPersistence {

    private var underlyingDifficulty = [QuestionSet:QuizDifficulty]()

    private var underlyingResults = [QuizResultsKey:[Int:QuizAnswerPersistedInput]]()

    func setDifficulty(for questionSet: QuestionSet, difficulty: QuizDifficulty) {
        underlyingDifficulty[questionSet] = difficulty
    }

    func getDifficulty(for questionSet: QuestionSet) -> QuizDifficulty? {
        underlyingDifficulty[questionSet]
    }

    func saveAnswers(
        difficulty: QuizDifficulty,
        questionSet: QuestionSet,
        questions: [QuizQuestion],
        answers: [Int : QuizAnswerInput]
    ) {
        let key = QuizResultsKey(difficulty: difficulty, questionSet: questionSet)
        underlyingResults[key] = serialiseAnswers(answers, questions: questions)
    }

    func getAnswers(
        difficulty: QuizDifficulty,
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> [Int : QuizAnswerInput] {
        let key = QuizResultsKey(difficulty: difficulty, questionSet: questionSet)
        let deserialized = underlyingResults[key].map { answers in
            deserialiseAnswers(answers, questions: questions)
        }
        return deserialized ?? [:]
    }

    private func deserialiseAnswers(
        _ answers: [Int: QuizAnswerPersistedInput],
        questions: [QuizQuestion]
    ) -> [Int:QuizAnswerInput] {
        var deserializedAnswers = [Int: QuizAnswerInput]()

        answers.forEach { (questionId, answer) in
            if let deserialized =
                deserializeAnswer(answer, questionId: questionId, questions: questions) {
                deserializedAnswers[questionId] = deserialized
            }
        }
        assert(deserializedAnswers.count == answers.count)
        return deserializedAnswers
    }

    private func serialiseAnswers(
        _ answers: [Int : QuizAnswerInput],
        questions: [QuizQuestion]
    ) -> [Int : QuizAnswerPersistedInput] {
        var serializedAnswers = [Int:QuizAnswerPersistedInput]()

        answers.forEach { (questionId, answer) in
            if let serialized =
                serializeAnswer(questions: questions, questionId: questionId, answer: answer) {
                serializedAnswers[questionId] = serialized
            }
        }

        assert(serializedAnswers.count == answers.count)
        return serializedAnswers
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

fileprivate struct QuizAnswerPersistedInput {
    let firstAnswerId: Int
    let otherAnswersId: [Int]
}
