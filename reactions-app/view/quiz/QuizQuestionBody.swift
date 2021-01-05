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
            HStack {
                Spacer()
                    .frame(width: settings.navTotalWidth)
                VStack {
                    QuizQuestionView(
                        question: model.currentQuestion,
                        settings: settings
                    )

                    if (model.showExplanation &&
                            model.currentQuestion.hasExplanation) {
                        explanationView
                            .padding(.bottom, 10)
                    }

                    answers

                }
                Spacer()
                    .frame(width: settings.navTotalWidth)
            }
            .padding(.top, settings.progressBarPadding)
            .padding(.bottom, settings.geometry.safeAreaInsets.bottom)
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
            .foregroundColor(.white)
            .shadow(radius: 4)
            .overlay(
                Image(systemName: "lightbulb.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .offset(x: 10, y: -10)
                    .foregroundColor(.orangeAccent),
                alignment: .topTrailing
            )
        )
        .fixedSize(horizontal: false, vertical: true)
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

                RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                    .stroke(lineWidth: answerLineWidth(option: option))
                    .foregroundColor(answerBorder(option: option))
                    .overlay(overlay(option: option), alignment: .topTrailing)

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
        let active = styleCorrect(option) || styleIncorrect(option) || model.selectedAnswer == nil
        return active ? Styling.quizAnswer : Styling.quizAnswerInactive
    }

    private func answerBorder(option: QuizOption) -> Color {
        if (styleCorrect(option)) {
            return Styling.quizAnswerCorrectBorder
        } else if (styleIncorrect(option)) {
            return Styling.quizAnswerIncorrectBorder
        }
        return Styling.quizAnswerBorder
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
