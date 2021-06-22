//
// Reactions App
//


import SwiftUI

struct TitrationChartStack: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitrationPhChart(
                layout: layout,
                phase: model.reactionPhase,
                strongSubstancePreEPModel: model.strongSubstancePreEPModel,
                strongSubstancePostEPModel: model.strongSubstancePostEPModel
            )
            Spacer(minLength: 0)
            TitrationBarsOrReactionProgress(
                layout: layout,
                phase: model.reactionPhase,
                strongSubstancePreparationModel: model.strongSubstancePreparationModel,
                strongSubstancePreEPModel: model.strongSubstancePreEPModel,
                strongSubstancePostEPModel: model.strongSubstancePostEPModel
            )
        }
    }
}

