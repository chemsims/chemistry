//
// Reactions App
//
  

import SwiftUI

struct QuizReviewBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: settings.navTotalWidth)
                VStack(spacing: 20) {
                    heading
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(0..<model.quizLength) { index in
                        reviewCard(index: index)
                    }
                }
                .padding(.top, settings.progressBarPadding)
                Spacer()
                    .frame(width: settings.navTotalWidth)
            }
        }
    }

    private var heading: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.retryLabelWidth)
            Spacer()
            VStack(spacing: 5) {
                Text("You got \(model.correctAnswers) correct out of \(model.quizLength)")
                    .foregroundColor(.orangeAccent)
                Text("Let's review the questions!")
            }

            Spacer()
            Button(action: model.restart) {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise.circle")
                        .padding(settings.retryPadding)
                        .background(
                            Circle()
                                .foregroundColor(Styling.speechBubble)
                        )
                        .frame(width: settings.retryIconWidth, height: settings.retryIconWidth)

                    Text("Retry")
                        .font(.system(size: settings.retryLabelFontSize))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(Styling.navIcon)
                }
                .foregroundColor(Styling.navIcon)
            }
            .frame(width: settings.retryLabelWidth)
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


    @State private var explanationIsExpanded: Bool = true

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

                if (selectedOption != question.correctOption) {
                    optionLine(
                        option: question.correctOption,
                        topLine: "Correct answer",
                        question: question
                    )
                }

                VStack(alignment: .leading, spacing: 0) {
                    Button(action: handleExplanationPress) {
                        Text(explanationIsExpanded ? "Hide Explanation" : "Show Explanation")
                            .font(.system(size: settings.questionFontSize))
                    }
                    if (explanationIsExpanded) {
                        TextLinesView(
                            lines: question.longExplanation,
                            fontSize: settings.questionFontSize
                        )
                    }

                }
            }
            .padding(settings.questionReviewPadding)
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
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(topLine)
                    .font(.system(size: settings.questionFontSize))
                    .foregroundColor(.orangeAccent)
                Spacer()
            }

            TextLinesView(
                line: answer,
                fontSize: settings.questionFontSize
            )
        }
        .minimumScaleFactor(1)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var reviewBackground: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(.white)
            .shadow(color: borderColor, radius: 3, x: 0, y: 0)

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
        isCorrect ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerIncorrectBorder
    }

    private func handleExplanationPress() {
        withAnimation(.easeOut(duration: 0.5)) {
            explanationIsExpanded.toggle()
        }
    }
}
