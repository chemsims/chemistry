//
// Reactions App
//

import SwiftUI
import ReactionsCore

class SolubilityViewModel: ObservableObject {
    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    init() {
        self.navigation = SolubilityNavigationModel.model(model: self)
    }

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }
}
