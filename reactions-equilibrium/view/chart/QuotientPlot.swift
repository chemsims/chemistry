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
    let equilibriumTime: CGFloat

    let showData: Bool
    let offset: CGFloat
    let discontinuity: CGPoint?

    let kTerm: String
    let accessibilityValue: Equation

    let maxDragTime: CGFloat

    let settings: ReactionEquilibriumChartsLayoutSettings

    var body: some View {
        HStack(alignment: .top, spacing: settings.axisLabelGapFromAxis) {
            Text("Q")
                .frame(width: settings.yAxisWidthLabelWidth, height: settings.size)
                .fixedSize()
                .minimumScaleFactor(0.8)
                .zIndex(1)
                .accessibility(hidden: true)

            VStack(spacing: settings.axisLabelGapFromAxis) {
                annotatedChart
                Text("Time")
                    .frame(height: settings.xAxisLabelHeight)
                    .accessibility(hidden: true)
            }
            Text(kTerm)
                .foregroundColor(.orangeAccent)
                .frame(width: settings.yAxisWidthLabelWidth, height: settings.size)
                .fixedSize()
                .minimumScaleFactor(0.8)
                .offset(y: asymptoteYLabelOffset)
                .animation(nil)
                .opacity(showData ? 1 : 0)
                .accessibility(hidden: true)
        }
        .font(.system(size: settings.axisLabelFontSize))
        .accessibilityElement()
        .accessibility(label: Text(label))
        .updatingAccessibilityValue(x: currentTime, format: getAccessibilityValue)
        .accessibilitySetCurrentTimeAction(
            currentTime: $currentTime,
            canSetTime: canSetCurrentTime,
            initialTime: discontinuity?.x ?? 0,
            finalTime: maxDragTime
        )
    }

    private var label: String {
        "Graph showing time vs quotient, with a horizontal line for \(kTerm)"
    }

    private func getAccessibilityValue(forTime time: CGFloat) -> String {
        guard showData else {
            return "no data"
        }
        let quotient = accessibilityValue.getY(at: time).str(decimals: 2)
        let timeString = time.str(decimals: 1)
        let k = accessibilityValue.getY(at: finalTime + offset).str(decimals: 2)

        return "Time \(timeString), quotient \(quotient), \(kTerm) \(k)"
    }

    private var annotatedChart: some View {
        ZStack {
            equilibriumHighlight
            if showData {
                indicatorLine
            }
            equilibriumHighlight
            chart
        }
        .frame(width: settings.size, height: settings.size)
    }

    private var equilibriumHighlight: some View {
        EquilibriumHighlight(
            equilibriumTime: equilibriumTime,
            chartSize: settings.size,
            xAxis: settings.layout.xAxis,
            offset: offset
        )
    }

    private var chart: some View {
        TimeChartView(
            data: !showData ? [] : [
                TimeChartDataLine(
                    equation: equation,
                    headColor: .orangeAccent,
                    haloColor: Color.orangeAccent.opacity(0.3),
                    headRadius: settings.headRadius,
                    discontinuity: discontinuity
                )
            ],
            initialTime: initialTime,
            currentTime: $currentTime,
            finalTime: finalTime,
            canSetCurrentTime: canSetCurrentTime,
            settings: settings.layout,
            axisSettings: settings.axisShapeSettings,
            clipData: true,
            offset: offset,
            minDragTime: discontinuity?.x
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
            .animation(nil)
            .zIndex(1)
    }

    private var asymptoteYLabelOffset: CGFloat {
        asymptoteYPosition - (settings.size / 2)
    }

    private var asymptoteYPosition: CGFloat {
        settings.layout.yAxis.getPosition(at: equilibriumConstant)
    }

    private var equilibriumConstant: CGFloat {
        equation.getY(at: finalTime + offset)
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
            equilibriumTime: 10,
            showData: true,
            offset: 0,
            discontinuity: nil,
            kTerm: "K",
            accessibilityValue: ConstantEquation(value: 0),
            maxDragTime: 10,
            settings: ReactionEquilibriumChartsLayoutSettings(
                size: 300,
                maxYAxisValue: 1
            )
        )
    }
}
