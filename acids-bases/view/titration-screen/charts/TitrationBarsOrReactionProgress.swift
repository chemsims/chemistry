//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBarsOrReactionProgress: View {

    let layout: TitrationScreenLayout
    let state: TitrationComponentState.State
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
        switch state.phase {
        case .preparation: return strongSubstancePreparationModel.barChartData
        case .preEP: return strongSubstancePreEPModel.barChartData
        case .postEP: return strongSubstancePostEPModel.barChartData
        }
    }

    private var equationInput: CGFloat {
        switch state.phase {
        case .preparation: return CGFloat(strongSubstancePreparationModel.substanceAdded)
        case .preEP: return CGFloat(strongSubstancePreEPModel.titrantAdded)
        case .postEP: return CGFloat(strongSubstancePostEPModel.titrantAdded)
        }
    }
}
