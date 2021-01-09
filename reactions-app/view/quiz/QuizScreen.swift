//
// Reactions App
//
  

import SwiftUI

struct QuizScreen: View {

    @ObservedObject var model: QuizViewModel

    var body: some View {
        GeometryReader { geometry in
            QuizScreenWithSettings(
                model: model,
                settings: QuizLayoutSettings(geometry: geometry)
            )
        }
    }
}

fileprivate struct QuizScreenWithSettings: View {
    @ObservedObject var model: QuizViewModel
    let settings: QuizLayoutSettings

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if (model.quizState != .completed) {
                    progressBar
                        .padding(.horizontal, settings.progressBarPadding)
                        .padding(.top, settings.progressBarPadding)
                }

                if (model.quizState == .running) {
                    QuizQuestionsBody(
                        settings: settings,
                        model: model
                    )
                }
                if (model.quizState == .completed) {
                    QuizReviewBody(settings: settings, model: model)
                }

                if (model.quizState == .pending) {
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: settings.navTotalWidth)
                        QuizIntroBody(
                            settings: settings,
                            model: model
                        )
                        .padding(.vertical, settings.progressBarPadding)
                        Spacer()
                            .frame(width: settings.navTotalWidth)
                    }
                }
            }
            .edgesIgnoringSafeArea(
                model.quizState == .pending ? [] : .bottom
            )
            navButtons
        }
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.8)
    }

    private var navButtons: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                PreviousButton(action: model.back)
                    .frame(width: settings.navSize, height: settings.navSize)

                Spacer()

                NextButton(action: model.next)
                    .frame(width: settings.navSize, height: settings.navSize)
                    .disabled(nextIsDisabled)
                    .opacity(nextIsDisabled ? 0.3 : 1)
            }
        }.padding(settings.navPadding)
    }

    private var nextIsDisabled: Bool {
        model.quizState == .running && model.selectedAnswer == nil
    }

    private var progressBar: some View {
        ZStack {
            ProgressBar(
                progress: 0.9,
                progressColor: Styling.quizAnswer,
                backgroundColor: Styling.inactiveScreenElement,
                backgroundBorder: Styling.inactiveScreenElement,
                cornerRadius: 0
            )
            .frame(
                width: settings.progressWidth,
                height: settings.progressHeight
            )

            progressLabel
        }
    }

    private var progressLabel: some View {
        Text("\(model.questionIndex + 1)/\(model.quizLength)")
        .font(.system(size: settings.progressFontSize))
        .padding(.horizontal, settings.progressLabelPadding)
        .background(
            ZStack {
                RoundedRectangle(
                    cornerRadius: settings.progressCornerRadius
                )
                .foregroundColor(Color.white)
                .opacity(0.8)

                RoundedRectangle(
                    cornerRadius: settings.progressCornerRadius
                )
                .stroke(lineWidth: 0.5)
                .foregroundColor(.black)
                .opacity(0.5)
            }
        )
    }
}

struct QuizScreen_Previews: PreviewProvider {
    static var previews: some View {
        QuizScreen(
            model: QuizViewModel(questions: QuizQuestion.zeroOrderQuestions)
        )
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
