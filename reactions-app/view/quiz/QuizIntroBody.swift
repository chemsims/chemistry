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
