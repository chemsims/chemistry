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

    @Published var progress: CGFloat = 0
    @Published var question: String = ""
    @Published var hasSelectedAnswer: Bool = false
    @Published var correctOption: QuizOption = .A
    @Published var quizState: QuizState = .pending
    @Published var quizDifficulty = QuizDifficulty.medium
    private(set) var questionIndex: Int = 0


    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    private var maxAnsweredIndex: Int = -1
    private var options = [QuizOption:String]()

    func next() {
        switch (quizState) {
        case .pending:
            quizState = .running
        case .running:
            setMaxAnsweredIndex()
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
            setMaxAnsweredIndex()
            setQuestion(newIndex: questionIndex - 1)
        }
    }

    private func setMaxAnsweredIndex() {
        if (hasSelectedAnswer) {
            maxAnsweredIndex = max(questionIndex, maxAnsweredIndex)
        }
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

        if (newIndex <= maxAnsweredIndex) {
            hasSelectedAnswer = true
        } else {
            hasSelectedAnswer = false
        }

        questionIndex = newIndex

        setProgress()
    }

    private func setProgress() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            progress = CGFloat(questionIndex) / CGFloat(quizDifficulty.quizLength)
        }
    }
}
