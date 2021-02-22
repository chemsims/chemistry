//
// Reactions App
//

import SwiftUI
import ReactionsCore

class QuizViewModel: ObservableObject {

    private let allQuestions: [QuizQuestion]
    private let questionSet: QuestionSet
    private let persistence: QuizPersistence
    private let analytics: AnalyticsService

    init(
        questions: QuizQuestionsList,
        persistence: QuizPersistence,
        analytics: AnalyticsService,
        restoreLastPersistedQuiz: Bool = true
    ) {
        let displayQuestions = questions.createQuestions()
        self.allQuestions = displayQuestions
        self.persistence = persistence
        self.questionSet = questions.questionSet
        self.currentQuestion = displayQuestions.first!
        self.analytics = analytics
        let previousQuiz = persistence.getAnswers(
            questionSet: questions.questionSet,
            questions: displayQuestions
        )
        if let previousQuiz = previousQuiz, restoreLastPersistedQuiz {
            self.quizDifficulty = previousQuiz.difficulty
            self.quizState = .completed
            self.currentQuestion = availableQuestions.last!
            self.answers = previousQuiz.answers
            setProgress()
        }
    }

    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    // MARK: Published properties
    @Published var currentQuestion: QuizQuestion
    @Published var answers = [String: QuizAnswerInput]()
    @Published var progress: CGFloat = 0
    @Published var quizState = QuizState.pending
    @Published var quizDifficulty = QuizDifficulty.medium

    // MARK: Public computed properties
    var selectedAnswer: QuizAnswerInput? {
        answers[currentQuestion.id]
    }

    var correctOption: QuizOption {
        currentQuestion.correctOption
    }

    var question: TextLine {
        currentQuestion.question
    }

    var correctAnswers: Int {
        answers.filter { answer in
            let question = availableQuestions.first { $0.id == answer.key }
            return question?.correctOption == answer.value.firstAnswer
        }.count
    }

    var availableQuestions: [QuizQuestion] {
        QuizDifficulty.availableQuestions(at: quizDifficulty, questions: allQuestions)
    }

    var availableDifficulties: [QuizDifficulty] {
        QuizDifficulty.allCases
    }

    var quizLength: Int {
        availableQuestions.count
    }

    var currentIndex: Int {
        let i = availableQuestions.firstIndex { $0.id == currentQuestion.id }
        assert(i != nil)
        return i ?? 0
    }

    var hasSelectedCorrectOption: Bool {
        answers[currentQuestion.id]?.allAnswers.contains(correctOption) ?? false
    }

    var answeredQuestions: [QuizQuestion] {
        availableQuestions.filter {
            selectedAnswer(id: $0.id) != nil
        }
    }

    var correctCount: Int {
        answeredQuestions.filter {  q in
            selectedAnswer(id: q.id)!.firstAnswer == q.correctOption
        }.count
    }

    var nextIsDisabled: Bool {
        quizState == .running && !hasSelectedCorrectOption
    }

    // MARK: Private variables
    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    private var hasLoggedQuizCompletion = false

    // MARK: Public methods
    func question(with id: String) -> QuizQuestion {
        availableQuestions.first { $0.id == id }!
    }

    func selectedAnswer(id: String) -> QuizAnswerInput? {
        answers[id]
    }

    func answer(option: QuizOption) {
        let prevAnswer = answers[currentQuestion.id]?.appending(option)
        let newAnswer = prevAnswer ?? QuizAnswerInput(firstAnswer: option)
        let duration = QuizViewModel.explanationExpansionDuration(currentQuestion, option: option)
        withAnimation(reduceMotion ? nil : .easeOut(duration: duration)) {
            answers[currentQuestion.id] = newAnswer
        }
        logAnswered(option: option, answerAttempt: newAnswer.allAnswers.count)
    }

    func optionText(_ option: QuizOption) -> TextLine {
        currentQuestion.options[option]?.answer ?? ""
    }

    func showExplanation(option: QuizOption) -> Bool {
        guard let answer = selectedAnswer?.allAnswers else {
            return false
        }
        return option != correctOption && answer.contains(option)
    }

    // MARK: Private methods
    private func setQuestion(newIndex: Int) {
        guard newIndex < availableQuestions.count && newIndex >= 0 else {
            return
        }
        currentQuestion = availableQuestions[newIndex]
        setProgress()
    }

    private func saveQuiz() {
        persistence.saveAnswers(
            quiz: SavedQuiz(
                questionSet: questionSet,
                difficulty: quizDifficulty,
                answers: answers
            ),
            questions: allQuestions
        )
    }
}

// MARK: Quiz Navigation
extension QuizViewModel {

    func next(force: Bool = false) {
        guard !nextIsDisabled || force else {
            return
        }
        switch quizState {
        case .pending:
            quizState = .running
            answers = [String: QuizAnswerInput]()
            setProgress()
            logStarted()
        case .running:
            if currentIndex == quizLength - 1 {
                quizState = .completed
                setProgress()
                saveQuiz()
                logEnded()
            } else {
                setQuestion(newIndex: currentIndex + 1)
            }
        case .completed:
            nextScreen?()
        }
    }

    func back() {
        switch quizState {
        case .pending:
            prevScreen?()
        case .running where currentIndex == 0:
            quizState = .pending
            setProgress()
        case .running:
            setQuestion(newIndex: currentIndex - 1)
        case .completed:
            quizState = .running
        }
    }

    func restart() {
        quizState = .pending
        currentQuestion = availableQuestions.first!
        setProgress()
    }

    func skip() {
        nextScreen?()
    }
}

// MARK: Animation methods
extension QuizViewModel {

    static func explanationExpansionDuration(_ question: QuizQuestion, option: QuizOption) -> Double {
        let contentLength = question.options[option]?.explanation.length ?? 0
        return explanationExpansionDuration(contentLength: contentLength)
    }

    private static func explanationExpansionDuration(contentLength: Int) -> Double {
        let minDuration: CGFloat = 0.3
        let maxDuration: CGFloat = 1
        let equation = LinearEquation(x1: 200, y1: minDuration, x2: 800, y2: 1)

        let duration = equation.getY(at: CGFloat(contentLength))
        return Double(min(maxDuration, max(duration, minDuration)))
    }

    fileprivate func setProgress() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            let pending = quizState == .pending
            progress = pending ? 0 : CGFloat(currentIndex + 1) / CGFloat(quizLength)
        }
    }
}

// MARK: Analytics methods
fileprivate extension QuizViewModel {

    func logStarted() {
        analytics.startedQuiz(questionSet: questionSet, difficulty: quizDifficulty)
        hasLoggedQuizCompletion = false
    }

    func logEnded() {
        guard !hasLoggedQuizCompletion else {
            return
        }
        analytics.completedQuiz(
            questionSet: questionSet,
            difficulty: quizDifficulty,
            percentCorrect: (Double(correctCount) / Double(quizDifficulty.quizLength)) * 100
        )
        hasLoggedQuizCompletion = true
    }

    func logAnswered(option: QuizOption, answerAttempt: Int) {
        let answerId = currentQuestion.options[option]?.id ?? "UNKNOWN-ANSWER-ID"
        analytics.answeredQuestion(
            questionSet: questionSet,
            questionId: currentQuestion.id,
            answerId: answerId,
            answerAttempt: answerAttempt,
            isCorrect: currentQuestion.correctOption == option
        )
    }
}

struct QuizAnswerInput: Equatable {
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
