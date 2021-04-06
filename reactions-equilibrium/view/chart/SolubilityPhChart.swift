//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityPhChart: View {

    let equation: SolubilityChartEquation

    var body: some View {
        GeometryReader { geo in
            SolubilityChartWithGeometry(
                equation: equation,
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }

}

private struct SolubilityChartWithGeometry: View {

    let equation: Equation
    let width: CGFloat
    let height: CGFloat

    let lineWidth: CGFloat = 2

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Solubility")
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: yAxisWidth, height: plotHeight)
            Rectangle()
                .frame(width: lineWidth, height: plotHeight)
            VStack(alignment: .leading, spacing: 0) {
                chartLine
                Rectangle()
                    .frame(width: plotWidth, height: lineWidth)
                Text("pH")
                    .frame(width: plotWidth, height: xAxisHeight)
            }
        }
        .minimumScaleFactor(0.8)
    }

    private var chartLine: some View {
        ChartLine(
            equation: equation,
            yAxis: axis(minPosition: height, maxPosition: 0),
            xAxis: axis(minPosition: 0, maxPosition: width),
            startX: 0,
            endX: 1
        )
        .stroke(lineWidth: lineWidth)
        .frame(width: plotWidth, height: plotHeight)
    }

    private func axis(minPosition: CGFloat, maxPosition: CGFloat) -> AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: minPosition,
            maxValuePosition: maxPosition,
            minValue: 0,
            maxValue: 1.2
        )
    }

    private var plotWidth: CGFloat {
        0.9 * width
    }

    private var yAxisWidth: CGFloat {
        width - plotWidth
    }

    private var plotHeight: CGFloat {
        0.9 * height
    }

    private var xAxisHeight: CGFloat {
        height - plotHeight
    }
}

struct SolubilityChartEquation: Equation {

    private let underlying: Equation

    init(
        zeroPhSolubility: CGFloat,
        maxPhSolubility: CGFloat,
        minSolubilityPh: CGFloat,
        minSolubility: CGFloat
    ) {
        let parabola = CGPoint(x: minSolubilityPh, y: minSolubility)
        self.underlying = SwitchingEquation(
            thresholdX: minSolubilityPh,
            underlyingLeft: QuadraticEquation(
                parabola: parabola,
                through: CGPoint(x: 0, y: zeroPhSolubility)
            ),
            underlyingRight: QuadraticEquation(
                parabola: parabola,
                through: CGPoint(x: 1, y: maxPhSolubility)
            )
        )
    }

    func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x)
    }

}

struct SolubilityPhChart_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityPhChart(
            equation: SolubilityChartEquation(
                zeroPhSolubility: 0.8,
                maxPhSolubility: 1,
                minSolubilityPh: 0.6,
                minSolubility: 0.2
            )
        )
        .frame(width: 300, height: 200)
    }
}
