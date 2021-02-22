//
// Reactions App
//

import SwiftUI

struct ReactionFilingCabinetScreen: View {

    @ObservedObject var model: ReactionPagingViewModel

    var body: some View {
        VStack {
            PageViewController(pages: model.pages, currentPage: $model.currentPage)
        }
    }
}
