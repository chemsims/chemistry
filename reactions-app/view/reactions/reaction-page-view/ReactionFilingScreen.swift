//
// Reactions App
//
  

import SwiftUI

struct ReactionFilingScreen: View {

    @ObservedObject var model: ReactionFilingViewModel

    var body: some View {
        PageViewController(pages: model.pages, currentPage: $model.currentPage)
    }
}

struct CompletedReactionScreen<Content: View>: View {

    let enabled: Bool
    var content: () -> Content

    var body: some View {
        ZStack {
            content()
                .blur(radius: enabled ? 0 : 8)
                .disabled(!enabled)
            if (!enabled) {
                Text("Finish more of the app, and then come back here to take a look at your reaction!")
            }
        }
    }
}
