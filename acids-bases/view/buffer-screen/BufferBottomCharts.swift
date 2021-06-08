//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferBottomCharts: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    @State private var selected = SelectedGraph.bars

    var body: some View {
        VStack(spacing: 0) {
            toggle
            BufferBarChart(
                layout: layout,
                phase: model.phase,
                model1: model.weakSubstanceModel,
                model2: model.phase2Model
            )
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
        _ selection: SelectedGraph,
        disabled: Bool
    ) -> some View {
        SelectionToggleText(
            text: selection.name,
            isSelected: selected == selection,
            action: { selected = selection }
        )
        .disabled(disabled)
    }

    enum SelectedGraph: String {
        case curve, bars, neutralization

        var name: String {
            self.rawValue.capitalized
        }
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
        default: return model1.barChartData
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
