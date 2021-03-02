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
//        AqueousSetStatementState(statement: AqueousStatements.intro),
//        AqueousSetStatementState(statement: AqueousStatements.explainEquilibrium),
//        AqueousSetStatementState(statement: AqueousStatements.explainQuotient1),
//        AqueousSetStatementState(statement: AqueousStatements.explainQuotient2),
//        AqueousSetStatementState(statement: AqueousStatements.explainQuotient3),
//        AqueousSetStatementState(statement: AqueousStatements.explainQuotient4),
//        AqueousSetStatementState(statement: AqueousStatements.explainQuotient5),
//        AqueousSetStatementState(statement: AqueousStatements.explainK),
        AqueousSetWaterLevelState(),
        AqueousAddReactantState(),
        AqueousPreRunAnimationState(),
        AqueousRunAnimationState(),
        AqueousEndAnimationState(),
        AqueousSetStatementState(statement: AqueousStatements.leChatelier),
        AqueousShiftChartState()
    ]
}
