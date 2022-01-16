//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityPhChart: View {

    let curve: SolubilityChartEquation
    let startPh: CGFloat
    let ph: Equation
    let solubility: Equation
    let currentTime: CGFloat

    let lineWidth: CGFloat
    let indicatorRadius: CGFloat
    let haloRadius: CGFloat

    var body: some View {
        GeometryReader { geo in
            SolubilityChartWithGeometry(
                curve: curve,
                startPh: startPh,
                ph: ph,
                solubility: solubility,
                currentTime: currentTime,
                lineWidth: lineWidth,
                indicatorRadius: indicatorRadius,
                haloRadius: haloRadius,
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }
}

private struct SolubilityChartWithGeometry: View {

    let curve: SolubilityChartEquation
    let startPh: CGFloat
    let ph: Equation
    let solubility: Equation
    let currentTime: CGFloat

    let lineWidth: CGFloat
    let indicatorRadius: CGFloat
    let haloRadius: CGFloat

    let width: CGFloat
    let height: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Solubility")
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: yAxisWidth, height: plotHeight)
                .accessibility(hidden: true)

            VStack(alignment: .leading, spacing: 2) {
                plotArea
                Text("pH")
                    .fixedSize()
                    .frame(width: plotWidth, height: xAxisHeight)
                    .accessibility(hidden: true)
            }
        }
        .minimumScaleFactor(0.8)
        .accessibilityElement(children: .contain)
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
                .accessibility(sortPriority: 2)

            plotIndicatorHead
                .accessibility(label: Text("Reaction position on ph-solubility curve"))
                .updatingAccessibilityValue(x: currentTime, format: chartLineLabel)
                .accessibility(sortPriority: 1)
        }
        .frame(width: plotWidth, height: plotHeight)
    }

    private var plotIndicatorHead: some View {
        ZStack {
            head(radius: haloRadius, color: Styling.primaryColorHalo)
            head(radius: indicatorRadius, color: .orangeAccent)
        }
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
                solubility: solubility,
                ph: ph,
                currentTime: currentTime,
                phAxis: phAxis,
                solubilityAxis: solubilityAxis
            )
            .stroke(lineWidth: lineWidth)
            .foregroundColor(.red)
            .accessibility(label: Text(curve.label))
        }
    }

    private func chartLineLabel(at time: CGFloat) -> String {
        let rawPh = ph.getValue(at: time)
        let rawSol = solubility.getValue(at: time)

        let phPerc = rawPh.percentage
        let solPerc = rawSol.percentage
        var label = "Ph \(phPerc) along x axis, solubility \(solPerc) up y axis. "

        let curveSolubility = curve.getValue(at: rawPh)
        let delta = curveSolubility - rawSol

        if abs(delta) < 0.01 {
            label.append(" solubility is equal to the ph-solubility profile curve.")
        } else if delta < 0 {
            label.append(" solubility is above the ph-solubility profile curve.")
        } else {
            label.append(" solubility is below the ph-solubility profile curve")
        }

        return label
    }

    private var phAxis: LinearAxis<CGFloat> {
        axis(minPosition: 0, maxPosition: width)
    }

    private var solubilityAxis: LinearAxis<CGFloat> {
        axis(minPosition: plotHeight, maxPosition: 0)
    }

    private func axis(minPosition: CGFloat, maxPosition: CGFloat) -> LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: minPosition,
            maxValuePosition: maxPosition,
            minValue: 0,
            maxValue: 1.3
        )
    }

    private func head(radius: CGFloat, color: Color) -> some View {
        SolubilityPhIndicatorHead(
            ph: ph,
            solubility: solubility,
            currentTime: currentTime,
            radius: radius,
            solubilityAxis: solubilityAxis,
            phAxis: phAxis
        )
        .foregroundColor(color)

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

private struct SolubilityPhIndicatorHead: Shape {

    let ph: Equation
    let solubility: Equation
    var currentTime: CGFloat

    let radius: CGFloat
    let solubilityAxis: LinearAxis<CGFloat>
    let phAxis: LinearAxis<CGFloat>


    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func path(in rect: CGRect) -> Path {
        ChartIndicatorHead(
            radius: radius,
            equation: ConstantEquation(value: solubility.getValue(at: currentTime)),
            yAxis: solubilityAxis,
            xAxis: phAxis,
            x: ph.getValue(at: currentTime),
            offset: 0
        ).path(in: rect)
    }
}

private struct SolubilityPhPositionLine: Shape {

    let startingPh: CGFloat
    let solubility: Equation
    let ph: Equation
    var currentTime: CGFloat

    let phAxis: LinearAxis<CGFloat>
    let solubilityAxis: LinearAxis<CGFloat>

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

        let endPh = self.ph.getValue(at: currentTime)
        let endSolubility = self.solubility.getValue(at: currentTime)

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
            ph: ConstantEquation(value: 0.4),
            solubility: ConstantEquation(value: 0.75),
            currentTime: 0,
            lineWidth: 1,
            indicatorRadius: 5,
            haloRadius: 10
        )
        .frame(width: 300, height: 200)
    }
}
