//
// Reactions App
//
  

import SwiftUI

struct TimeChartAxisView<Value>: View where Value: BinaryFloatingPoint {

    @Binding var concentration: Value
    @Binding var time: Value

    let minConcentration: Value
    let maxConcentration: Value

    let minTime: Value
    let maxTime: Value

    let chartSize: CGFloat

    var body: some View {
        makeView(using: TimeChartGeometrySettings(chartSize: chartSize))
    }

    private func makeView(using settings: TimeChartGeometrySettings) -> some View {
        HStack {
            VStack {
                Text("[A]")
                Text("\(Double(concentration), specifier: "%.2f") M").foregroundColor(.orangeAccent)
            }
            .font(.system(size: settings.labelFontSize))
            .frame(width: settings.yLabelWidth)

            HStack(alignment: .top) {
                slider(isPortrait: true, settings: settings)
                VStack {
                    TimeChartAxisShape(
                        verticalTicks: settings.verticalTicks,
                        horizontalTicks: settings.horizontalTicks,
                        tickSize: settings.tickSize,
                        gapToTop: settings.gapFromMaxTickToChart,
                        gapToSide: settings.gapFromMaxTickToChart
                    )
                        .stroke()
                        .frame(width: chartSize, height: chartSize)
                        .overlay(verticalIndicator(settings: settings), alignment: .leading)
                        .overlay(horizontalIndicator(settings: settings), alignment: .bottom)

                    slider(isPortrait: false, settings: settings)

                    HStack {
                        Text("Time")
                            .frame(width: chartSize / 2, alignment: .trailing)

                        Text("\(Double(time), specifier: "%.1f") s")
                            .foregroundColor(.orangeAccent)
                            .frame(width: chartSize / 2, alignment: .leading)
                    }.font(.system(size: settings.labelFontSize))
                }
            }
        }
    }

    private func verticalIndicator(settings: TimeChartGeometrySettings) -> some View {
        indicator(isPortrait: true, settings: settings)
    }

    private func horizontalIndicator(settings: TimeChartGeometrySettings) -> some View {
        indicator(isPortrait: false, settings: settings)
    }

    private func slider(isPortrait: Bool, settings: TimeChartGeometrySettings) -> some View {
        let width: CGFloat = isPortrait ? settings.sliderHandleWidth : chartSize
        let height: CGFloat = isPortrait ? chartSize : settings.sliderHandleWidth
        return CustomSlider(
            value: isPortrait ? $concentration : $time,
            minValue: isPortrait ? minConcentration : minTime,
            maxValue: isPortrait ? maxConcentration : maxTime,
            handleThickness: settings.handleThickness,
            handleColor: Color.orangeAccent,
            handleCornerRadius: settings.handleCornerRadius,
            barThickness: 3,
            barColor: Color.darkGray,
            minValuePadding: settings.sliderMinValuePadding,
            maxValuePadding: settings.sliderMaxValuePadding,
            orientation: isPortrait ? .portrait : .landscape,
            previousHandleValue: nil,
            previousHandlePadding: 10
        ).frame(width: width, height: height)
    }

    private func indicator(isPortrait: Bool, settings: TimeChartGeometrySettings) -> some View {
        let width: CGFloat = isPortrait ? 25 : chartSize
        let height: CGFloat = isPortrait ? chartSize : 25
        return CustomSlider(
            value: isPortrait ? $concentration : $time,
            minValue: isPortrait ? minConcentration : minTime,
            maxValue: isPortrait ? maxConcentration : maxTime,
            handleThickness: 2,
            handleColor: Color.orangeAccent,
            handleCornerRadius: 0,
            barThickness: 0,
            barColor: Color.darkGray,
            minValuePadding: settings.sliderMinValuePadding,
            maxValuePadding: settings.sliderMaxValuePadding,
            orientation: isPortrait ? .portrait : .landscape,
            previousHandleValue: nil,
            previousHandlePadding: 10
        ).frame(width: width, height: height).disabled(true)
    }
}

struct TimeChartAxisView_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    struct ViewWrapper: View {
        @State private var c: CGFloat = 0.5
        @State private var t: CGFloat = 0.5

        var body: some View {
            TimeChartAxisView(
                concentration: $c,
                time: $t,
                minConcentration: 0,
                maxConcentration: 1,
                minTime: 0,
                maxTime: 10,
                chartSize: 250
            )
        }
    }
}
