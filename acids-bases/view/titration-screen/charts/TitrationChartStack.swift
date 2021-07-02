//
// Reactions App
//


import SwiftUI

struct TitrationChartStack: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            TitrationPhChart(
                layout: layout,
                state: model.components.state,
                strongSubstancePreEPModel: model.components.strongSubstancePreEPModel,
                strongSubstancePostEPModel: model.components.strongSubstancePostEPModel,
                weakPreEPModel: model.components.weakSubstancePreEPModel,
                weakPostEPModel: model.components.weakSubstancePostEPModel
            )
            Spacer(minLength: 0)
            TitrationBarsOrReactionProgress(
                layout: layout,
                model: model
            )
        }
    }
}

