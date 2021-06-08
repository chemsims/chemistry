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
        BufferBottomCharts(layout: layout, model: model)
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
