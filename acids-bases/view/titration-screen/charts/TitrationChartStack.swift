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
                state: model.components.state,
                strongSubstancePreEPModel: model.components.strongSubstancePreEPModel,
                strongSubstancePostEPModel: model.components.strongSubstancePostEPModel
            )
            Spacer(minLength: 0)
            TitrationBarsOrReactionProgress(
                layout: layout,
                state: model.components.state,
                strongSubstancePreparationModel: model.components.strongSubstancePreparationModel,
                strongSubstancePreEPModel: model.components.strongSubstancePreEPModel,
                strongSubstancePostEPModel: model.components.strongSubstancePostEPModel
            )
        }
    }
}

