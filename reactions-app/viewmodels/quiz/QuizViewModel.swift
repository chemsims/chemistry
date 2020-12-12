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

    @Published var progress: CGFloat = 0
    @Published var question: String = ""
    @Published var hasSelectedAnswer: Bool = false
    @Published var correctOption: QuizOption = .A

    private var questionIndex: Int = 0
    private var maxIndex: Int = -1
    private var options = [QuizOption:String]()

    func next() {
        setQuestion(newIndex: questionIndex + 1)
        if (questionIndex > maxIndex) {
            maxIndex = questionIndex
        }
    }

    func back() {
        setQuestion(newIndex: questionIndex - 1)
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

        if (newIndex <= maxIndex) {
            hasSelectedAnswer = true
        } else {
            hasSelectedAnswer = false
        }

        questionIndex = newIndex

        withAnimation(.easeOut(duration: 0.4)) {
            progress = CGFloat(newIndex) / CGFloat(questions.count)
        }
    }
}
