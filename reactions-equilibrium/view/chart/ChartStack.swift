//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChartStack: View {
    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    @State private var showGraph = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chartSelectionToggle
                .colorMultiply(
                    model.highlightedElements.colorMultiply(for: nil)
                )
            chartOrTable
            Spacer()
            quotientChart
        }
    }

    // Must use opacity to hide chart rather than remove from view, otherwise the animation doesn't resume
    private var chartOrTable: some View {
        ZStack(alignment: .leading) {
            concentrationChart.opacity(showGraph ? 1 : 0)
            if (!showGraph) {
                ICETable(
                    initial: model.components.equations.initialConcentrations,
                    final: model.components.equations.equilibriumConcentrations
                )
                .colorMultiply(
                    model.highlightedElements.colorMultiply(for: nil)
                )
            }
        }.frame(
            width: settings.chartSettings.totalChartWidth,
            height: settings.chartSettings.totalChartHeight,
            alignment: .leading
        )
    }

    private var concentrationChart: some View {
        MultiConcentrationPlot(
            equations: model.components.equations.reactions,
            equilibriumTime: model.components.equations.convergenceTime,
            discontinuities: model.components.moleculeChartDiscontinuities,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            showData: model.showConcentrationLines,
            offset: model.chartOffset,
            minDragTime: model.components.quotientChartDiscontinuity?.x,
            canSetIndex: model.canSetChartIndex,
            activeIndex: $model.activeChartIndex,
            settings: settings.chartSettings
        )
        .colorMultiply(
            model.highlightedElements.colorMultiply(for: .chartEquilibrium)
        )
    }

    private var quotientChart: some View {
        QuotientPlot(
            equation: model.quotientEquation,
            initialTime: 0,
            currentTime: $model.currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: model.canSetCurrentTime,
            equilibriumTime: model.equations.convergenceTime,
            showData: model.showQuotientLine,
            offset: model.chartOffset,
            discontinuity: model.components.quotientChartDiscontinuity,
            settings: settings.quotientChartSettings(
                convergenceQ: model.convergenceQuotient,
                maxQ: model.maxQuotient
            )
        )
        .colorMultiply(
            model.highlightedElements.colorMultiply(for: .chartEquilibrium)
        )
    }

    private var chartSelectionToggle: some View {
        HStack {
            selectionToggleText(isGraph: true)
            Spacer()
            selectionToggleText(isGraph: false)
            Spacer()
        }
        .frame(
            width: settings.chartSize,
            height: settings.chartSelectionHeight
        )
        .padding(.leading, settings.chartSettings.yAxisWidthLabelWidth)
        .padding(.bottom, settings.chartSelectionBottomPadding)
        .font(.system(size: settings.chartSelectionFontSize))
    }

    private func selectionToggleText(isGraph: Bool) -> some View {
        SelectionToggleText(
            text: isGraph ? "Graph" : "Table",
            isSelected: showGraph == isGraph,
            action: { showGraph = isGraph }
        )
    }
}
