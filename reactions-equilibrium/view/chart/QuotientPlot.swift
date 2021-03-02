//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct QuotientPlot: View {

    let equation: Equation

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let showData: Bool
    let offset: CGFloat

    let settings: ReactionEquilibriumChartsLayoutSettings

    var body: some View {
        HStack(alignment: .top, spacing: settings.axisLabelGapFromAxis) {
            Text("Q")
                .frame(width: settings.yAxisWidthLabelWidth, height: settings.size)
                .fixedSize()
                .minimumScaleFactor(0.8)
            VStack(spacing: settings.axisLabelGapFromAxis) {
                annotatedChart
                Text("Time")
            }
            Text("K")
                .foregroundColor(.orangeAccent)
                .frame(width: settings.yAxisWidthLabelWidth, height: settings.size)
                .fixedSize()
                .minimumScaleFactor(0.8)
                .offset(y: asymptoteYLabelOffset)
                .opacity(showData ? 1 : 0)
        }
        .font(.system(size: settings.axisLabelFontSize))
    }

    private var annotatedChart: some View {
        ZStack {
            if showData {
                indicatorLine
            }
            chart
        }
        .frame(width: settings.size, height: settings.size)
    }

    private var chart: some View {
        TimeChartView(
            data: !showData ? [] : [
                TimeChartDataline(
                    equation: equation,
                    headColor: .orangeAccent,
                    haloColor: Color.orangeAccent.opacity(0.3),
                    headRadius: settings.headRadius
                )
            ],
            initialTime: 0,
            currentTime: $currentTime,
            finalTime: AqueousReactionSettings.totalReactionTime,
            canSetCurrentTime: canSetCurrentTime,
            settings: settings.layout,
            axisSettings: settings.axisShapeSettings,
            offset: offset
        )
    }

    private var indicatorLine: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [settings.size / 35]))
            .frame(height: 1)
            .foregroundColor(.orangeAccent)
            .position(
                x: settings.size / 2,
                y: asymptoteYPosition
            )
    }

    private var asymptoteYLabelOffset: CGFloat {
        asymptoteYPosition - (settings.size / 2)
    }

    private var asymptoteYPosition: CGFloat {
        settings.layout.yAxis.getPosition(at: equation.getY(at: finalTime))
    }
}


struct QuotientPlot_Previews: PreviewProvider {
    static var previews: some View {
        QuotientPlot(
            equation: LinearEquation(m: 1/18, x1: 0, y1: 0),
            initialTime: 0,
            currentTime: .constant(10),
            finalTime: 20,
            canSetCurrentTime: false,
            showData: true,
            offset: 0,
            settings: ReactionEquilibriumChartsLayoutSettings(
                size: 300,
                maxYAxisValue: 1
            )
        )
    }
}
