//
// Reactions App
//


import SwiftUI

struct TimeChartMultiDataLineView: View {

    let data: [TimeChartDataLine]
    let settings: TimeChartLayoutSettings

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let canSetCurrentTime: Bool

    let highlightLhs: Bool
    let highlightRhs: Bool

    let clipData: Bool
    let offset: CGFloat
    let minDragTime: CGFloat?
    let activeIndex: Int?

    init(
        data: [TimeChartDataLine],
        settings: TimeChartLayoutSettings,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        filledBarColor: Color,
        canSetCurrentTime: Bool,
        highlightLhs: Bool = false,
        highlightRhs: Bool = false,
        clipData: Bool = false,
        offset: CGFloat = 0,
        minDragTime: CGFloat? = nil,
        activeIndex: Int? = nil
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
        self.offset = offset
        self.minDragTime = minDragTime
        self.activeIndex = activeIndex
    }

    var body: some View {
        ZStack {
            ForEach(0..<data.count, id: \.self) { i in
                TimeChartDataLineView(
                    data: data[i],
                    settings: settings,
                    lineWidth: activeIndex == i ? 2 * settings.lineWidth : settings.lineWidth,
                    initialTime: initialTime,
                    currentTime: $currentTime,
                    finalTime: finalTime,
                    filledBarColor: filledBarColor,
                    canSetCurrentTime: canSetCurrentTime,
                    highlightLhs: highlightLhs,
                    highlightRhs: highlightRhs,
                    clipData: clipData,
                    offset: offset,
                    minDragTime: minDragTime
                )
                .opacity(activeIndex.forAll({$0 == i }) ? 1 : 0.3)
                .zIndex(activeIndex == i ? 1 : 0)
            }
        }
    }
}

public struct TimeChartDataLineView: View {

    let data: TimeChartDataLine
    let settings: TimeChartLayoutSettings
    let lineWidth: CGFloat

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let canSetCurrentTime: Bool

    let highlightLhs: Bool
    let highlightRhs: Bool
    let clipData: Bool

    let offset: CGFloat
    let minDragTime: CGFloat?

    public init(
        data: TimeChartDataLine,
        settings: TimeChartLayoutSettings,
        lineWidth: CGFloat,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        filledBarColor: Color,
        canSetCurrentTime: Bool,
        highlightLhs: Bool,
        highlightRhs: Bool,
        clipData: Bool = false,
        offset: CGFloat = 0,
        minDragTime: CGFloat? = nil
    ) {
        self.data = data
        self.settings = settings
        self.lineWidth = lineWidth
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.filledBarColor = filledBarColor
        self.canSetCurrentTime = canSetCurrentTime
        self.highlightLhs = highlightLhs
        self.highlightRhs = highlightRhs
        self.clipData = clipData
        self.offset = offset
        self.minDragTime = minDragTime
    }

    public var body: some View {
        ZStack {
            dataLine(time: finalTime + offset, color: filledBarColor)
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
                    let shiftedAxis = settings.xAxis.shift(by: offset)
                    let newTime = shiftedAxis.getValue(at: xLocation)

                    let minTime = minDragTime ?? initialTime + offset
                    let maxTime = finalTime + offset
                    currentTime = max(minTime, min(maxTime, newTime))
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
            x: currentTime,
            offset: offset
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
            lineWidth: lineWidth
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
            lineWidth: 2.5 * lineWidth
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
            endX: time,
            offset: offset,
            discontinuity: data.discontinuity
        )
        .stroke(lineWidth: lineWidth)
        .foregroundColor(color)

        if clipData {
            view.clipped()
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
            highlightRhs: false,
            offset: 5
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
            lineWidth: 2
        )
    }

    private static var allData: [TimeChartDataLine] {
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
                LinearEquation(m: 0.5, x1: 0, y1: 0),
                .black
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

    private static func data(_ equation: Equation, _ color: Color) -> TimeChartDataLine {
        TimeChartDataLine(
            equation: equation,
            headColor: color,
            haloColor: color.opacity(0.3),
            headRadius: 6
        )
    }
}
