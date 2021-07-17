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
                weakModel: model.weakSubstanceModel,
                saltModel: model.saltModel,
                strongModel: model.strongSubstanceModel
            )
            .padding(.leading, leadingPaddingForChartWithoutYAxis)
            .colorMultiply(model.highlights.colorMultiply(for: nil))

        case .curve:
            BufferFractionsChart(
                layout: layout,
                phase: model.phase,
                model: model,
                saltModel: model.saltModel,
                strongModel: model.strongSubstanceModel
            )
            .background(
                Color.white
                    .padding(.trailing, -0.05 * layout.common.chartSize)
                    .padding(.bottom, fractionChartHighlightBottomPadding)

            )
            .colorMultiply(
                model.highlights.colorMultiply(for: .fractionChart)
            )


        case .neutralization:
            BufferReactionProgressChart(
                layout: layout,
                phase: model.phase,
                weakModel: model.weakSubstanceModel,
                saltModel: model.saltModel,
                strongModel: model.strongSubstanceModel
            )
            .padding(.leading, leadingPaddingForChartWithoutYAxis)
            .colorMultiply(model.highlights.colorMultiply(for: nil))
        }
    }

    private var fractionChartHighlightBottomPadding: CGFloat {
        let barAxisHeight = layout.common.barChartSettings.totalAxisHeight
        let axisHeight = layout.common.chartXAxisHeight + layout.common.chartXAxisVSpacing

        let difference = barAxisHeight - axisHeight
        return max(0, difference)
    }

    private var leadingPaddingForChartWithoutYAxis: CGFloat {
        layout.common.chartYAxisWidth + layout.common.chartYAxisHSpacing
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
        .colorMultiply(model.highlights.colorMultiply(for: nil))
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

private struct BufferReactionProgressChart: View {

    let layout: BufferScreenLayout
    let phase: BufferScreenViewModel.Phase
    @ObservedObject var weakModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongModel: BufferStrongSubstanceComponents

    var body: some View {
        ReactionProgressChart(
            model: model,
            geometry: layout.common.reactionProgressGeometry(SubstancePart.self)
        )
    }

    private var model: ReactionProgressChartViewModel<SubstancePart> {
        switch phase {
        case .addWeakSubstance: return weakModel.reactionProgress
        case .addSalt: return saltModel.reactionProgress
        case .addStrongSubstance: return strongModel.reactionProgress
        }
    }
}

private struct BufferBarChart: View {

    let layout: BufferScreenLayout
    let phase: BufferScreenViewModel.Phase
    @ObservedObject var weakModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongModel: BufferStrongSubstanceComponents

    var body: some View {
        BarChart(
            data: data,
            time: barCharInput,
            settings: layout.common.barChartSettings
        )
    }

    private var data: [BarChartData] {
        switch phase {
        case .addWeakSubstance: return weakModel.barChartData
        case .addSalt: return saltModel.barChartData
        case .addStrongSubstance: return strongModel.barChartData
        }
    }

    private var barCharInput: CGFloat {
        switch phase {
        case .addWeakSubstance: return weakModel.progress
        case .addSalt: return CGFloat(saltModel.substanceAdded)
        case .addStrongSubstance: return CGFloat(strongModel.substanceAdded)
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
                        model: BufferScreenViewModel(
                            namePersistence: InMemoryNamePersistence()
                        )
                    )
                    Spacer()
                }
                Spacer()
            }
        }
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
