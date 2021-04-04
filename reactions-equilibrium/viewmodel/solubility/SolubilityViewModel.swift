//
// Reactions App
//

import SwiftUI
import ReactionsCore

class SolubilityViewModel: ObservableObject {

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0

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
