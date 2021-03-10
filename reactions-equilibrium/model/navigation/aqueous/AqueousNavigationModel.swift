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
        AqueousSetStatementState(statement: AqueousStatements.intro),
        AqueousHasSelectedReactionState(),
        AqueousSetStatementState(statement: AqueousStatements.explainQuotient1),
        AqueousSetStatementState(statement: AqueousStatements.explainQuotient2, highlights: [.quotientToConcentrationDefinition]),
        AqueousSetStatementState(statement: AqueousStatements.explainQuotient3, highlights: [.quotientToEquilibriumConstantDefinition]),
        AqueousSetStatementState(statement: AqueousStatements.explainQuotient4, highlights: [.quotientToConcentrationDefinition]),
        AqueousSetStatementState(statement: AqueousStatements.explainQuotient5, highlights: [.quotientToConcentrationDefinition]),
        AqueousSetStatementState(statement: AqueousStatements.explainK, highlights: [.quotientToEquilibriumConstantDefinition]),
        AqueousSetWaterLevelState(),
        AqueousAddReactantState(),
        AqueousPreRunAnimationState(),
        AqueousRunAnimationState(),
        AqueousEndAnimationState(statement: AqueousStatements.reachedEquilibrium, endTime: AqueousReactionSettings.forwardReactionTime),
        AqueousSetStatementState(statement: AqueousStatements.leChatelier),
        AqueousShiftChartState(),
        InstructToAddProductState(),
        AqueousPreReverseAnimation(),
        AqueousRunReverseAnimation(),
        AqueousEndAnimationState(
            statement: AqueousStatements.reverseEquilibriumReached,
            endTime: AqueousReactionSettings.endOfReverseReaction
        ),
        FinalAqueousState()
    ]
}
