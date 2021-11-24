//
// Reactions App
//

import SwiftUI
import ReactionsCore

class LimitingReagentFilingCabinetScreenViewModel: LimitingReagentScreenViewModel {

    override init(persistence: LimitingReagentPersistence) {
        super.init(persistence: persistence)
        self.navigation = LimitingReagentNavigationModel.filingCabinetModel(using: self, persistence: persistence)
    }

    // We don't block next at all in the filing cabinet
    override var nextIsDisabled: Bool {
        false
    }
}
