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

    @State private var shakingOption: QuizOption?
    @State private var badgeScale: CGFloat = 1

    var body: some View {
        ZStack {
            VStack {
                progressBar
                    .frame(
                        width: settings.progressWidth,
                        height: settings.progressHeight
                    ).padding(settings.navPadding)

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                    if (!model.quizHasFinished) {
                        questionBody
                    } else {
                        reviewList
                    }
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                }

                Spacer()
            }
            navButtons
        }
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.8)
    }

    private var reviewList: some View {
        VStack {
            Text("Let's review the questions!")
            VStack {
                ForEach(model.questions) { question in
                    reviewCard(question: question)
                }
            }.edgesIgnoringSafeArea(.bottom)
        }
    }

    private func reviewCard(question: QuizQuestionOptions) -> some View {
        HStack {
            Text(question.question)
            Text(question.options[question.correctOption] ?? "")
                .foregroundColor(.orangeAccent)
        }.padding()
    }

    private var questionBody: some View {
        VStack {
            Text(model.question)
                .lineLimit(1)
            answers
        }
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
                    .disabled(!model.hasSelectedAnswer)
                    .opacity(model.hasSelectedAnswer ? 1 : 0.5)
            }
        }.padding(settings.navPadding)
    }

    private var progressBar: some View {
        ProgressBar(
            progress: model.progress,
            progressColor: .orangeAccent,
            backgroundColor: Styling.quizProgressBackground,
            backgroundBorder: Styling.quizProgressBorder,
            cornerRadius: settings.progressCornerRadius
        )
    }

    private var answers: some View {
        VStack {
            HStack {
                answer(option: .A)
                answer(option: .B)
            }
            HStack {
                answer(option: .C)
                answer(option: .D)
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

                Text(model.optionText(option))
                    .foregroundColor(.black)
            }
            .onTapGesture(perform: { handleAnswer(option: option) })
            .rotationEffect(shakingOption == option ? .degrees(4) : .zero)
        }.padding()
    }

    private func overlay(option: QuizOption) -> some View {
        ZStack {
            if (model.hasSelectedAnswer && model.correctOption == option) {
                Group {
                    Circle()
                        .foregroundColor(.white)

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Styling.quizAnswerCorrectBorder)
                        .scaleEffect(badgeScale)
                }
                .scaleEffect(badgeScale)
                .onAppear(perform: runBadgeAnimation)
            }
        }
        .frame(width: settings.navSize, height: settings.navSize)
        .offset(x: settings.navSize / 3, y: -settings.navSize / 3)
    }

    private func runBadgeAnimation() {
        badgeScale = 1
        withAnimation(.easeOut(duration: 0.35)) {
            badgeScale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
            withAnimation(.easeInOut(duration: 0.25)) {
                badgeScale = 1
            }
        }
    }

    private func handleAnswer(option: QuizOption) {
        guard !model.hasSelectedAnswer else {
            return
        }
        if (model.correctOption == option) {
            withAnimation(.easeOut(duration: 0.125)) {
                model.hasSelectedAnswer = true
            }
        } else {
            runShake(option: option)
        }
    }

    private func runShake(option: QuizOption) {
        let animation = Animation.spring(
            response: 0.1,
            dampingFraction: 0.125
        )
        withAnimation(animation) {
            shakingOption = option
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            withAnimation(animation) {
                shakingOption = nil
            }
        }
    }

    private func answerBackground(option: QuizOption) -> Color {
        let active = !model.hasSelectedAnswer || model.correctOption == option
        return active ? Styling.quizAnswer : Styling.quizAnswerInactive
    }

    private func answerBorder(option: QuizOption) -> Color {
        let active = model.hasSelectedAnswer && model.correctOption == option
        return active ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerBorder
    }

    private func answerLineWidth(option: QuizOption) -> CGFloat {
        let active = model.hasSelectedAnswer && model.correctOption == option
        return active ? 3 : 1
    }
}

fileprivate struct RotatedModifier: ViewModifier {

    let active: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0 : 1)
            .rotationEffect(active ? .zero : .degrees(360))
    }
}

struct QuizLayoutSettings {
    let geometry: GeometryProxy

    var progressWidth: CGFloat {
        0.8 * geometry.size.width
    }

    var progressHeight: CGFloat {
        0.06 * geometry.size.height
    }

    var progressCornerRadius: CGFloat {
        0.01 * geometry.size.height
    }

    var navSize: CGFloat {
        0.05 * geometry.size.width
    }

    var fontSize: CGFloat {
        0.04 * geometry.size.width
    }

    var navPadding: CGFloat {
        0.5 * navSize
    }

    var navTotalWidth: CGFloat {
        navSize + (2 * navPadding)
    }
}

struct QuizScreen_Previews: PreviewProvider {
    static var previews: some View {
        QuizScreen(
            model: QuizViewModel()
        ).previewLayout(.fixed(width: 568, height: 320))
    }
}
