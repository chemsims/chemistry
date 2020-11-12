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

    private let verticalTicks = 10
    private let horizontalTicks = 10
    private var tickSize: CGFloat {
        0.04 * chartSize
    }
    private var gapFromMaxTickToChart: CGFloat {
        0.24 * chartSize
    }
    private var sliderHandleWidth: CGFloat {
        0.16 * chartSize
    }
    private var sliderHandleThickness: CGFloat {
        0.16 * chartSize
    }
    private var sliderMinValuePadding: CGFloat {
        0.1 * chartSize
    }
    private var sliderMaxValuePadding: CGFloat {
        0.28 * chartSize
    }
    private var yLabelWidth: CGFloat {
        0.32 * chartSize
    }
    private var handleThickness: CGFloat {
        0.08 * chartSize
    }
    private var handleCornerRadius: CGFloat {
        handleThickness * 0.25
    }
    private var labelFontSize: CGFloat {
        0.06 * chartSize
    }


    var body: some View {
        HStack {
            VStack {
                Text("[A]")
                Text("\(Double(concentration), specifier: "%.2f") M").foregroundColor(.orangeAccent)
            }
            .font(.system(size: labelFontSize))
            .frame(width: yLabelWidth)

            HStack(alignment: .top) {
                slider(isPortrait: true)
                VStack {
                    TimeChartAxisShape(
                        verticalTicks: verticalTicks,
                        horizontalTicks: horizontalTicks,
                        tickSize: tickSize,
                        gapToTop: gapFromMaxTickToChart,
                        gapToSide: gapFromMaxTickToChart
                    )
                        .stroke()
                        .frame(width: chartSize, height: chartSize)
                        .overlay(verticalIndicator, alignment: .leading)
                        .overlay(horizontalIndicator, alignment: .bottom)

                    slider(isPortrait: false)

                    HStack {
                        Text("Time")
                            .frame(width: chartSize / 2, alignment: .trailing)

                        Text("\(Double(time), specifier: "%.1f") s")
                            .foregroundColor(.orangeAccent)
                            .frame(width: chartSize / 2, alignment: .leading)
                    }.font(.system(size: labelFontSize))
                }
            }
        }
    }

    private var verticalIndicator: some View {
        indicator(isPortrait: true)
    }

    private var horizontalIndicator: some View {
        indicator(isPortrait: false)
    }

    private func slider(isPortrait: Bool) -> some View {
        let width: CGFloat = isPortrait ? sliderHandleWidth : chartSize
        let height: CGFloat = isPortrait ? chartSize : sliderHandleWidth
        return CustomSlider(
            value: isPortrait ? $concentration : $time,
            minValue: isPortrait ? minConcentration : minTime,
            maxValue: isPortrait ? maxConcentration : maxTime,
            handleThickness: handleThickness,
            handleColor: Color.orangeAccent,
            handleCornerRadius: handleCornerRadius,
            barThickness: 3,
            barColor: Color.darkGray,
            minValuePadding: sliderMinValuePadding,
            maxValuePadding: sliderMaxValuePadding,
            orientation: isPortrait ? .portrait : .landscape
        ).frame(width: width, height: height)
    }

    private func indicator(isPortrait: Bool) -> some View {
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
            minValuePadding: sliderMinValuePadding,
            maxValuePadding: sliderMaxValuePadding,
            orientation: isPortrait ? .portrait : .landscape
        ).frame(width: width, height: height).disabled(true)
    }
}

struct TimeChartGeometrySettings {
    let geometry: GeometryProxy


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
