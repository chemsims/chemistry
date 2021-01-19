//
// Reactions App
//
  

import SwiftUI

struct QuizQuestionView: View {

    let question: QuizQuestion
    let settings: QuizLayoutSettings
    let tableWidth: CGFloat

    var body: some View {
        VStack(spacing: 10) {
            TextLinesView(
                line: question.question,
                fontSize: settings.questionFontSize
            )
            .minimumScaleFactor(1)

            if (question.image != nil) {
                Image(question.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: settings.maxImageHeight)
            }

            if (question.table != nil) {
                QuizTableView(
                    table: question.table!,
                    fontSize: settings.questionFontSize,
                    availableWidth: tableWidth
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
