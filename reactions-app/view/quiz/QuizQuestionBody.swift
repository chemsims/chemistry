//
// Reactions App
//
  

import SwiftUI

struct QuizQuestionsBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    @State private var badgeScale: CGFloat = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                QuizQuestionView(
                    question: model.currentQuestion,
                    settings: settings,
                    tableWidth: settings.tableWidthQuestionCard
                )

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
        QuizAnswerOption(
            model: model,
            settings: settings,
            option: option
        )
    }

}

fileprivate struct QuizAnswerOption: View {

    @ObservedObject var model: QuizViewModel
    let settings: QuizLayoutSettings
    let option: QuizOption

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var badgeScale: CGFloat = 1

    var body: some View {
        VStack(spacing: 0) {
            answer
            if (model.showExplanation(option: option)) {
                explanation
            }
        }
    }

    private var answer: some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                    .foregroundColor(answerBackground)
                    .shadow(radius: 3)

                if (styleCorrect || styleIncorrect) {
                    RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                        .strokeBorder(lineWidth: settings.activeLineWidth)
                        .foregroundColor(answerBorder)
                        .overlay(overlay, alignment: .topTrailing)
                }

                TextLinesView(
                    line: model.optionText(option),
                    fontSize: settings.answerFontSize
                )
                .foregroundColor(.black)
                .padding()
                .minimumScaleFactor(0.5)
            }
            .onTapGesture(perform: { handleAnswer() })
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var explanation: some View {
        let explanation = model.currentQuestion.options[option]?.explanation?.italic()
        return
            TextLinesView(
                line: explanation ?? TextLine(stringLiteral: "Explanation for option \(option)"),
                fontSize: settings.answerFontSize
            )
            .padding()
            .fixedSize(horizontal: false, vertical: true)
    }

    private var overlay: some View {
        ZStack {
            if (styleCorrect || styleIncorrect) {
                QuizAnswerIconOverlay(isCorrect: styleCorrect)
                    .scaleEffect(badgeScale)
                    .onAppear(perform: runBadgeAnimation)
            }
        }
        .frame(width: settings.navSize, height: settings.navSize)
        .offset(x: settings.navSize / 3, y: -settings.navSize / 3)
        .id("\(model.currentIndex)-\(option.hashValue)")
    }

    private func runBadgeAnimation() {
        guard !reduceMotion, model.selectedAnswer?.allAnswers.contains(option) ?? false else {
            return
        }
        if (option == model.correctOption) {
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

    private func handleAnswer() {
        let notFinished = !model.hasSelectedCorrectOption
        let notSelected = !(model.selectedAnswer?.allAnswers.contains(option) ?? false)
        guard notFinished && notSelected else {
            return
        }
        model.answer(option: option)
    }

    private var answerBackground: Color {
        if (styleCorrect) {
            return Styling.Quiz.correctAnswerBackground
        } else if (styleIncorrect) {
            return Styling.Quiz.wrongAnswerBackground
        } else if (model.hasSelectedCorrectOption) {
            return Styling.Quiz.disabledAnswerBackground
        }
        return Styling.Quiz.answerBackground
    }

    private var answerBorder: Color {
        if (styleCorrect) {
            return Styling.Quiz.correctAnswerBorder
        } else if (styleIncorrect) {
            return Styling.Quiz.wrongAnswerBorder
        }
        return Styling.Quiz.answerBackground
    }

    private var styleCorrect: Bool {
        option == model.correctOption && model.hasSelectedCorrectOption
    }

    private var styleIncorrect: Bool {
        let isIncorrect = model.correctOption != option
        let isSelected = model.selectedAnswer?.allAnswers.contains(option) ?? false
        return isIncorrect && isSelected
    }
}
