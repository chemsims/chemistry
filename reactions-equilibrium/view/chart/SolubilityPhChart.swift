//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityPhChart: View {

    let curve: SolubilityChartEquation
    let startPh: CGFloat
    let endPh: Equation
    let endSolubility: Equation
    let currentTime: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            SolubilityChartWithGeometry(
                curve: curve,
                startPh: startPh,
                endPh: endPh,
                endSolubility: endSolubility,
                currentTime: currentTime,
                lineWidth: lineWidth,
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }
}

private struct SolubilityChartWithGeometry: View {

    let curve: SolubilityChartEquation
    let startPh: CGFloat
    let endPh: Equation
    let endSolubility: Equation
    let currentTime: CGFloat

    let lineWidth: CGFloat
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Solubility")
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: yAxisWidth, height: plotHeight)

            VStack(alignment: .leading, spacing: 0) {
                plotArea
                Text("pH")
                    .fixedSize()
                    .frame(width: plotWidth, height: xAxisHeight)
            }
        }
        .minimumScaleFactor(0.8)
    }

    private var plotArea: some View {
        ZStack {
            Path { p in
                p.move(to: .zero)
                p.addLine(to: CGPoint(x: 0, y: plotHeight))
                p.addLine(to: CGPoint(x: plotWidth, y: plotHeight))
            }
            .stroke(lineWidth: lineWidth)

            plotLines
        }
        .frame(width: plotWidth, height: plotHeight)
    }

    private var plotLines: some View {
        ZStack {
            ChartLine(
                equation: curve,
                yAxis: solubilityAxis,
                xAxis: phAxis,
                startX: 0,
                endX: 1
            )
            .stroke(lineWidth: lineWidth)

            SolubilityPhPositionLine(
                startingPh: startPh,
                endSolubility: endSolubility,
                endPh: endPh,
                currentTime: currentTime,
                phAxis: phAxis,
                solubilityAxis: solubilityAxis
            )
            .stroke(lineWidth: lineWidth)
            .foregroundColor(.red)
        }
    }

    private var phAxis: AxisPositionCalculations<CGFloat> {
        axis(minPosition: 0, maxPosition: width)
    }

    private var solubilityAxis: AxisPositionCalculations<CGFloat> {
        axis(minPosition: plotHeight, maxPosition: 0)
    }

    private func axis(minPosition: CGFloat, maxPosition: CGFloat) -> AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: minPosition,
            maxValuePosition: maxPosition,
            minValue: 0,
            maxValue: 1.3
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

private struct SolubilityPhPositionLine: Shape {

    let startingPh: CGFloat
    let endSolubility: Equation
    let endPh: Equation
    var currentTime: CGFloat

    let phAxis: AxisPositionCalculations<CGFloat>
    let solubilityAxis: AxisPositionCalculations<CGFloat>

    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func path(in rect: CGRect) -> Path {
        func getPoint(ph: CGFloat, solubility: CGFloat) -> CGPoint {
            CGPoint(
                x: phAxis.getPosition(at: ph),
                y: solubilityAxis.getPosition(at: solubility)
            )
        }

        var path = Path()

        path.move(to: getPoint(ph: startingPh, solubility: 0))

        let endPh = self.endPh.getY(at: currentTime)
        let endSolubility = self.endSolubility.getY(at: currentTime)

        if startingPh != endPh {
            path.addLine(to: getPoint(ph: startingPh, solubility: endSolubility))
        }
        path.addLine(to: getPoint(ph: endPh, solubility: endSolubility))

        return path
    }
}

struct SolubilityPhChart_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityPhChart(
            curve: SolubilityChartEquation(
                zeroPhSolubility: 0.8,
                maxPhSolubility: 1,
                minSolubility: 0.2,
                phAtMinSolubility: 0.6
            ),
            startPh: 0.8,
            endPh: ConstantEquation(value: 0.4),
            endSolubility: ConstantEquation(value: 0.75),
            currentTime: 0,
            lineWidth: 1
        )
        .frame(width: 300, height: 200)
    }
}
