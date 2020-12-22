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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                progressBar
                    .frame(
                        width: settings.progressWidth,
                        height: settings.progressHeight
                    )
                    .padding(settings.progressBarPadding)

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                    if (model.quizState == .pending) {
                        introBody
                    }
                    if (model.quizState == .running) {
                        questionBody
                    }

                    if (model.quizState == .completed) {
                        reviewList
                    }
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                }

                Spacer()
            }
            .edgesIgnoringSafeArea(model.quizState == .completed ? .bottom : [])
            navButtons
        }
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.8)
    }

    private var introBody: some View {
        VStack {
            Text("Let's take a quiz!")
                .font(.system(size: settings.fontSize))
            Text("Choose the difficulty level of the quiz")
                .font(.system(size: 0.8 * settings.fontSize))
                .foregroundColor(.orangeAccent)
            ForEach(QuizDifficulty.allCases, id: \.rawValue) { difficulty in
                quizDifficultyOption(difficulty: difficulty)
            }
        }
        .minimumScaleFactor(0.5)
    }

    private func quizDifficultyOption(
        difficulty: QuizDifficulty
    ) -> some View {
        let isSelected = model.quizDifficulty == difficulty
        let subline = difficulty == .skip ? "Skip this quiz" : "\(difficulty.quizLength) questions"

        return ZStack {
            RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                .foregroundColor(Styling.quizAnswer)

            RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                .stroke(lineWidth: isSelected ? activeLineWidth : standardLineWidth)
                .foregroundColor(isSelected ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerBorder)

            VStack {
                Text(difficulty.rawValue.capitalized)
                Text(subline)
                    .font(.system(size: 0.7 * settings.fontSize))
            }
        }.onTapGesture {
            model.quizDifficulty = difficulty
        }
    }

    private var reviewList: some View {
        VStack(spacing: 2) {
            HStack {
                Spacer()
                Text("Let's review the questions!")
                Spacer()
            }
            Rectangle()
                .frame(height: 1)
                .shadow(radius: 1, y: 2)
            ScrollView {
                ForEach(model.questions.prefix(model.quizDifficulty.quizLength)) { question in
                    reviewCard(question: question)
                }
            }
        }
    }

    private func reviewCard(question: QuizQuestionOptions) -> some View {
        HStack {
            Spacer()
            Text(question.question)
            Text(question.options[question.correctOption] ?? "")
                .foregroundColor(.orangeAccent)
            Spacer()
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
                progress: model.progress,
                progressColor: .orangeAccent,
                backgroundColor: Styling.quizProgressBackground,
                backgroundBorder: Styling.quizProgressBorder,
                cornerRadius: settings.progressCornerRadius
            )

            if (model.quizState == .running) {
                progressLabel
            }
        }
    }

    private var progressLabel: some View {
        Text("\(model.questionIndex + 1)/\(model.quizDifficulty.quizLength)")
        .font(.system(size: settings.progressFontSize))
        .minimumScaleFactor(0.8)
        .frame(width: settings.progressLabelWidth, height: 0.9 * settings.progressHeight)
        .background(
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(Color.white)
            .opacity(0.5)
        )
    }

    private var answers: some View {
        VStack {
            answer(option: .A)
            answer(option: .B)
            answer(option: .C)
            answer(option: .D)
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
        }
    }

    private func overlay(option: QuizOption) -> some View {
        ZStack {
            if (styleCorrect(option) || styleIncorrect(option)) {
                Group {
                    Circle()
                        .foregroundColor(.white)

                    Image(systemName: styleCorrect(option) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(styleCorrect(option) ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerIncorrectBorder)
                        .scaleEffect(badgeScale)
                }
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
        styleCorrect(option) || styleIncorrect(option) ? activeLineWidth : standardLineWidth
    }

    private func styleCorrect(_ option: QuizOption) -> Bool {
        model.selectedAnswer != nil && model.correctOption == option
    }

    private func styleIncorrect(_ option: QuizOption) -> Bool {
        model.selectedAnswer == option && model.correctOption != option
    }

    private let activeLineWidth: CGFloat = 3
    private let standardLineWidth: CGFloat = 1
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
        0.07 * geometry.size.height
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

    var progressFontSize: CGFloat {
        0.7 * fontSize
    }

    var progressLabelWidth: CGFloat {
        0.1 * progressWidth
    }

    var navPadding: CGFloat {
        0.5 * navSize
    }

    var navTotalWidth: CGFloat {
        navSize + (2 * navPadding)
    }

    var progressBarPadding: CGFloat {
        navPadding
    }

}

struct QuizScreen_Previews: PreviewProvider {
    static var previews: some View {
        QuizScreen(
            model: QuizViewModel()
        )
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
