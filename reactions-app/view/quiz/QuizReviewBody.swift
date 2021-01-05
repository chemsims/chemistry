//
// Reactions App
//
  

import SwiftUI

struct QuizReviewBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    @State private var expandedExplanations = Set<Int>()

    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                    VStack(spacing: 20) {
                        heading
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
    }

    private var heading: some View {
        HStack {
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

        return ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Spacer()
                }
                QuizQuestionView(
                    question: question,
                    settings: settings
                )

                optionLine(
                    option: selectedOption!,
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
                    Button(action: { handleExplanationPress(index: index) }) {
                        Text(expandedExplanations.contains(index) ? "Hide Explanation" : "Show Explanation")
                            .font(.system(size: settings.questionFontSize))
                    }
                    if (expandedExplanations.contains(index)) {
                        TextLinesView(
                            lines: question.longExplanation,
                            fontSize: settings.questionFontSize
                        )
                    }

                }
            }
            .padding()
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
        .font(.system(size: settings.questionFontSize))
        .background(
            reviewBackground(isCorrect: isCorrect)
        )
    }

    private func reviewBackground(isCorrect: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(.white)
            .shadow(color: borderColor(isCorrect: isCorrect), radius: 3, x: 0, y: 0)

            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .strokeBorder(lineWidth: 2)
            .foregroundColor(borderColor(isCorrect: isCorrect))

            QuizAnswerIconOverlay(isCorrect: isCorrect)
                .frame(width: 30, height: 30)
                .offset(x: 10, y: -10)
        }
    }

    private func borderColor(isCorrect: Bool) -> Color {
        isCorrect ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerIncorrectBorder
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

    private func incorrectAnswer(
        question: QuizQuestionDisplay,
        selectedOption: QuizOption?
    ) -> some View {
        let selectedAnswer = selectedOption.flatMap { question.options[$0]?.answer } ?? ""
        return VStack(alignment: .leading) {
            HStack {
                Text("Your answer")
                TextLinesView(
                    line: selectedAnswer,
                    fontSize: settings.fontSize
                )
                .foregroundColor(.orangeAccent)
            }
        }
    }

    private func handleExplanationPress(index: Int) {
        withAnimation(.easeOut(duration: 0.5)) {
            if (expandedExplanations.contains(index)) {
                expandedExplanations.remove(index)
            } else {
                expandedExplanations.insert(index)
            }
        }
    }
}

