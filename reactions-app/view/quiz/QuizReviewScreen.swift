//
// Reactions App
//
  

import SwiftUI

struct QuizReviewScreen: View {

    @ObservedObject var model: QuizViewModel

    var body: some View {
        GeometryReader { geometry in
            QuizReviewScreenWithSettings(
                model: model,
                settings: QuizLayoutSettings(geometry: geometry)
            )
        }
    }
}

fileprivate struct QuizReviewScreenWithSettings: View {

    @ObservedObject var model: QuizViewModel
    let settings: QuizLayoutSettings

    var body: some View {
        VStack(alignment: .center) {
            Text("Let's take a look at the questions.")
        }
        .font(.system(size: settings.fontSize))
    }
}

struct QuizReviewScreen_Previews: PreviewProvider {
    static var previews: some View {
        QuizReviewScreen(
            model: QuizViewModel(questions: QuizQuestion.zeroOrderQuestions)
        )
    }
}
