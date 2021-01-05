//
// Reactions App
//
  

import SwiftUI

class QuizViewModel: ObservableObject {

    private let allQuestions: [QuizQuestionDisplay]
    let difficultyCount: [QuizDifficulty:Int]

    init(questions: [QuizQuestion]) {
        let displayQuestions = questions.map { $0.randomDisplay() }
        self.allQuestions = displayQuestions
        difficultyCount = QuizDifficulty.counts(questions: displayQuestions)

        var a = [Int:QuizOption]()
        availableQuestions.enumerated().forEach { (index, _) in
            a[index] = QuizOption.A
        }
        answers = a
    }

    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    @Published var answers = [Int:QuizOption]()
    @Published var progress: CGFloat = 0
    @Published var quizState = QuizState.pending
    @Published var quizDifficulty = QuizDifficulty.medium
    @Published private(set) var questionIndex = 0

    @Published var showExplanation: Bool = false

    var selectedAnswer: QuizOption? {
        answers[questionIndex]
    }

    var correctOption: QuizOption {
        currentQuestion.correctOption
    }

    var correctAnswers: Int {
        answers.filter { answer in
            availableQuestions[answer.key].correctOption == answer.value
        }.count
    }

    var availableQuestions: [QuizQuestionDisplay] {
        allQuestions.filter { question in
            question.difficulty <= quizDifficulty
        }
    }

    var availableDifficulties: [QuizDifficulty] {
        QuizDifficulty.allCases.filter {
            (difficultyCount[$0] ?? 0) > 0
        }.sorted()
    }

    var quizLength: Int {
        difficultyCount[quizDifficulty] ?? 0
    }

    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    func selectedOption(index: Int) -> QuizOption? {
        answers[index]
    }

    func next() {
        switch (quizState) {
        case .pending:
            quizState = .running
            answers = [Int:QuizOption]()
            setProgress()
        case .running:
            if (questionIndex == quizLength - 1) {
                quizState = .completed
                setProgress()
            } else {
                setQuestion(newIndex: questionIndex + 1)
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
        case .running where questionIndex == 0:
            quizState = .pending
            setProgress()
        case .running:
            setQuestion(newIndex: questionIndex - 1)
        case .completed:
            quizState = .running
        }
        setShowExplanation(animate: false)
    }

    func answer(option: QuizOption) {
        answers[questionIndex] = option
        setShowExplanation(animate: true)
    }

    func optionText(_ option: QuizOption) -> TextLine {
        currentQuestion.options[option]?.answer ?? ""
    }

    func restart() {
        quizState = .pending
        questionIndex = 0
        setProgress()
    }

    func skip() {
        nextScreen?()
    }

    private func setShowExplanation(animate: Bool) {
        let shouldShowExplanation = selectedAnswer != nil && selectedAnswer != correctOption
        withAnimation(animate && !reduceMotion ? .easeOut(duration: 0.4) : nil) {
            showExplanation = shouldShowExplanation
        }
    }

    var question: TextLine {
        currentQuestion.question
    }

    var currentQuestion: QuizQuestionDisplay {
        availableQuestions[questionIndex]
    }

    private func setQuestion(newIndex: Int) {
        guard newIndex < availableQuestions.count && newIndex >= 0 else {
            return
        }
        questionIndex = newIndex
        setProgress()
    }

    private func setProgress() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            let pending = quizState == .pending
            progress = pending ? 0 : CGFloat(questionIndex + 1) / CGFloat(quizLength)
        }
    }
}
