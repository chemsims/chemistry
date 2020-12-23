//
// Reactions App
//
  

import SwiftUI

class QuizViewModel: ObservableObject {

    let questions: [QuizQuestionOptions]

    init() {
        questions = QuizQuestion.dummyQuestions.map { $0.randomOptions }
        setQuestion(newIndex: 0)
    }

    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    @Published private var answers = [Int:QuizOption]()

    @Published var progress: CGFloat = 0
    @Published var question = ""

    @Published var correctOption: QuizOption = .A
    @Published var quizState = QuizState.completed
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

    private var options = [QuizOption:String]()

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

    func optionText(_ option: QuizOption) -> String {
        options[option] ?? ""
    }

    private func setQuestion(newIndex: Int) {
        guard newIndex < questions.count && newIndex >= 0 else {
            return
        }
        let nextQuestion = questions[newIndex]
        correctOption = nextQuestion.correctOption
        options = nextQuestion.options
        question = nextQuestion.question
        questionIndex = newIndex
        setProgress()
    }

    private func setProgress() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            progress = CGFloat(questionIndex) / CGFloat(quizDifficulty.quizLength)
        }
    }
}
