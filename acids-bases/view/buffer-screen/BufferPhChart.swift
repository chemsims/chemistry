//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferPhChart: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        HStack(spacing: layout.common.chartXAxisHSpacing) {
            Text("pH")
                .frame(height: layout.common.chartYAxisWidth)
                .rotationEffect(.degrees(-90))

            VStack(spacing: layout.common.chartYAxisVSpacing) {
                plotArea

                // TODO dynamic label
                Text("Moles added")
                    .frame(height: layout.common.chartXAxisHeight)
            }
        }
        .font(.system(size: layout.common.chartLabelFontSize))
    }

    private var plotArea: some View {
        ZStack {
            waterLine

            TimeChartView(
                data: [],
                initialTime: 0,
                currentTime: .constant(0),
                finalTime: 1,
                canSetCurrentTime: false,
                settings: TimeChartLayoutSettings(
                    xAxis: xAxis,
                    yAxis: yAxis,
                    haloRadius: layout.common.haloRadius,
                    lineWidth: 0.4 // TODO
                ),
                axisSettings: layout.common.chartAxis
            )
        }
        .frame(square: chartSize)
    }

    private var waterLine: some View {
        ChartLine(
            equation: LinearEquation(m: -1, x1: 0, y1: 1),
            yAxis: yAxis,
            xAxis: xAxis,
            startX: 0,
            endX: 1
        )
        .stroke(lineWidth: 0.4)
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.9 * chartSize,
            maxValuePosition: 0.1 * chartSize,
            minValue: 0,
            maxValue: 1
        )
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * chartSize,
            maxValuePosition: 0.9 * chartSize,
            minValue: 0,
            maxValue: 1
        )
    }

    private var chartSize: CGFloat {
        layout.common.chartSize
    }
}

struct BufferPhChart_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    BufferPhChart(
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
        .previewLayout(.iPhoneSELandscape)
    }
}
