//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChartStack: View {

    let components: ReactionComponents
    let initialParams: MoleculeValue<CGFloat>
    let finalParams: MoleculeValue<CGFloat>
    @Binding var currentTime: CGFloat
    let chartOffset: CGFloat
    let canSetCurrentTime: Bool
    let canSetChartIndex: Bool
    let showConcentrationLines: Bool
    let showQuotientLine: Bool
    let maxQuotient: CGFloat
    let settings: AqueousScreenLayoutSettings
    let equilibriumQuotient: CGFloat
    @Binding var activeChartIndex: Int?

    let generalElementHighlight: Color
    let equilibriumHighlight: Color

    let topChartYLabel: String

    @State private var showGraph = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chartSelectionToggle
                .colorMultiply(generalElementHighlight)
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
                    initial: initialParams,
                    final: finalParams
                )
                .colorMultiply(generalElementHighlight)
            }
        }.frame(
            width: settings.chartSettings.totalChartWidth,
            height: settings.chartSettings.totalChartHeight,
            alignment: .leading
        )
    }

    private var concentrationChart: some View {
        MultiConcentrationPlot(
            equations: components.equation.concentration,
            equilibriumTime: components.equation.equilibriumTime,
            discontinuities: components.moleculeChartDiscontinuities,
            initialTime: 0,
            currentTime: $currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: canSetCurrentTime,
            showData: showConcentrationLines,
            offset: chartOffset,
            minDragTime: components.quotientChartDiscontinuity?.x,
            canSetIndex: canSetChartIndex,
            activeIndex: $activeChartIndex,
            yLabel: topChartYLabel,
            settings: settings.chartSettings
        )
        .colorMultiply(equilibriumHighlight)
    }

    private var quotientChart: some View {
        QuotientPlot(
            equation: components.quotientEquation,
            initialTime: 0,
            currentTime: $currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: canSetCurrentTime,
            equilibriumTime: components.equation.equilibriumTime,
            showData: showQuotientLine,
            offset: chartOffset,
            discontinuity: components.quotientChartDiscontinuity,
            settings: settings.quotientChartSettings(
                convergenceQ: equilibriumQuotient,
                maxQ: maxQuotient
            )
        )
        .colorMultiply(equilibriumHighlight)
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

extension ChartStack {
    init(
        model: AqueousReactionViewModel,
        currentTime: Binding<CGFloat>,
        activeChartIndex: Binding<Int?>,
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            components: model.components,
            initialParams: model.components.equation.initialConcentrations,
            finalParams: model.components.equation.equilibriumConcentrations,
            currentTime: currentTime,
            chartOffset: model.chartOffset,
            canSetCurrentTime: model.canSetCurrentTime,
            canSetChartIndex: model.canSetChartIndex,
            showConcentrationLines: model.showConcentrationLines,
            showQuotientLine: model.showQuotientLine,
            maxQuotient: model.maxQuotient,
            settings: settings,
            equilibriumQuotient: model.convergenceQuotient,
            activeChartIndex: activeChartIndex,
            generalElementHighlight: model.highlightedElements.colorMultiply(for: nil),
            equilibriumHighlight: model.highlightedElements.colorMultiply(for: .chartEquilibrium),
            topChartYLabel: "Concentration"
        )
    }

    init(
        model: GaseousReactionViewModel,
        currentTime: Binding<CGFloat>,
        activeChartIndex: Binding<Int?>,
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            components: model.components,
            initialParams: model.components.equation.initialConcentrations.map {
                $0 * GaseousReactionSettings.pressureToConcentration
            },
            finalParams: model.components.equation.equilibriumConcentrations.map {
                $0 * GaseousReactionSettings.pressureToConcentration
            },
            currentTime: currentTime,
            chartOffset: model.chartOffset,
            canSetCurrentTime: model.canSetCurrentTime,
            canSetChartIndex: model.canSetChartIndex,
            showConcentrationLines: model.showConcentrationLines,
            showQuotientLine: model.showQuotientLine,
            maxQuotient: model.maxQuotient,
            settings: settings,
            equilibriumQuotient: model.equilibriumQuotientForAxis,
            activeChartIndex: activeChartIndex,
            generalElementHighlight: model.highlightedElements.colorMultiply(for: nil),
            equilibriumHighlight: model.highlightedElements.colorMultiply(for: .chartEquilibrium),
            topChartYLabel: "Pressure"
        )
    }
}
