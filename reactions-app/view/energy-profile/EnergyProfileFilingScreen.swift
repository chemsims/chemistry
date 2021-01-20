//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileFilingScreen: View {

    @ObservedObject var model: EnergyProfileFilingViewModel

    var body: some View {
        PageViewController(
            pages: [
                EnergyProfileScreen(navigation: model.navigation(index: 0)),
                EnergyProfileScreen(navigation: model.navigation(index: 1)),
                EnergyProfileScreen(navigation: model.navigation(index: 2))
            ],
            currentPage: $model.page
        )
    }

    private var nav: NavigationViewModel<EnergyProfileState> {
        EnergyProfileNavigationViewModel.model(EnergyProfileViewModel())
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
