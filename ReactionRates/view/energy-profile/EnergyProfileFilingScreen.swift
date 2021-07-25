//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EnergyProfileFilingScreen: View {

    @ObservedObject var model: EnergyProfileFilingViewModel

    var body: some View {
        GeometryReader { geo in
            PageViewController(
                pages: [
                    view(index: 0, geo: geo),
                    view(index: 1, geo: geo),
                    view(index: 2, geo: geo)
                ],
                currentPage: $model.page
            )
        }
    }

    private func view(index: Int, geo: GeometryProxy) -> some View {
        EnergyProfileScreen(
            navigation: model.navigation(index: index)
        )
        .frame(width: geo.size.width, height: geo.size.height)
    }
}

struct EnergyProfileFilingScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileFilingScreen(
            model: EnergyProfileFilingViewModel(
                persistence: InMemoryEnergyProfilePersistence()
            )
        )
    }
}
