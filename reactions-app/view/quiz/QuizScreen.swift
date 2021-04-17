//
// Reactions App
//

import SwiftUI

struct QuizScreen: View {

    @ObservedObject var model: QuizViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            QuizScreenWithSettings(
                model: model,
                settings: QuizLayoutSettings(
                    geometry: geometry,
                    horizontalSizeClass: horizontalSizeClass,
                    verticalSizeClass: verticalSizeClass
                )
            )
        }
    }
}

private struct QuizScreenWithSettings: View {
    @ObservedObject var model: QuizViewModel
    let settings: QuizLayoutSettings

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .top) {
            if model.quizState != .completed {
                Rectangle()
                    .frame(height: settings.geometry.safeAreaInsets.top)
                    .edgesIgnoringSafeArea(.all)
                    .foregroundColor(.white)
                    .zIndex(3)
            }

            VStack(spacing: 0) {
                if model.quizState != .completed {
                    progressBar
                        .zIndex(2)
                        .accessibility(sortPriority: 0.5)
                }

                if model.quizState == .running {
                    QuizQuestionsBody(
                        settings: settings,
                        model: model
                    )
                    .accessibility(sortPriority: 2)
                }
                if model.quizState == .completed {
                    QuizReviewBody(settings: settings, model: model)
                        .accessibility(sortPriority: 2)
                }

                if model.quizState == .pending {
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: settings.navTotalWidth)
                        QuizIntroBody(
                            settings: settings,
                            model: model
                        )
                        .padding(.vertical, settings.progressBarPadding)
                        .accessibility(sortPriority: 2)
                        Spacer()
                            .frame(width: settings.navTotalWidth)
                    }
                }
            }
            .edgesIgnoringSafeArea(
                model.quizState == .pending ? [] : .bottom
            )

            navButtons

            NotificationView(
                isShowing: model.showNotification,
                settings: settings
            )
            .accessibility(hidden: true)
        }
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.8)
    }

    private var navButtons: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                PreviousButton(action: { navigate(next: false)})
                    .frame(width: settings.leftNavSize, height: settings.leftNavSize)
                    .padding(settings.leftNavPadding)
                    .accessibility(sortPriority: 0.7)
            }
            Spacer()
            VStack(spacing: 5) {
                Spacer()
                if model.quizState == .completed {
                    retryButton
                        .accessibility(sortPriority: 0.8)
                }

                nextButton
                    .accessibility(sortPriority: 0.9)
            }
        }
    }

    private var nextButton: some View {
        ZStack {
            NextButton(action: { navigate(next: true) })
                .disabled(model.nextIsDisabled)
                .opacity(model.nextIsDisabled ? 0.3 : 1)
                .padding(settings.rightNavPadding)
                .ifTrue(model.nextIsDisabled) {
                    $0.accessibility(hint: Text("Select correct answer to enable next button"))
                }

            if model.nextIsDisabled {
                Button(action: { navigate(next: true) }) {
                    Circle()
                        .opacity(0)
                }
                .accessibility(hidden: true)
            }

        }.frame(width: settings.rightNavSize, height: settings.rightNavSize)
    }

    private func navigate(next: Bool) {
        if next {
            if !model.nextIsDisabled {
                UIAccessibility.post(
                    notification: .screenChanged,
                    argument: NSString(string: "")
                )
            }
            model.next()
        } else {
            model.back()
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
            .accessibilityElement()
            .accessibility(label: Text("Restart quiz"))
        }
        .buttonStyle(NavButtonButtonStyle())
    }

    private var progressBar: some View {
        ZStack {
            Rectangle()
                .frame(
                    height:
                        settings.progressHeight + (2 * settings.progressBarPadding)
                )
                .foregroundColor(.white)
                .shadow(radius: 3, y: 0)
                .edgesIgnoringSafeArea(.horizontal)

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

            if model.quizState != .pending {
                progressLabel
            }
        }
        .accessibilityElement()
        .accessibility(label: Text("Quiz progress"))
        .accessibility(value: Text(accessibilityValue))
    }

    private var accessibilityValue: String {
        if model.quizState == .pending {
            return "0 out of \(model.quizLength)"
        }
        return "\(labelLhs) out of \(model.quizLength)"
    }

    private var progressLabel: some View {
        Text("\(labelLhs)/\(model.quizLength)")
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

    private var labelLhs: String {
        "\(model.currentIndex + 1)"
    }
}

fileprivate extension View {
    @ViewBuilder
    func ifTrue<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}

private struct NotificationView: View {

    let isShowing: Bool

    @GestureState private var offset: CGFloat = 0
    @GestureState private var isDragging = false

    let settings: QuizLayoutSettings
    var fontSize: CGFloat {
        0.75 * settings.answerFontSize
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(message)
            .font(.system(size: fontSize))
            .minimumScaleFactor(0.7)
            .padding(0.3 * height)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            )
            .frame(height: height)
            .padding(.top, topPadding)
            .offset(y: !isShowing && !isDragging ? notShowingOffset : showingOffset + offset)
            .gesture(gesture)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5))
    }

    private var showingOffset: CGFloat {
        0
    }

    private var notShowingOffset: CGFloat {
        -(height + safeAreaGap + topPadding + 10)
    }

    private var height: CGFloat {
        1.2 * settings.navSize
    }

    private var topPadding: CGFloat {
        0.1 * height
    }

    private var safeAreaGap: CGFloat {
        let safeArea = settings.geometry.safeAreaInsets
        return max(safeArea.bottom, safeArea.trailing, safeArea.leading, safeArea.top)
    }

    private var gesture: some Gesture {
        DragGesture()
            .updating($offset) { gesture, offsetState, _ in
                let dy = gesture.translation.height
                if dy > 0 {
                    offsetState = dy * 0.33
                } else {
                    offsetState = dy
                }
            }
            .updating($isDragging) { gesture, dragState, _ in
                dragState = true
            }
    }

    private var message: String {
        "Choose the correct answer to progress to the next question"
    }
}

struct QuizScreen_Previews: PreviewProvider {
    static var previews: some View {
        QuizScreen(
            model: QuizViewModel(
                questions: .zeroOrderQuestions,
                persistence: InMemoryQuizPersistence(),
                analytics: NoOpAnalytics()
            )
        )
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
