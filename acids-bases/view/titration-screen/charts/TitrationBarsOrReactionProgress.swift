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
            if showBarChart {
                TitrationBarChart(layout: layout, model: model)
            } else {
                TitrationReactionProgressChart(layout: layout, model: model)
            }
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
        Group {
            if model.components.state.substance.isStrong {
                strongReactionProgress
            } else {
                weakReactionProgress
            }
        }
    }

    private var strongReactionProgress: some View {
        TitrationSubstanceReactionProgressChart(
            layout: layout,
            phase: model.components.state.phase,
            prepModel: strongPrepModel.reactionProgress,
            preEPModel: strongPreEPModel.reactionProgress,
            postEPModel: strongPostEPModel.reactionProgress
        )
    }

    private var weakReactionProgress: some View {
        TitrationSubstanceReactionProgressChart(
            layout: layout,
            phase: model.components.state.phase,
            prepModel: weakPreparationModel.reactionProgressModel,
            preEPModel: weakPreEPModel.reactionProgress,
            postEPModel: weakPostEPModel.reactionProgress
        )
    }
}

private struct TitrationSubstanceReactionProgressChart<MoleculeType : EnumMappable>: View {

    let layout: TitrationScreenLayout
    let phase: TitrationComponentState.Phase
    @ObservedObject var prepModel: ReactionProgressChartViewModel<MoleculeType>
    @ObservedObject var preEPModel: ReactionProgressChartViewModel<MoleculeType>
    @ObservedObject var postEPModel: ReactionProgressChartViewModel<MoleculeType>

    var body: some View {
        ReactionProgressChart(
            model: model,
            geometry: layout.common.reactionProgressGeometry(MoleculeType.self)
        )
    }

    private var model: ReactionProgressChartViewModel<MoleculeType> {
        switch phase {
        case .preparation: return prepModel
        case .preEP: return preEPModel
        case .postEP: return postEPModel
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
