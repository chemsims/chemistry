//
// Reactions App
//
  

import SwiftUI

struct QuizQuestionsBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    @State private var badgeScale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                QuizQuestionView(
                    question: model.currentQuestion,
                    settings: settings,
                    tableWidth: settings.tableWidthQuestionCard
                )

                if (model.showExplanation && model.currentQuestion.hasExplanation) {
                    explanationView
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                }

                answers
            }
            .frame(width: settings.contentWidth)
            .padding(.top, settings.progressBarPadding)
            .padding(.bottom, settings.geometry.safeAreaInsets.bottom + 10)
            .frame(width: settings.width)
        }
    }

    private var explanationView: some View {
        TextLinesView(
            line: model.currentQuestion.explanation ?? "",
            fontSize: settings.answerFontSize
        )
        .padding()
        .background(
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(Styling.Quiz.explanationBackground)
            .shadow(radius: 4)
            .overlay(
                infoIcon,
                alignment: .topTrailing
            )
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    private var infoIcon: some View {
        ZStack {
            Circle()
                .foregroundColor(Styling.Quiz.infoIconBackground)

            Image(systemName: "info.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Styling.Quiz.infoIconForeground)
        }
        .frame(width: 30, height: 30)
        .offset(x: 10, y: -10)
    }

    private var answers: some View {
        VStack(spacing: 20) {
            answerWithExplanation(option: .A)
            answerWithExplanation(option: .B)
            answerWithExplanation(option: .C)
            answerWithExplanation(option: .D)
        }
    }

    private func answerWithExplanation(option: QuizOption) -> some View {
        VStack(spacing: 0) {
            answer(option: option)
            if (model.showExplanation &&
                    model.currentQuestion.hasExplanation(option: option)
            ) {
                optionExplanation(option: option)
            }
        }
    }

    private func answer(option: QuizOption) -> some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                    .foregroundColor(answerBackground(option: option))
                    .shadow(radius: 3)

                if (styleCorrect(option) || styleIncorrect(option)) {
                    RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                        .strokeBorder(lineWidth: answerLineWidth(option: option))
                        .foregroundColor(answerBorder(option: option))
                        .overlay(overlay(option: option), alignment: .topTrailing)
                }

                TextLinesView(
                    line: model.optionText(option),
                    fontSize: settings.answerFontSize
                )
                .foregroundColor(.black)
                .padding()
                .minimumScaleFactor(0.5)
            }
            .onTapGesture(perform: { handleAnswer(option: option) })
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func optionExplanation(option: QuizOption) -> some View {
        let explanation = model.currentQuestion.options[option]?.explanation
        return TextLinesView(
                line: explanation?.italic() ?? "",
                fontSize: settings.answerFontSize
        )
        .padding()
        .fixedSize(horizontal: false, vertical: true)
    }

    private func overlay(option: QuizOption) -> some View {
        ZStack {
            if (styleCorrect(option) || styleIncorrect(option)) {
                QuizAnswerIconOverlay(isCorrect: styleCorrect(option))
                    .scaleEffect(badgeScale)
                    .onAppear(perform: runBadgeAnimation)
            }
        }
        .frame(width: settings.navSize, height: settings.navSize)
        .offset(x: settings.navSize / 3, y: -settings.navSize / 3)
        .id("\(model.questionIndex)-\(option.hashValue)")
    }

    private func runBadgeAnimation() {
        guard !reduceMotion else {
            return
        }
        if (model.selectedAnswer == model.correctOption) {
            badgeScale = 1
            withAnimation(.easeOut(duration: 0.35)) {
                badgeScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    badgeScale = 1
                }
            }
        } else {
            badgeScale = 0.75
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                badgeScale = 1
            }
        }
    }

    private func handleAnswer(option: QuizOption) {
        guard model.selectedAnswer == nil else {
            return
        }
        model.answer(option: option)
    }

    private func answerBackground(option: QuizOption) -> Color {
        if (styleCorrect(option)) {
            return Styling.Quiz.correctAnswerBackground
        } else if (styleIncorrect(option)) {
            return Styling.Quiz.wrongAnswerBackground
        } else if (model.selectedAnswer != nil) {
            return Styling.Quiz.disabledAnswerBackground
        }
        return Styling.Quiz.answerBackground
    }

    private func answerBorder(option: QuizOption) -> Color {
        if (styleCorrect(option)) {
            return Styling.Quiz.correctAnswerBorder
        } else if (styleIncorrect(option)) {
            return Styling.Quiz.wrongAnswerBorder
        }
        return Styling.Quiz.answerBackground
    }

    private func answerLineWidth(option: QuizOption) -> CGFloat {
        styleCorrect(option) || styleIncorrect(option) ? settings.activeLineWidth : settings.standardLineWidth
    }

    private func styleCorrect(_ option: QuizOption) -> Bool {
        model.selectedAnswer != nil && model.correctOption == option
    }

    private func styleIncorrect(_ option: QuizOption) -> Bool {
        model.selectedAnswer == option && model.correctOption != option
    }
}
