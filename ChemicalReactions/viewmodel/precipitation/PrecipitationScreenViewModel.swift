//
// Reactions App
//

import Foundation
import ReactionsCore

class PrecipitationScreenViewModel: ObservableObject {

    init() {
        self.navigation = PrecipitationNavigationModel.model(using: self)
    }

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<PrecipitationScreenState>!
}

// MARK: - Navigation
extension PrecipitationScreenViewModel {
    func next() {
        if !nextIsDisabled {
            navigation.next()
        }
    }

    func back() {
        navigation.back()
    }

    var nextIsDisabled : Bool {
        false
    }
}
