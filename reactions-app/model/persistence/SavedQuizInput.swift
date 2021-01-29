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
    let answers: [String:QuizAnswerInput]
}

fileprivate struct SavedPersistedQuiz: Codable {
    let difficulty: QuizDifficulty
    let answers: [String: QuizAnswerPersistedInput]
}

fileprivate struct QuizAnswerPersistedInput: Codable {
    let firstAnswerId: Int
    let otherAnswersId: [Int]
}

enum QuestionSet: String, CaseIterable {
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

class UserDefaultsQuizPersistence: QuizPersistence {

    private let userDefaults = UserDefaults.standard

    private let keyBase = "quiz-results"

    func saveAnswers(quiz: SavedQuiz, questions: [QuizQuestion]) {
        let serialized = serialiseAnswers(quiz, questions: questions)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(serialized) {
            userDefaults.set(encoded, forKey: key(for: quiz.questionSet))
        }
    }

    func getAnswers(questionSet: QuestionSet, questions: [QuizQuestion]) -> SavedQuiz? {
        let decoder = JSONDecoder()
        if let data = userDefaults.object(forKey: key(for: questionSet)) as? Data {
            if let decoded = try? decoder.decode(SavedPersistedQuiz.self, from: data) {
                return deserialiseAnswers(decoded, questionSet: questionSet, questions: questions)
            }
        }
        return nil
    }

    private func key(for questionSet: QuestionSet) -> String {
        "\(keyBase)-\(questionSet.rawValue)"
    }
}


// MARK: Serialize
fileprivate extension QuizPersistence {
    func serialiseAnswers(
        _ quiz: SavedQuiz,
        questions: [QuizQuestion]
    ) -> SavedPersistedQuiz {
        var serializedAnswers = [String:QuizAnswerPersistedInput]()

        quiz.answers.forEach { (questionId, answer) in
            if let serialized =
                serializeAnswer(
                    questions: questions,
                    questionId: questionId,
                    answer: answer
                ) {
                serializedAnswers[questionId] = serialized
            }
        }

        assert(serializedAnswers.count == quiz.answers.count)
        return SavedPersistedQuiz(difficulty: quiz.difficulty, answers: serializedAnswers)
    }

    func serializeAnswer(
        questions: [QuizQuestion],
        questionId: String,
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
fileprivate extension QuizPersistence {

    func deserialiseAnswers(
        _ quiz: SavedPersistedQuiz,
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> SavedQuiz {

        var deserializedAnswers = [String: QuizAnswerInput]()
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

    func deserializeAnswer(
        _ answer: QuizAnswerPersistedInput,
        questionId: String,
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
