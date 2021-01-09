//
// Reactions App
//
  

import SwiftUI

struct QuizIntroBody: View {

    let settings: QuizLayoutSettings
    @ObservedObject var model: QuizViewModel

    var body: some View {
        VStack {
            Text("Let's take a quiz!")
                .font(.system(size: settings.fontSize))
            Text("Choose the difficulty level of the quiz")
                .font(.system(size: 0.7 * settings.fontSize))
            HStack {
                Spacer()
                Button(action: model.skip) {
                    Text("Skip Quiz")
                        .font(.system(size: settings.skipFontSize, weight: .medium))
                        .foregroundColor(.orangeAccent)
                }
            }
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

        return ZStack {
            RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                .foregroundColor(isSelected ? Styling.quizActiveBlue : .white)
                .shadow(radius: 2)

            if (isSelected) {
                RoundedRectangle(cornerRadius: settings.progressCornerRadius)
                    .strokeBorder(lineWidth: settings.activeLineWidth)
                    .foregroundColor(Styling.quizActiveDarkBlue)
            }

            Text(difficulty.displayName)
                .font(.system(size: settings.fontSize, weight: .bold))
                .foregroundColor(
                    isSelected ? Styling.quizActiveDarkBlue : .black
                )
            questionCount(count)
                .foregroundColor(
                    isSelected ? Styling.quizActiveDarkBlue : Styling.inactiveScreenElement
                )
        }.onTapGesture {
            model.quizDifficulty = difficulty
        }
    }

    private func questionCount(_ count: Int) -> some View {
        VStack {
            Spacer()
            HStack {
                Text("\(count) questions")
                    .font(.system(size: 0.55 * settings.fontSize, weight: .semibold))
                    .padding(2 * settings.progressCornerRadius)
                Spacer()
            }
        }
    }
}

fileprivate extension QuizDifficulty {
    var displayName: String {
        switch (self) {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}
