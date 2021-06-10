//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferBottomCharts: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        VStack(spacing: 0) {
            toggle
            chart
        }
    }

    @ViewBuilder
    private var chart: some View {
        switch model.selectedBottomGraph {
        case .bars:
            BufferBarChart(
                layout: layout,
                phase: model.phase,
                model1: model.weakSubstanceModel,
                model2: model.saltComponents
            )
        case .curve:
            BufferFractionsChart(
                layout: layout,
                model: model.saltComponents
            )
        case .neutralization:
            Text("neutralization chart")
        }
    }

    private var toggle: some View {
        HStack {
            text(.bars, disabled: false)
            text(.curve, disabled: model.phase == .addWeakSubstance)
            text(.neutralization, disabled: false)
        }
        .font(.system(size: layout.common.toggleFontSize))
        .frame(height: layout.common.toggleHeight)
        .minimumScaleFactor(0.5)
    }

    private func text(
        _ selection: BufferScreenViewModel.BottomGraph,
        disabled: Bool
    ) -> some View {
        SelectionToggleText(
            text: selection.name,
            isSelected: model.selectedBottomGraph == selection,
            action: { model.selectedBottomGraph = selection }
        )
        .disabled(disabled)
    }
}

private struct BufferBarChart: View {

    let layout: BufferScreenLayout
    let phase: BufferScreenViewModel.Phase
    @ObservedObject var model1: BufferWeakSubstanceComponents
    @ObservedObject var model2: BufferSaltComponents

    var body: some View {
        BarChart(
            data: data,
            time: barCharInput,
            settings: layout.common.barChartSettings
        )
    }

    private var data: [BarChartData] {
        switch phase {
        case .addWeakSubstance: return model1.barChartData
        default: return model2.barChartData
        }
    }

    private var barCharInput: CGFloat {
        switch phase {
        case .addWeakSubstance: return model1.progress
        default: return CGFloat(model2.substanceAdded)
        }
    }
}

struct BufferBottomCharts_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    BufferBottomCharts(
                        layout: BufferScreenLayout(
                            common: AcidBasesScreenLayout(
                                geometry: geo,
                                verticalSizeClass: nil,
                                horizontalSizeClass: nil
                            )
                        ),
                        model: BufferScreenViewModel()
                    )
                    Spacer()
                }
                Spacer()
            }
        }
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
