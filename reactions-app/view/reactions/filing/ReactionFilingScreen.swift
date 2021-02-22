//
// Reactions App
//

import SwiftUI

struct ReactionFilingScreen: View {

    @ObservedObject var model: ReactionFilingViewModel

    var body: some View {
        GeometryReader { geo in
            PageViewController(
                pages: [
                    getView(.A, geo: geo),
                    getView(.B, geo: geo),
                    getView(.C, geo: geo)
                ],
                currentPage: $model.currentPage
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func getView(
        _ reactionType: ReactionType,
        geo: GeometryProxy
    ) -> some View {
        CompletedReactionScreen(
            enabled: model.enabled(reactionType: reactionType),
            disabledStatement: ReactionFilingStatements.pageNotEnabledMessage(order: model.order)
        ) {
            model.makeView(reactionType: reactionType)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct CompletedReactionScreen<Content: View>: View {

    let enabled: Bool
    let disabledStatement: String
    var content: () -> Content

    var body: some View {
        ZStack {
            content()
                .blur(radius: enabled ? 0 : 8)
                .disabled(!enabled)
            if !enabled {
                Text(disabledStatement)
                    .font(.headline)
            }
        }
    }
}
