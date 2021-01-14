//
// Reactions App
//
  

import SwiftUI

class QuizViewModel: ObservableObject {

    private let allQuestions: [QuizQuestion]
    private let questionSet: QuestionSet
    private let persistence: QuizPersistence

    init(
        questions: QuizQuestionsList,
        persistence: QuizPersistence
    ) {
        let displayQuestions = questions.createQuestions()
        self.allQuestions = displayQuestions
        self.currentQuestion = displayQuestions.first!
        self.questionSet = questions.questionSet
        self.persistence = persistence
    }


    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    // MARK: Published properties
    @Published var answers = [Int:QuizAnswerInput]()
    @Published var progress: CGFloat = 0
    @Published var quizState = QuizState.pending
    @Published var quizDifficulty = QuizDifficulty.medium

    @Published var showExplanation: Bool = false
    @Published var currentQuestion: QuizQuestion

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

    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    // MARK: Public methods
    func question(with id: Int) -> QuizQuestion {
        availableQuestions.first { $0.id == id }!
    }

    func selectedAnswer(id: Int) -> QuizAnswerInput? {
        answers[id]
    }

    func answer(option: QuizOption) {
        let newAnswer =
            answers[currentQuestion.id]?.appending(option) ?? QuizAnswerInput(firstAnswer: option)

        answers[currentQuestion.id] = newAnswer
        setShowExplanation(animate: true)
    }

    func optionText(_ option: QuizOption) -> TextLine {
        currentQuestion.options[option]?.answer ?? ""
    }

    // MARK: Private methods
    private func setShowExplanation(animate: Bool) {
        let shouldShowExplanation = selectedAnswer != nil && selectedAnswer?.firstAnswer != correctOption

        let duration = QuizViewModel.explanationExpansionDuration(currentQuestion)

        withAnimation(animate && !reduceMotion ? .easeOut(duration: duration) : nil) {
            showExplanation = shouldShowExplanation
        }
    }

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

    func next() {
        switch (quizState) {
        case .pending:
            quizState = .running
            answers = [Int:QuizAnswerInput]()
            setProgress()
        case .running:
            if (currentIndex == quizLength - 1) {
                quizState = .completed
                setProgress()
                saveQuiz()
            } else {
                setQuestion(newIndex: currentIndex + 1)
            }
        case .completed:
            nextScreen?()
        }
        setShowExplanation(animate: false)
    }

    func back() {
        switch (quizState) {
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
        setShowExplanation(animate: false)
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
    static func explanationExpansionDuration(_ question: QuizQuestion) -> Double {
        let contentLength = question.longExplanation.map(\.length).reduce(0) { $0 + $1 }

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

struct QuizAnswerInput: Equatable {
    let firstAnswer: QuizOption
    let otherAnswers: [QuizOption]

    init(firstAnswer: QuizOption, otherAnswers: [QuizOption] = []) {
        self.firstAnswer = firstAnswer
        self.otherAnswers = otherAnswers
    }

    func appending(_ option: QuizOption) -> QuizAnswerInput {
        guard option != firstAnswer else {
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
