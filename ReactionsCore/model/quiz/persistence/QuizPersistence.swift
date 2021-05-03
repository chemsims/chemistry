//
// Reactions App
//

import Foundation

public protocol QuizPersistence {
    associatedtype QuestionSet

    func saveAnswers(quiz: SavedQuiz<QuestionSet>, questions: [QuizQuestion])

    func getAnswers(
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> SavedQuiz<QuestionSet>?
}

public class InMemoryQuizPersistence<QuestionSet: Hashable>: QuizPersistence {

    public init() { }

    private var underlyingResults = [QuestionSet: SavedPersistedQuiz]()

    public func saveAnswers(
        quiz: SavedQuiz<QuestionSet>,
        questions: [QuizQuestion]
    ) {
        underlyingResults[quiz.questionSet] = serialiseAnswers(quiz, questions: questions)
    }

    public func getAnswers(
        questionSet: QuestionSet,
        questions: [QuizQuestion]
    ) -> SavedQuiz<QuestionSet>? {
        let quiz = underlyingResults[questionSet]
        return quiz.map { q in
            deserialiseAnswers(q, questionSet: questionSet, questions: questions)
        }
    }
}

public class UserDefaultsQuizPersistence<QuestionSet: RawRepresentable>: QuizPersistence where QuestionSet.RawValue == String {

    public init() { }

    private let userDefaults = UserDefaults.standard

    private let keyBase = "quiz-results"

    public func saveAnswers(quiz: SavedQuiz<QuestionSet>, questions: [QuizQuestion]) {
        let serialized = serialiseAnswers(quiz, questions: questions)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(serialized) {
            userDefaults.set(encoded, forKey: key(for: quiz.questionSet))
        }
    }

    public func getAnswers(questionSet: QuestionSet, questions: [QuizQuestion]) -> SavedQuiz<QuestionSet>? {
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
        _ quiz: SavedQuiz<QuestionSet>,
        questions: [QuizQuestion]
    ) -> SavedPersistedQuiz {
        var serializedAnswers = [String: QuizAnswerPersistedInput]()

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
    ) -> SavedQuiz<QuestionSet> {

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

        func getOption(_ id: String) -> QuizOption? {
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

private struct SavedPersistedQuiz: Codable {
    let difficulty: QuizDifficulty
    let answers: [String: QuizAnswerPersistedInput]
}

private struct QuizAnswerPersistedInput: Codable {
    let firstAnswerId: String
    let otherAnswersId: [String]
}
