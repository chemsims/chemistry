//
// Reactions App
//


import SwiftUI

public struct TimeChartMultiDataLineView: View {

    let data: [TimeChartDataline]
    let settings: TimeChartLayoutSettings

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let canSetCurrentTime: Bool

    let highlightLhs: Bool
    let highlightRhs: Bool

    let clipData: Bool

    public init(
        data: [TimeChartDataline],
        settings: TimeChartLayoutSettings,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        filledBarColor: Color,
        canSetCurrentTime: Bool,
        highlightLhs: Bool = false,
        highlightRhs: Bool = false,
        clipData: Bool = false
    ) {
        self.data = data
        self.settings = settings
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.filledBarColor = filledBarColor
        self.canSetCurrentTime = canSetCurrentTime
        self.highlightLhs = highlightLhs
        self.highlightRhs = highlightRhs
        self.clipData = clipData
    }

    public var body: some View {
        ZStack {
            ForEach(0..<data.count, id: \.self) { i in
                TimeChartDataLineView(
                    data: data[i],
                    settings: settings,
                    initialTime: initialTime,
                    currentTime: $currentTime,
                    finalTime: finalTime,
                    filledBarColor: filledBarColor,
                    canSetCurrentTime: canSetCurrentTime,
                    highlightLhs: highlightLhs,
                    highlightRhs: highlightRhs,
                    clipData: clipData
                )
            }
        }
    }
}

public struct TimeChartDataLineView: View {

    let data: TimeChartDataline
    let settings: TimeChartLayoutSettings

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let canSetCurrentTime: Bool

    let highlightLhs: Bool
    let highlightRhs: Bool
    let clipData: Bool

    public init(
        data: TimeChartDataline,
        settings: TimeChartLayoutSettings,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        filledBarColor: Color,
        canSetCurrentTime: Bool,
        highlightLhs: Bool,
        highlightRhs: Bool,
        clipData: Bool = false
    ) {
        self.data = data
        self.settings = settings
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.filledBarColor = filledBarColor
        self.canSetCurrentTime = canSetCurrentTime
        self.highlightLhs = highlightLhs
        self.highlightRhs = highlightRhs
        self.clipData = clipData
    }

    public var body: some View {
        ZStack {
            dataLine(time: finalTime, color: filledBarColor)
            dataLine(time: currentTime, color: data.headColor)
            if highlightLhs {
                highlightLine(startTime: initialTime, endTime: (initialTime + finalTime) / 2)
            }
            if highlightRhs {
                highlightLine(startTime: (initialTime + finalTime) / 2, endTime: finalTime)
            }

            if data.haloColor != nil {
                head(
                    radius: settings.haloRadius,
                    color: data.haloColor!
                )
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                    guard canSetCurrentTime else {
                        return
                    }
                    let xLocation = gesture.location.x
                    let newTime = settings.xAxis.getValue(at: xLocation)
                    currentTime = max(initialTime, min(finalTime, newTime))
                })
            }
            head(
                radius: data.headRadius,
                color: data.headColor
            )
        }
    }

    private func head(
        radius: CGFloat,
        color: Color
    ) -> some View {
        ChartIndicatorHead(
            radius: radius,
            equation: data.equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            x: currentTime
        )
        .fill()
        .foregroundColor(color)
    }

    private func dataLine(
        time: CGFloat,
        color: Color
    ) -> some View {
        line(
            startTime: initialTime,
            time: time,
            color: color,
            lineWidth: settings.lineWidth
        )
    }

    private func highlightLine(
        startTime: CGFloat,
        endTime: CGFloat
    ) -> some View {
        line(
            startTime: startTime,
            time: endTime,
            color: data.headColor,
            lineWidth: 2.5 * settings.lineWidth
        )
    }

    @ViewBuilder
    private func line(
        startTime: CGFloat,
        time: CGFloat,
        color: Color,
        lineWidth: CGFloat
    ) -> some View {
        let view = ChartLine(
            equation: data.equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            startX: startTime,
            endX: time
        )
        .stroke(lineWidth: lineWidth)
        .foregroundColor(color)

        if clipData {
            view
                .clipped()
        } else {
            view
        }
    }
}


struct TimeChartDataLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeChartMultiDataLineView(
            data: allData,
            settings: settings,
            initialTime: 0,
            currentTime: .constant(10),
            finalTime: 10,
            filledBarColor: .black,
            canSetCurrentTime: false,
            highlightLhs: false,
            highlightRhs: false
        )
        .frame(width: 300, height: 300)
        .border(Color.black)
    }

    private static var settings: TimeChartLayoutSettings {
        TimeChartLayoutSettings(
            xAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 0,
                maxValuePosition: 300,
                minValue: 0,
                maxValue: 10
            ),
            yAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 300,
                maxValuePosition: 0,
                minValue: 0,
                maxValue: 10
            ),
            haloRadius: 18,
            lineWidth: 3
        )
    }

    private static var allData: [TimeChartDataline] {
        [
            data(
                makeEquation(
                    parabola: CGPoint(x: 5, y: 0),
                    through: CGPoint(x: 0, y: 5)
                ),
                .from(.moleculeA)
            ),
            data(
                makeEquation(
                    parabola: CGPoint(x: 4, y: 6),
                    through: CGPoint(x: 0, y: 2)
                ),
                .from(.moleculeB)
            ),
            data(
                makeEquation(
                    parabola: CGPoint(x: 4, y: 8),
                    through: CGPoint(x: 0, y: 4)
                ),
                .from(.moleculeC)
            ),
            data(
                LinearEquation(m: 2, x1: 0, y1: 0),
                .red
            )
        ]
    }

    private static func makeEquation(
        parabola: CGPoint,
        through: CGPoint
    ) -> Equation {
        SwitchingEquation(
            thresholdX: parabola.x,
            underlyingLeft: QuadraticEquation(parabola: parabola, through: through),
            underlyingRight: ConstantEquation(value: parabola.y)
        )
    }

    private static func data(_ equation: Equation, _ color: Color) -> TimeChartDataline {
        TimeChartDataline(
            equation: equation,
            headColor: color,
            haloColor: color.opacity(0.3),
            headRadius: 6
        )
    }
}
