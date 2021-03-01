//
// Reactions App
//


import SwiftUI

public struct TimeChartView: View {

    let data: [TimeChartDataline]

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let settings: TimeChartLayoutSettings
    let axisSettings: ChartAxisShapeSettings

    let clipData: Bool

    public init(
        data: [TimeChartDataline],
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        canSetCurrentTime: Bool,
        settings: TimeChartLayoutSettings,
        axisSettings: ChartAxisShapeSettings,
        clipData: Bool = false
    ) {
        self.data = data
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.canSetCurrentTime = canSetCurrentTime
        self.settings = settings
        self.axisSettings = axisSettings
        self.clipData = clipData
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
                clipData: clipData
            )
        }
    }
}
