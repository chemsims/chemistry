//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBarsOrReactionProgress: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    @State private var showBarChart = true

    var body: some View {
        VStack(spacing: 0) {
//            TitrationBarChart(layout: layout, model: model)
            TitrationReactionProgressChart(layout: layout, model: model)
            toggle
        }
    }

    private var toggle: some View {
        HStack {
            SelectionToggleText(
                text: "Bars",
                isSelected: showBarChart,
                action: { showBarChart = true }
            )

            SelectionToggleText(
                text: "Neutralization",
                isSelected: !showBarChart,
                action: { showBarChart = false }
            )
        }
        .font(.system(size: layout.common.toggleFontSize))
        .frame(height: layout.common.toggleHeight)
        .frame(width: layout.common.chartSize)
        .minimumScaleFactor(0.1)
        .lineLimit(1)
    }
}

private struct TitrationReactionProgressChart: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    @ObservedObject var strongPrepModel: TitrationStrongSubstancePreparationModel
    @ObservedObject var strongPreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongPostEPModel: TitrationStrongSubstancePostEPModel
    @ObservedObject var weakPreparationModel: TitrationWeakSubstancePreparationModel
    @ObservedObject var weakPreEPModel: TitrationWeakSubstancePreEPModel
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    var body: some View {
        ReactionProgressChart(
            model: reactionProgressModel,
            geometry: layout.common.reactionProgressGeometry
        )
    }

    private var reactionProgressModel: ReactionProgressChartViewModel<PrimaryIon> {
        switch model.components.state.phase {
        case .preparation: return strongPrepModel.reactionProgress
        case .preEP: return strongPreEPModel.reactionProgress
        case .postEP: return strongPostEPModel.reactionProgress
        }
    }
}

private struct TitrationBarChart: View {
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


extension TitrationReactionProgressChart {
    init(
        layout: TitrationScreenLayout,
        model: TitrationViewModel
    ) {
        self.init(
            layout: layout,
            model: model,
            strongPrepModel: model.components.strongSubstancePreparationModel,
            strongPreEPModel: model.components.strongSubstancePreEPModel,
            strongPostEPModel: model.components.strongSubstancePostEPModel,
            weakPreparationModel: model.components.weakSubstancePreparationModel,
            weakPreEPModel: model.components.weakSubstancePreEPModel,
            weakPostEPModel: model.components.weakSubstancePostEPModel
        )
    }
}

extension TitrationBarChart {
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
