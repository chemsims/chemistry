//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferChartStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        VStack(spacing: 0) {
            tableOrGraph
            Spacer()
            bottomCharts
        }
    }

    private var tableOrGraph: some View {
        BufferPHChartOrTable(
            layout: layout,
            model: model
        )
    }

    private var bottomCharts: some View {
        BufferFractionCoords(
            layout: layout,
            model: model.phase2Model
        )
    }
}

private struct BufferFractionCoords: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferSaltComponents

    let size: CGFloat = 200

    var body: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: model.haFractionInTermsOfPH,
                    headColor: .blue,
                    haloColor: .red,
                    headRadius: layout.common.chartHeadRadius
                ),
                TimeChartDataLine(
                    equation: model.aFractionInTermsOfPH,
                    headColor: .purple,
                    haloColor: .black,
                    headRadius: layout.common.chartHeadRadius
                )
            ],
            initialTime: 0,
            currentTime: .constant(model.ph.getY(at: CGFloat(model.substanceAdded))),
            finalTime: max(1, CGFloat(2 * model.finalPH)),
            canSetCurrentTime: false,
            settings: TimeChartLayoutSettings(
                xAxis: xAxis,
                yAxis: yAxis,
                haloRadius: layout.common.haloRadius,
                lineWidth: 0.4
            ),
            axisSettings: layout.common.chartAxis
        )
        .frame(square: layout.common.chartSize)
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * chartSize,
            maxValuePosition: 0.9 * chartSize,
            minValue: 0,
            maxValue: max(1, CGFloat(2 * model.finalPH))
        )
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.9 * chartSize,
            maxValuePosition: 0.1 * chartSize,
            minValue: 0,
            maxValue: 1
        )
    }

    private var chartSize: CGFloat {
        layout.common.chartSize
    }
}

private struct BufferPHChartOrTable: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    @State private var showingTable = false

    var body: some View {
        VStack(spacing: layout.common.toggleHeight) {
            toggle
            if showingTable {
                table
            } else {
                graph
            }
        }
    }

    private var toggle: some View {
        HStack {
            SelectionToggleText(
                text: "Graph",
                isSelected: !showingTable,
                action: { showingTable = false }
            )
            SelectionToggleText(
                text: "Table",
                isSelected: showingTable,
                action: { showingTable = true }
            )
        }
        .font(.system(size: layout.common.toggleFontSize))
        .frame(height: layout.common.toggleHeight)
        .minimumScaleFactor(0.5)
    }

    private var graph: some View {
        BufferPhChart(
            layout: layout,
            model: model
        )
    }

    private var table: some View {
        BufferICETable(
            phase: model.phase,
            phase1Component: model.weakSubstanceModel,
            phase2Component: model.phase2Model
        )
        .frame(size: layout.tableSize)
    }
}

private struct BufferICETable: View {

    let phase: BufferScreenViewModel.Phase
    @ObservedObject var phase1Component: BufferWeakSubstanceComponents
    @ObservedObject var phase2Component: BufferSaltComponents

    var body: some View {
        Group {
            if phase == .addWeakSubstance {
                ICETable(
                    columns: phase1Component.tableData,
                    x: phase1Component.progress
                )
            } else {
                ICETable(
                    columns: phase2Component.tableData,
                    x: CGFloat(phase2Component.substanceAdded)
                )
            }
        }
    }
}

struct BufferChartStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferChartStack(
                layout: BufferScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: BufferScreenViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
