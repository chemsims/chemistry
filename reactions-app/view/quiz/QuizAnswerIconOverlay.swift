//
// Reactions App
//
  

import SwiftUI

struct QuizAnswerIconOverlay: View {
    let isCorrect: Bool

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(isCorrect ? Styling.quizAnswerCorrectBorder : Styling.quizAnswerIncorrectBorder)
        }
    }
}
