//
// Reactions App
//
  

import SwiftUI

struct QuizReviewBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    var body: some View {
        ScrollView {
                VStack(spacing: 20) {
                    heading
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(0..<filteredQuestions.count) { index in
                        reviewCard(index: index)
                    }
                }
                .frame(width: settings.contentWidth)
                .padding(.top, settings.progressBarPadding)
                .padding(.bottom, settings.geometry.safeAreaInsets.bottom + 10)
                .frame(width: settings.width)
        }
    }

    private var filteredQuestions: [QuizQuestion] {
        model.availableQuestions.filter {
            model.selectedAnswer(id: $0.id) != nil
        }
    }

    private var correctCount: Int {
        filteredQuestions.filter {  q in
            model.selectedAnswer(id: q.id)!.firstAnswer == q.correctOption
        }.count
    }

    private var heading: some View {
        let header = "You got \(correctCount) correct out of \(filteredQuestions.count)"
        let subHeader = "Let's review the questions!"

        return HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 5) {
                Text(header)
                Text(subHeader)
                    .font(.system(size: settings.h2FontSize))
            }
            .accessibilityElement()
            .accessibility(addTraits: .isHeader)
            .accessibility(label: Text("\(header), \(subHeader)"))
            Spacer()
        }
    }

    private func reviewCard(
        index: Int
    ) -> some View {
        let question = filteredQuestions[index]
        return QuestionReviewCard(
            question: question,
            answer: model.selectedAnswer(id: question.id)!,
            settings: settings,
            questionNumber: index + 1,
            totalQuestions: filteredQuestions.count
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

fileprivate struct QuestionReviewCard: View {

    let question: QuizQuestion
    let answer: QuizAnswerInput
    let settings: QuizLayoutSettings

    let questionNumber: Int
    let totalQuestions: Int

    @State private var explanationIsExpanded: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Spacer()
                }
                QuizQuestionView(
                    question: question,
                    settings: settings,
                    tableWidth: settings.tableWidthReviewCard
                )
                .accessibility(label: Text(label))
                .accessibility(addTraits: .isHeader)

                ForEach(answer.allAnswers, id: \.self) { option in
                    optionLine(
                        option: option,
                        topLine: "Your answer"
                    )
                }
            }
            .padding(4 * settings.questionReviewPadding)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, settings.questionReviewPadding)
        .font(.system(size: settings.questionFontSize))
        .background(reviewBackground)
    }

    private var label: String {
        let correct = isCorrect ? "correct" : "incorrect"
        let prefix = "Question \(questionNumber) of \(totalQuestions), \(correct)"
        return "\(prefix). \(question.question.asString)"
    }

    private func optionLine(
        option: QuizOption,
        topLine: String
    ) -> some View {
        let optionIsCorrect = question.correctOption == option
        let topLine = optionIsCorrect && !isCorrect ? "Correct answer" : "Your answer"
        return QuizReviewSingleOption(
            question: question,
            topLine: topLine,
            option: option,
            settings: settings
        )
    }

    private var reviewBackground: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .foregroundColor(.white)
            .shadow(radius: 3)

            RoundedRectangle(
                cornerRadius: settings.progressCornerRadius
            )
            .strokeBorder(lineWidth: 2)
            .foregroundColor(borderColor)

            QuizAnswerIconOverlay(isCorrect: isCorrect)
                .frame(width: 30, height: 30)
                .offset(x: 10, y: -10)
                .accessibility(hidden: true)
        }
    }

    private var borderColor: Color {
        isCorrect ? Styling.Quiz.correctAnswerBorder : Styling.Quiz.wrongAnswerBorder
    }

    private var isCorrect: Bool {
        answer.firstAnswer == question.correctOption
    }
}


fileprivate struct QuizReviewSingleOption: View {

    let question: QuizQuestion
    let topLine: String
    let option: QuizOption
    let settings: QuizLayoutSettings

    @State private var explanationIsExpanded: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let answer = question.options[option]?.answer ?? ""
        let fullLine = answer.prepending(TextSegment(content: "\(topLine): "))


        return VStack(alignment: .leading, spacing: 0) {
            TextLinesView(
                line: fullLine,
                fontSize: settings.questionFontSize,
                color: isCorrect ?
                    Styling.Quiz.reviewCorrectAnswerFont : Styling.Quiz.reviewWrongAnswerFont
            )

            Button(action: handleExplanationPress) {
                Text(explanationIsExpanded ? "Hide Explanation" : "Show Explanation")
                    .font(.system(size: settings.questionFontSize))
            }

            if (explanationIsExpanded) {
                TextLinesView(
                    lines: [explanationString],
                    fontSize: settings.questionFontSize
                )
            }

        }
        .minimumScaleFactor(1)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func handleExplanationPress() {
        withAnimation( reduceMotion ? nil : .easeOut(duration: 0.2)) {
            explanationIsExpanded.toggle()
        }
    }

    private var explanationString: TextLine {
        question.options[option]?.explanation ?? ""
    }

    private var isCorrect: Bool {
        option == question.correctOption
    }
}
