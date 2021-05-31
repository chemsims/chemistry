//
// Reactions App
//

import SwiftUI

public struct BarChart: View {
    public init(
        data: [BarChartData],
        time: CGFloat,
        settings: BarChartGeometry
    ) {
        self.data = data
        self.time = time
        self.settings = settings
    }

    let data: [BarChartData]
    let time: CGFloat
    let settings: BarChartGeometry

    public var body: some View {
        VStack(spacing: settings.chartToAxisSpacing) {
            plotArea
            labels
                .accessibility(hidden: true)
        }
    }

    private var plotArea: some View {
        ZStack {
            BarChartMinorAxisShape(ticks: settings.ticks)
                .stroke(lineWidth: 0.3)
            BarChartAxisShape(
                ticks: settings.ticks,
                tickSize: settings.yAxisTickSize
            )
            .stroke(lineWidth: 1.4)

            bars
        }
        .frame(square: settings.chartWidth)
    }

    private var bars: some View {
        HStack(spacing: 0) {
            ForEach(data.indices, id: \.self) { i in
                Spacer()
                bar(data[i])
                Spacer()
            }
        }
    }

    private var labels: some View {
        HStack(spacing: 0) {
            ForEach(data.indices, id: \.self) { i in
                Spacer()
                label(data[i])
                Spacer()
            }
        }.frame(width: settings.chartWidth)
    }

    private func bar(_ data: BarChartData) -> some View {
        ZStack {
            if data.initialValue != nil {
                BarShape(
                    equation: ConstantEquation(value: data.initialValue!.value),
                    time: time,
                    axis: settings.yAxis
                )
                .foregroundColor(data.initialValue!.color)
            }

            BarShape(
                equation: data.equation,
                time: time,
                axis: settings.yAxis
            )
            .foregroundColor(data.color)
        }
        .frame(width: settings.barWidth, height: settings.chartWidth)
        .offset(y: -settings.tickDy)
        .accessibility(label: Text(data.accessibilityLabel))
        .updatingAccessibilityValue(x: time, format: data.accessibilityValue)
    }

    private func label(_ data: BarChartData) -> some View {
        VStack(spacing: settings.labelToCircleSpacing) {
            Circle()
                .frame(square: settings.labelDiameter)
                .foregroundColor(data.color)
            Text(data.label)
                .font(.system(size: settings.labelFontSize))
                .frame(height: settings.labelTextHeight)
                .minimumScaleFactor(0.75)
        }
    }
}

struct BarChart_Previews: PreviewProvider {

    private static let geometry = BarChartGeometry(
        chartWidth: 200,
        minYValue: 0,
        maxYValue: 1,
        barWidthFraction: 0.13
    )

    static var previews: some View {
        BarChart(
            data: [
                BarChartData(
                    label: "A",
                    equation: LinearEquation(m: 1, x1: 0, y1: 0),
                    color: .red,
                    accessibilityLabel: "",
                    initialValue: .init(value: 0.5, color: Styling.barChartEmpty)
                ),
                BarChartData(
                    label: "B",
                    equation: LinearEquation(m: 1, x1: 0, y1: 0.3),
                    color: .blue,
                    accessibilityLabel: ""
                ),
                BarChartData(
                    label: "C",
                    equation: LinearEquation(m: 1, x1: 0, y1: 0.2),
                    color: .purple,
                    accessibilityLabel: ""
                ),
                BarChartData(
                    label: "D",
                    equation: LinearEquation(m: 1, x1: 0, y1: 0.4),
                    color: .green,
                    accessibilityLabel: ""
                )
            ],
            time: 0,
            settings: geometry
        )
    }
}
