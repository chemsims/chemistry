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
                        .frame(
                            width: settings.progressWidth,
                            height: settings.progressHeight
                        )
                        .padding(.horizontal, settings.progressBarPadding)
                        .padding(.top, settings.progressBarPadding)
                }

                if (model.quizState == .running) {
                    QuizQuestionsBody(
                        settings: settings,
                        model: model
                    )
                }

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                    if (model.quizState == .pending) {
                        QuizIntroBody(
                            settings: settings,
                            model: model
                        ).padding(.top, settings.progressBarPadding)
                    }

                    if (model.quizState == .completed) {
                        QuizReviewBody(settings: settings, model: model)
                    }
                    Spacer()
                        .frame(width: settings.navTotalWidth)
                }

                Spacer()
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
        Text("\(model.questionIndex + 1)/\(model.quizLength)")
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
}

fileprivate struct QuizIntroBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    var body: some View {
        VStack {
            Text("Let's take a quiz!")
                .font(.system(size: settings.fontSize))
            Text("Choose the difficulty level of the quiz")
                .font(.system(size: 0.8 * settings.fontSize))
                .foregroundColor(.orangeAccent)
            ForEach(model.availableDifficulties, id: \.rawValue) { difficulty in
                quizDifficultyOption(difficulty: difficulty)
            }
        }
        .minimumScaleFactor(0.5)
    }

    private func quizDifficultyOption(
        difficulty: QuizDifficulty
    ) -> some View {
        let isSelected = model.quizDifficulty == difficulty
        let count = model.difficultyCount[difficulty] ?? 0
        let subline = difficulty == .skip ? "Skip this quiz" : "\(count) questions"

        return ZStack {
            RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                .foregroundColor(Styling.quizAnswer)

            RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                .stroke(lineWidth: isSelected ? settings.activeLineWidth : settings.standardLineWidth)
                .foregroundColor(isSelected ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerBorder)

            VStack {
                Text(difficulty.displayName)
                Text(subline)
                    .font(.system(size: 0.7 * settings.fontSize))
            }
        }.onTapGesture {
            model.quizDifficulty = difficulty
        }
    }
}

fileprivate struct QuizQuestionsBody: View {

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
                    TextLinesView(line: model.question, fontSize: settings.questionFontSize)
                    answers
                }
                Spacer()
                    .frame(width: settings.navTotalWidth)
            }
            .padding(.top, settings.progressBarPadding)
            .padding(.bottom, settings.geometry.safeAreaInsets.bottom)
        }
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

                TextLinesView(
                    line: model.optionText(option),
                    fontSize: settings.answerFontSize
                )
                .foregroundColor(.black)
                .padding()
            }
            .onTapGesture(perform: { handleAnswer(option: option) })
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

fileprivate struct QuizReviewBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                heading
                ForEach(0..<model.quizLength) { index in
                    reviewCard(index: index)
                }
            }
            .padding(.top, settings.progressBarPadding)
        }
    }

    private var heading: some View {
        HStack {
            Spacer()
            VStack {
                Text("Your score is \(model.correctAnswers)/\(model.quizLength)")
                    .foregroundColor(.orangeAccent)
                Text("Let's review the questions!")
            }

            Spacer()
        }
    }

    private func reviewCard(index: Int) -> some View {
        let question = model.availableQuestions[index]
        let selectedOption = model.selectedOption(index: index)

        return ZStack(alignment: .leading) {
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(.white)
            .shadow(radius: 2)

            VStack(alignment: .leading) {
                TextLinesView(line: question.question, fontSize: settings.fontSize)
                TextLinesView(line: question.options[question.correctOption] ?? "", fontSize: settings.fontSize)
                    .foregroundColor(.orangeAccent)
                if (selectedOption != question.correctOption) {
                    incorrectAnswer(
                        question: question,
                        selectedOption: selectedOption
                    )
                }
            }.padding()
        }.padding(.horizontal, 2)
    }

    private func incorrectAnswer(
        question: QuizQuestionDisplay,
        selectedOption: QuizOption?
    ) -> some View {
        let selectedAnswer = selectedOption.flatMap { question.options[$0] } ?? ""
        return VStack(alignment: .leading) {
            HStack {
                Text("Your answer")
                TextLinesView(line: selectedAnswer, fontSize: settings.fontSize)
                    .foregroundColor(.orangeAccent)
            }
        }
    }
}

fileprivate extension QuizDifficulty {
    var displayName: String {
        switch (self) {
        case .skip: return "Skip"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
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

    var questionFontSize: CGFloat {
        0.05 * geometry.size.height
    }

    var answerFontSize: CGFloat {
        0.9 * questionFontSize
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

    var activeLineWidth: CGFloat {
        3
    }

    var standardLineWidth: CGFloat {
        1
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
