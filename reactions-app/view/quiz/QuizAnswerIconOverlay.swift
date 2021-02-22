//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct QuizAnswerIconOverlay: View {
    let isCorrect: Bool

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(
                    isCorrect ? Styling.Quiz.correctAnswerBorder : Styling.Quiz.wrongAnswerBorder
                )
        }
    }
}
