//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ConcentrationPlotView: View {

    let settings: ReactionRateChartLayoutSettings
    let concentrationA: Equation
    let concentrationB: Equation?

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let includeAxis: Bool

    let highlightChart: Bool
    let highlightLhsCurve: Bool
    let highlightRhsCurve: Bool

    let display: ReactionPairDisplay

    init(
        settings: ReactionRateChartLayoutSettings,
        concentrationA: Equation,
        concentrationB: Equation?,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        canSetCurrentTime: Bool,
        highlightChart: Bool,
        highlightLhsCurve: Bool,
        highlightRhsCurve: Bool,
        display: ReactionPairDisplay,
        includeAxis: Bool = true
    ) {
        self.settings = settings
        self.concentrationA = concentrationA
        self.concentrationB = concentrationB
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.canSetCurrentTime = canSetCurrentTime
        self.includeAxis = includeAxis
        self.highlightChart = highlightChart
        self.highlightLhsCurve = highlightLhsCurve
        self.highlightRhsCurve = highlightRhsCurve
        self.display = display
    }

    var body: some View {
        ZStack {
            if highlightChart {
                Rectangle()
                    .fill(Color.white)
            }
            if highlightLhsCurve {
                rectangleHighlight(t1: initialTime, t2: (initialTime + finalTime) / 2)
            }
            if highlightRhsCurve {
                rectangleHighlight(t1: (initialTime + finalTime) / 2, t2: finalTime)
            }

            if includeAxis {
                verticalIndicator(at: initialTime)
                verticalIndicator(at: finalTime)
                horizontalIndicator(at: concentrationA.getValue(at: initialTime))
                horizontalIndicator(at: concentrationA.getValue(at: finalTime))
            }

            if includeAxis {
                ChartAxisShape(settings: settings.chartAxisShapeSettings)
                    .stroke()
            }

            if concentrationB != nil {
                TimeChartDataLineView(
                    data: TimeChartDataLine(
                        equation: concentrationB!,
                        headColor: display.product.color,
                        haloColor: nil,
                        headRadius: settings.chartHeadSecondarySize
                    ),
                    settings: settings.timeChartLayoutSettings,
                    lineWidth: settings.timeChartLayoutSettings.lineWidth,
                    initialTime: initialTime,
                    currentTime: .constant(currentTime),
                    finalTime: finalTime,
                    filledBarColor: Styling.timeAxisCompleteBar,
                    canSetCurrentTime: canSetCurrentTime,
                    highlightLhs: false,
                    highlightRhs: false
                )
            }

            TimeChartDataLineView(
                data: TimeChartDataLine(
                    equation: concentrationA,
                    headColor: display.reactant.color,
                    haloColor: display.reactant.color.opacity(0.3),
                    headRadius: settings.chartHeadPrimarySize
                ),
                settings: settings.timeChartLayoutSettings,
                lineWidth: settings.timeChartLayoutSettings.lineWidth,
                initialTime: initialTime,
                currentTime: $currentTime,
                finalTime: finalTime,
                filledBarColor: Styling.timeAxisCompleteBar,
                canSetCurrentTime: canSetCurrentTime,
                highlightLhs: highlightLhsCurve,
                highlightRhs: highlightRhsCurve
            )
        }
        .frame(width: settings.chartSize, height: settings.chartSize)
        .accessibilityElement()
        .modifier(currentValueModifier)
        .accessibilityAdjustableAction { direction in // TODO use the accessibilitySetCurrentTimeAction modifier in reactions core
            guard canSetCurrentTime else {
                return
            }
            let dt = finalTime - initialTime
            let increment = dt / 10
            let sign: CGFloat = direction == .increment ? 1 : -1
            let newValue = currentTime + (sign * increment)
            currentTime = min(finalTime, max(newValue, initialTime))
        }
        .disabled(!canSetCurrentTime)
    }

    private var currentValueModifier: some ViewModifier {
        AccessibleValueModifier(
            x: currentTime
        ) { t in
            let a = concentrationA.getValue(at: t).str(decimals: 2)

            let conB = concentrationB?.getValue(at: t)
            let product = display.product.name
            let b = conB.map { ", \(product) \($0.str(decimals: 2))" } ?? ""

            let reactant = display.reactant.name
            return "time \(t.str(decimals: 1)), \(reactant) \(a)\(b)"
        }
    }

    private func verticalIndicator(at time: CGFloat) -> some View {
        Path { p in
            p.move(
                to: CGPoint(
                    x: settings.xAxis.getPosition(at: time),
                    y: 0
                )
            )
            p.addLine(
                to: CGPoint(
                    x: settings.xAxis.getPosition(at: time),
                    y: settings.chartSize
                )
            )
        }
        .stroke(lineWidth: 0.3)
    }

    private func horizontalIndicator(at concentration: CGFloat) -> some View {
        Path { p in
            p.move(
                to: CGPoint(
                    x: 0,
                    y: settings.yAxis.getPosition(at: concentration)
                )
            )
            p.addLine(
                to: CGPoint(
                    x: settings.chartSize,
                    y: settings.yAxis.getPosition(at: concentration)
                )
            )
        }.stroke(lineWidth: 0.3)
    }

    private func rectangleHighlight(
        t1: CGFloat,
        t2: CGFloat
    ) -> some View {
        let equation = concentrationA
        let x1 = settings.xAxis.getPosition(at: t1)
        let x2 = settings.xAxis.getPosition(at: t2)
        let width = x2 - x1
        let midX = (x2 + x1) / 2

        let c1 = equation.getValue(at: t1)
        let c2 = equation.getValue(at: t2)
        let y1 = settings.yAxis.getPosition(at: c1)
        let y2 = settings.yAxis.getPosition(at: c2)

        let height = abs(y2 - y1)
        let midY = (y1 + y2) / 2

        return Rectangle()
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .position(x: midX, y: midY)
            .zIndex(-1)
    }

}

struct TimeChartPlotView_Previews: PreviewProvider {
    static var previews: some View {
        ConcentrationPlotView(
            settings: ReactionRateChartLayoutSettings(
                chartSize: 300
            ),
            concentrationA: equation,
            concentrationB: equation2,
            initialTime: 0,
            currentTime: .constant(10),
            finalTime: 10,
            canSetCurrentTime: true,
            highlightChart: false,
            highlightLhsCurve: true,
            highlightRhsCurve: false,
            display: ReactionType.A.display
        )
    }

    static var equation = ZeroOrderConcentration(t1: 0, c1: 0.8, t2: 10, c2: 0.2)
    static var equation2 = ZeroOrderConcentration(t1: 0, c1: 0.2, t2: 10, c2: 0.8)
}
