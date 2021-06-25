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
    @ObservedObject var weakPreparationModel: TitrationWeakSubstancePreparationModel
    @ObservedObject var weakPreEPModel: TitrationWeakSubstancePreEPModel
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    var body: some View {
        BarChart(
            data: data,
            time: equationInput,
            settings: layout.common.barChartSettings
        )
    }

    private var data: [BarChartData] {
        let isStrong = state.substance.isStrong
        switch state.phase {
        case .preparation where isStrong: return strongSubstancePreparationModel.barChartData
        case .preEP where isStrong: return strongSubstancePreEPModel.barChartData
        case .postEP where isStrong: return strongSubstancePostEPModel.barChartData

        case .preparation: return weakPreparationModel.barChartData
        case .preEP: return weakPreEPModel.barChartData
        case .postEP: return weakPostEPModel.barChartData
        }
    }

    private var equationInput: CGFloat {
        let isStrong = state.substance.isStrong

        switch state.phase {
        case .preparation where isStrong: return CGFloat(strongSubstancePreparationModel.substanceAdded)
        case .preEP where isStrong: return CGFloat(strongSubstancePreEPModel.titrantAdded)
        case .postEP where isStrong: return CGFloat(strongSubstancePostEPModel.titrantAdded)

        case .preparation: return weakPreparationModel.reactionProgress
        case .preEP: return CGFloat(weakPreEPModel.titrantAdded)
        case .postEP: return CGFloat(weakPostEPModel.titrantAdded)
        }
    }
}

extension TitrationBarsOrReactionProgress {
    init(
        layout: TitrationScreenLayout,
        model: TitrationViewModel
    ) {
        self.init(
            layout: layout,
            state: model.components.state,
            strongSubstancePreparationModel: model.components.strongSubstancePreparationModel,
            strongSubstancePreEPModel: model.components.strongSubstancePreEPModel,
            strongSubstancePostEPModel: model.components.strongSubstancePostEPModel,
            weakPreparationModel: model.components.weakSubstancePreparationModel,
            weakPreEPModel: model.components.weakSubstancePreEPModel,
            weakPostEPModel: model.components.weakSubstancePostEPModel
        )
    }
}
