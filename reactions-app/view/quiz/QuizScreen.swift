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
                        .zIndex(2)
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
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                PreviousButton(action: model.back)
                    .frame(width: settings.leftNavSize, height: settings.leftNavSize)
                    .padding(settings.leftNavPadding)
            }
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                if (model.quizState == .completed) {
                    retryButton
                }

                NextButton(action: model.next)
                    .frame(width: settings.rightNavSize, height: settings.rightNavSize)
                    .disabled(nextIsDisabled)
                    .opacity(nextIsDisabled ? 0.3 : 1)
                    .padding(settings.rightNavPadding)
            }
        }
    }

    private var retryButton: some View {
        Button(action: model.restart) {
            ZStack {
                Circle()
                    .foregroundColor(Styling.speechBubble)

                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
                    .padding(0.15 * settings.leftNavSize)
                    .font(.system(size: 15, weight: .bold))
            }
            .frame(width: settings.leftNavSize, height: settings.navSize)
        }
        .buttonStyle(NavButtonButtonStyle())
    }

    private var nextIsDisabled: Bool {
        model.quizState == .running && !model.hasSelectedCorrectOption
    }

    private var progressBar: some View {
        ZStack {
            Rectangle()
                .frame(height: settings.progressHeight + (2 * settings.progressBarPadding))
                .foregroundColor(.white)
                .shadow(radius: 3, y: 0)
                .edgesIgnoringSafeArea(.all)

            ProgressBar(
                progress: model.progress,
                progressColor: Styling.Quiz.progressForeground,
                backgroundColor: Styling.Quiz.progressBackground,
                cornerRadius: 0
            )
            .frame(
                width: settings.progressWidth,
                height: settings.progressHeight
            )
            .padding(.horizontal, settings.progressBarPadding)

            if (model.quizState != .pending) {
                progressLabel
            }
        }
    }

    private var progressLabel: some View {
        Text("\(model.currentIndex + 1)/\(model.quizLength)")
        .font(.system(size: settings.progressFontSize))
        .frame(width: settings.progressLabelWidth)
        .minimumScaleFactor(0.7)
        .background(
            ZStack {
                RoundedRectangle(
                    cornerRadius: settings.progressCornerRadius
                )
                .foregroundColor(Color.white)
                .opacity(0.9)

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
            model: QuizViewModel(questions: .zeroOrderQuestions)
        )
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
