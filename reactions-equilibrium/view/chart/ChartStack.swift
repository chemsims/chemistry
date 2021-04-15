//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChartStack: View {

    let concentrationData: [MultiConcentrationPlotData]
    let tableColumns: [ICETableColumn]
    let equilibriumTime: CGFloat
    let quotientEquation: Equation
    @Binding var currentTime: CGFloat
    let quotientChartDiscontinuity: CGPoint?
    let chartOffset: CGFloat
    let canSetCurrentTime: Bool
    let canSetChartIndex: Bool
    let showConcentrationLines: Bool
    let showQuotientLine: Bool
    let maxQuotient: CGFloat
    let settings: AqueousScreenLayoutSettings
    let equilibriumQuotient: CGFloat

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
                    columns: tableColumns
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
            values: concentrationData,
            equilibriumTime: equilibriumTime,
            initialTime: 0,
            currentTime: $currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: canSetCurrentTime,
            showData: showConcentrationLines,
            offset: chartOffset,
            minDragTime: quotientChartDiscontinuity?.x,
            canSetIndex: canSetChartIndex,
            yLabel: topChartYLabel,
            settings: settings.chartSettings
        )
        .colorMultiply(equilibriumHighlight)
    }

    private var quotientChart: some View {
        QuotientPlot(
            equation: quotientEquation,
            initialTime: 0,
            currentTime: $currentTime,
            finalTime: AqueousReactionSettings.forwardReactionTime,
            canSetCurrentTime: canSetCurrentTime,
            equilibriumTime: equilibriumTime,
            showData: showQuotientLine,
            offset: chartOffset,
            discontinuity: quotientChartDiscontinuity,
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
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            concentrationData: model.components.concentrationData,
            tableColumns: model.components.tableData(),
            equilibriumTime: model.components.equilibriumTime,
            quotientEquation: model.components.quotientEquation,
            currentTime: currentTime,
            quotientChartDiscontinuity: model.components.quotientChartDiscontinuity,
            chartOffset: model.chartOffset,
            canSetCurrentTime: model.canSetCurrentTime,
            canSetChartIndex: true,
            showConcentrationLines: model.showConcentrationLines,
            showQuotientLine: model.showQuotientLine,
            maxQuotient: model.maxQuotient,
            settings: settings,
            equilibriumQuotient: model.convergenceQuotient,
            generalElementHighlight: model.highlightedElements.colorMultiply(for: nil),
            equilibriumHighlight: model.highlightedElements.colorMultiply(for: .chartEquilibrium),
            topChartYLabel: "Concentration"
        )
    }

    init(
        model: GaseousReactionViewModel,
        currentTime: Binding<CGFloat>,
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            concentrationData: model.components.concentrationData,
            tableColumns: model.components.tableData(factor: GaseousReactionSettings.pressureToConcentration),
            equilibriumTime: model.components.equilibriumTime,
            quotientEquation: model.components.quotientEquation,
            currentTime: currentTime,
            quotientChartDiscontinuity: model.components.quotientChartDiscontinuity,
            chartOffset: model.chartOffset,
            canSetCurrentTime: model.canSetCurrentTime,
            canSetChartIndex: true,
            showConcentrationLines: model.showConcentrationLines,
            showQuotientLine: model.showQuotientLine,
            maxQuotient: model.maxQuotient,
            settings: settings,
            equilibriumQuotient: model.equilibriumQuotientForAxis,
            generalElementHighlight: model.highlightedElements.colorMultiply(for: nil),
            equilibriumHighlight: model.highlightedElements.colorMultiply(for: .chartEquilibrium),
            topChartYLabel: "Pressure"
        )
    }

    init(
        model: SolubilityViewModel,
        currentTime: Binding<CGFloat>,
        settings: AqueousScreenLayoutSettings
    ) {
        self.init(
            concentrationData: model.components.concentrationData(reaction: model.selectedReaction),
            tableColumns: model.components.tableData(reaction: model.selectedReaction),
            equilibriumTime: 20,
            quotientEquation: model.components.quotient,
            currentTime: currentTime,
            quotientChartDiscontinuity: model.components.quotientDiscontinuity,
            chartOffset: model.chartOffset,
            canSetCurrentTime: false,
            canSetChartIndex: true,
            showConcentrationLines: true,
            showQuotientLine: true,
            maxQuotient: 0.1,
            settings: settings,
            equilibriumQuotient: 0.1,
            generalElementHighlight: model.highlights.colorMultiply(for: nil),
            equilibriumHighlight: model.highlights.colorMultiply(for: .chartEquilibrium),
            topChartYLabel: "Concentration"
        )
    }
}

private extension SolubilityComponents {
    func concentrationData(reaction: SolubleReactionType) -> [MultiConcentrationPlotData] {
        SoluteValues(builder: { element in
            MultiConcentrationPlotData(
                equation: equation.concentration.value(for: element),
                color: element.color,
                discontinuity: concentrationDiscontinuity?.value(for: element),
                legendValue: reaction.product(for: element)
            )
        }).all
    }

    func tableData(reaction: SolubleReactionType) -> [ICETableColumn] {
        SoluteValues(builder: { element in
            ICETableColumn(
                header: reaction.product(for: element),
                initialValue: equation.initialConcentration.value(for: element),
                finalValue: equation.finalConcentration.value(for: element)
            )
        }).all
    }
}

private extension SolubleReactionType {
    func product(for element: SoluteProductType) -> String {
        element == .A ? products.first : products.second
    }
}

private extension ReactionComponents {
    var concentrationData: [MultiConcentrationPlotData] {
        MoleculeValue(builder: { molecule in
            MultiConcentrationPlotData(
                equation: equation.concentration.value(for: molecule),
                color: molecule.color,
                discontinuity: moleculeChartDiscontinuities?.value(for: molecule),
                legendValue: molecule.rawValue
            )
        }).all
    }

    func tableData(factor: CGFloat = 1) -> [ICETableColumn] {
        MoleculeValue(builder: { molecule in
            ICETableColumn(
                header: molecule.rawValue,
                initialValue: equation.initialConcentrations.map{ $0 * factor }.value(for: molecule),
                finalValue: equation.equilibriumConcentrations.map{ $0 * factor }.value(for: molecule)
            )
        }).all
    }
}
