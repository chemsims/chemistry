//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationPhChart: View {

    let layout: TitrationScreenLayout

    var body: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: ConstantEquation(value: 10),
                    headColor: .purple,
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius
                )
            ],
            initialTime: 0,
            currentTime: .constant(0.5),
            finalTime: 1,
            canSetCurrentTime: false,
            settings: .init(
                xAxis: xAxis,
                yAxis: yAxis,
                haloRadius: layout.common.haloRadius,
                lineWidth: 0.4 // TODO
            ),
            axisSettings: layout.common.chartAxis
        )
        .frame(square: layout.common.chartSize)
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.9 * layout.common.chartSize,
            maxValuePosition: 0.1 * layout.common.chartSize,
            minValue: 0,
            maxValue: 14
        )
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * layout.common.chartSize,
            maxValuePosition: 0.9 * layout.common.chartSize,
            minValue: 0,
            maxValue: 1
        )
    }
}

