//
// Reactions App
//


import SwiftUI

public struct TimeChartView: View {

    let data: [TimeChartDataLine]

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let settings: TimeChartLayoutSettings
    let axisSettings: ChartAxisShapeSettings

    let clipData: Bool

    let offset: CGFloat
    let minDragTime: CGFloat?
    let activeIndex: Int?

    public init(
        data: [TimeChartDataLine],
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        canSetCurrentTime: Bool,
        settings: TimeChartLayoutSettings,
        axisSettings: ChartAxisShapeSettings,
        clipData: Bool = false,
        offset: CGFloat = 0,
        minDragTime: CGFloat? = nil,
        activeIndex: Int? = nil
    ) {
        self.data = data
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.canSetCurrentTime = canSetCurrentTime
        self.settings = settings
        self.axisSettings = axisSettings
        self.clipData = clipData
        self.offset = offset
        self.minDragTime = minDragTime
        self.activeIndex = activeIndex
    }

    public var body: some View {
        ZStack {
            ChartAxisShape(settings: axisSettings)
                .stroke(lineWidth: axisSettings.lineWidth)

            TimeChartMultiDataLineView(
                data: data,
                settings: settings,
                initialTime: initialTime,
                currentTime: $currentTime,
                finalTime: finalTime,
                filledBarColor: Styling.timeAxisCompleteBar,
                canSetCurrentTime: canSetCurrentTime,
                clipData: clipData,
                offset: offset,
                minDragTime: minDragTime,
                activeIndex: activeIndex
            )
        }
    }
}
