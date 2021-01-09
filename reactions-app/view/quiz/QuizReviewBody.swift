//
// Reactions App
//
  

import SwiftUI

struct QuizReviewBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    var body: some View {
        ScrollView {
                VStack(spacing: 20) {
                    heading
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(0..<model.quizLength) { index in
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
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 5) {
                Text("You got \(model.correctAnswers) correct out of \(model.quizLength)")
                Text("Let's review the questions!")
                    .font(.system(size: settings.h2FontSize))
            }
            Spacer()
        }
    }

    private func reviewCard(index: Int) -> some View {
        let question = model.availableQuestions[index]
        let selectedOption = model.selectedOption(index: index)
        let isCorrect = selectedOption == question.correctOption

        return QuestionReviewCard(
            question: question,
            selectedOption: selectedOption ?? .A,
            isCorrect: isCorrect,
            settings: settings
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

fileprivate struct QuestionReviewCard: View {

    let question: QuizQuestionDisplay
    let selectedOption: QuizOption
    let isCorrect: Bool
    let settings: QuizLayoutSettings

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

                optionLine(
                    option: selectedOption,
                    topLine: "Your answer",
                    question: question
                )

                VStack(alignment: .leading, spacing: 0) {
                    Button(action: handleExplanationPress) {
                        Text(explanationIsExpanded ? "Hide Explanation" : "Show Explanation")
                            .font(.system(size: settings.questionFontSize))
                    }
                    if (explanationIsExpanded) {
                        if (selectedOption != question.correctOption) {
                            optionLine(
                                option: question.correctOption,
                                topLine: "Correct answer",
                                question: question
                            )
                        }

                        TextLinesView(
                            lines: question.longExplanation,
                            fontSize: settings.questionFontSize
                        )
                    }
                }
            }
            .padding(4 * settings.questionReviewPadding)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, settings.questionReviewPadding)
        .font(.system(size: settings.questionFontSize))
        .background(reviewBackground)
    }

    private func optionLine(
        option: QuizOption,
        topLine: String,
        question: QuizQuestionDisplay
    ) -> some View {
        let answer = question.options[option]?.answer ?? ""
        let fullLine = answer.prepending(TextSegment(content: "\(topLine): "))
        let isCorrect = option == question.correctOption
        return VStack(alignment: .leading, spacing: 0) {
            TextLinesView(
                line: fullLine,
                fontSize: settings.questionFontSize,
                color: isCorrect ?
                    Styling.Quiz.reviewCorrectAnswerFont : Styling.Quiz.reviewWrongAnswerFont
            )
        }
        .minimumScaleFactor(1)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(Styling.Quiz.reviewCorrectAnswerFont)
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
        }
    }

    private var borderColor: Color {
        isCorrect ? Styling.Quiz.correctAnswerBorder : Styling.Quiz.wrongAnswerBorder
    }

    private func handleExplanationPress() {
        let duration = QuizViewModel.explanationExpansionDuration(question)

        withAnimation( reduceMotion ? nil : .easeOut(duration: duration)) {
            explanationIsExpanded.toggle()
        }
    }
}
