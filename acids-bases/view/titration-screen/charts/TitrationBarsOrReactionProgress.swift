//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBarsOrReactionProgress: View {

    let layout: TitrationScreenLayout
    let phase: TitrationViewModel.ReactionPhase
    @ObservedObject var strongSubstancePreparationModel: TitrationStrongSubstancePreparationModel
    @ObservedObject var strongSubstancePreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongSubstancePostEPModel: TitrationStrongSubstancePostEPModel

    var body: some View {
        BarChart(
            data: data,
            time: equationInput,
            settings: layout.common.barChartSettings
        )
    }

    private var data: [BarChartData] {
        switch phase {
        case .strongSubstancePreparation: return strongSubstancePreparationModel.barChartData
        case .strongSubstancePreEP: return strongSubstancePreEPModel.barChartData
        case .strongSubstancePostEP: return strongSubstancePostEPModel.barChartData
        }
    }

    private var equationInput: CGFloat {
        switch phase {
        case .strongSubstancePreparation: return CGFloat(strongSubstancePreparationModel.substanceAdded)
        case .strongSubstancePreEP: return CGFloat(strongSubstancePreEPModel.substanceAdded)
        case .strongSubstancePostEP: return CGFloat(strongSubstancePostEPModel.titrantAdded)
        }
    }
}
