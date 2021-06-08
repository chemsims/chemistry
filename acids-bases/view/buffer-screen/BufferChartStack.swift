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
            iceTable
                .frame(size: layout.tableSize)
            Spacer()
            bottomCharts
        }
    }

    private var iceTable: some View {
        BufferICETable(
            phase: model.phase,
            phase1Component: model.weakSubstanceModel,
            phase2Component: model.phase2Model
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
