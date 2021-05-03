//
// Reactions App
//

import SwiftUI

struct QuizReviewBody<QP: QuizPersistence, Analytics: AppAnalytics>: View where QP.QuestionSet == Analytics.QuestionSet {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel<QP, Analytics>

    var body: some View {
        ScrollView {
                VStack(spacing: 20) {
                    heading
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(0..<model.answeredQuestions.count) { index in
                        reviewCard(index: index)
                    }
                }
                .frame(width: settings.contentWidth)
                .padding(.top, settings.progressBarPadding)
                .padding(.bottom, settings.geometry.safeAreaInsets.bottom + 10)
                .frame(width: settings.width)
        }
    }

    private var heading: some View {
        let header = "You got \(model.correctCount) correct out of \(model.answeredQuestions.count)"
        let subHeader = "Let's review the questions!"

        return HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 5) {
                Text(header)
                Text(subHeader)
                    .font(.system(size: settings.h2FontSize))
            }
            .accessibilityElement()
            .accessibility(addTraits: .isHeader)
            .accessibility(label: Text("\(header), \(subHeader)"))
            Spacer()
        }
    }

    private func reviewCard(
        index: Int
    ) -> some View {
        let question = model.answeredQuestions[index]
        return QuestionReviewCard(
            question: question,
            answer: model.selectedAnswer(id: question.id)!,
            settings: settings,
            questionNumber: index + 1,
            totalQuestions: model.answeredQuestions.count
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct QuestionReviewCard: View {

    let question: QuizQuestion
    let answer: QuizAnswerInput
    let settings: QuizLayoutSettings

    let questionNumber: Int
    let totalQuestions: Int

    @State private var explanationIsExpanded: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Spacer()
                }
                QuizQuestionView(
                    question: question,
                    settings: settings,
                    tableWidth: settings.tableWidthReviewCard
                )
                .accessibility(label: Text(label))

                ForEach(answer.allAnswers, id: \.self) { option in
                    optionLine(
                        option: option,
                        topLine: "Your answer"
                    )
                }
            }
            .padding(4 * settings.questionReviewPadding)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, settings.questionReviewPadding)
        .font(.system(size: settings.questionFontSize))
        .background(reviewBackground)
    }

    private var label: String {
        let correct = isCorrect ? "correct" : "incorrect"
        let prefix = "Question \(questionNumber) of \(totalQuestions), \(correct)"
        return "\(prefix). \(question.question.label)"
    }

    private func optionLine(
        option: QuizOption,
        topLine: String
    ) -> some View {
        let optionIsCorrect = question.correctOption == option
        let topLine = optionIsCorrect && !isCorrect ? "Correct answer" : "Your answer"
        return QuizReviewSingleOption(
            question: question,
            topLine: topLine,
            option: option,
            settings: settings
        )
    }

    private var reviewBackground: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(.white)
            .shadow(radius: 3)

            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .strokeBorder(lineWidth: 2)
            .foregroundColor(borderColor)

            QuizAnswerIconOverlay(isCorrect: isCorrect)
                .frame(width: 30, height: 30)
                .offset(x: 10, y: -10)
                .accessibility(hidden: true)
        }
    }

    private var borderColor: Color {
        isCorrect ? Styling.Quiz.correctAnswerBorder : Styling.Quiz.wrongAnswerBorder
    }

    private var isCorrect: Bool {
        answer.firstAnswer == question.correctOption
    }
}

private struct QuizReviewSingleOption: View {

    let question: QuizQuestion
    let topLine: String
    let option: QuizOption
    let settings: QuizLayoutSettings

    @State private var explanationIsExpanded: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let answer = question.options[option]?.answer ?? ""
        let fullLine = answer.prepending(TextSegment(content: "\(topLine): "))

        let correctLabel = isCorrect ? "Correct" : "Incorrect"
        let label = "\(topLine), \(correctLabel). \(answer.label). Explanation: \(explanationString.label)"

        return VStack(alignment: .leading, spacing: 0) {
            TextLinesView(
                line: fullLine,
                fontSize: settings.questionFontSize,
                color: isCorrect ?
                    Styling.Quiz.reviewCorrectAnswerFont : Styling.Quiz.reviewWrongAnswerFont
            )
            .accessibility(label: Text(label))

            Button(action: handleExplanationPress) {
                Text(explanationIsExpanded ? "Hide Explanation" : "Show Explanation")
                    .font(.system(size: settings.questionFontSize))
            }

            if explanationIsExpanded {
                TextLinesView(
                    lines: [explanationString],
                    fontSize: settings.questionFontSize
                )
            }

        }
        .minimumScaleFactor(1)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func handleExplanationPress() {
        withAnimation( reduceMotion ? nil : .easeOut(duration: 0.2)) {
            explanationIsExpanded.toggle()
        }
    }

    private var explanationString: TextLine {
        question.options[option]?.explanation ?? ""
    }

    private var isCorrect: Bool {
        option == question.correctOption
    }
}
