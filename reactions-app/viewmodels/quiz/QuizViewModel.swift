//
// Reactions App
//
  

import SwiftUI

class QuizViewModel: ObservableObject {

    let questions: [QuizQuestionDisplay]

    init() {
        questions = ZeroOrderQuizQuestions.questions.map { $0.randomDisplay() }
        setQuestion(newIndex: 1)
    }

    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    @Published private var answers = [Int:QuizOption]()

    @Published var progress: CGFloat = 0
    @Published var correctOption: QuizOption = .A
    @Published var quizState = QuizState.running
    @Published var quizDifficulty = QuizDifficulty.medium
    private(set) var questionIndex = 0

    var selectedAnswer: QuizOption? {
        answers[questionIndex]
    }

    var correctAnswers: Int {
        answers.filter { answer in
            questions[answer.key].correctOption == answer.value
        }.count
    }

    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    func selectedOption(index: Int) -> QuizOption? {
        answers[index]
    }

    func next() {
        guard quizDifficulty != .skip else {
            nextScreen?()
            return
        }
        switch (quizState) {
        case .pending:
            quizState = .running
        case .running:
            if (questionIndex == quizDifficulty.quizLength - 1) {
                quizState = .completed
                questionIndex += 1
                setProgress()
            } else {
                setQuestion(newIndex: questionIndex + 1)
            }
        case .completed:
            nextScreen?()
        }
    }

    func back() {
        switch (quizState) {
        case .pending:
            prevScreen?()
        case .running where questionIndex == 0:
            quizState = .pending
        default:
            quizState = .running
            setQuestion(newIndex: questionIndex - 1)
        }
    }

    func answer(option: QuizOption) {
        answers[questionIndex] = option
    }

    func optionText(_ option: QuizOption) -> TextLine {
        currentQuestion.options[option] ?? ""
    }

    var question: TextLine {
        currentQuestion.question
    }

    private var currentQuestion: QuizQuestionDisplay {
        questions[questionIndex]
    }

    private func setQuestion(newIndex: Int) {
        guard newIndex < questions.count && newIndex >= 0 else {
            return
        }
        let nextQuestion = questions[newIndex]
        correctOption = nextQuestion.correctOption
        questionIndex = newIndex
        setProgress()
    }

    private func setProgress() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            progress = CGFloat(questionIndex) / CGFloat(quizDifficulty.quizLength)
        }
    }
}
