//
// Reactions App
//

import ReactionsCore

struct AqueousNavigationModel {

    static func model(
        model: AqueousReactionViewModel
    ) -> NavigationModel<AqueousScreenState> {
        NavigationModel(
            model: model,
            states: states
        )
    }

    private static let states = [
        AqueousIntroState(),
        AqueousAddReactantState(),
        AqueousRunAnimationState(),
        AqueousEndAnimationState()
    ]

}
