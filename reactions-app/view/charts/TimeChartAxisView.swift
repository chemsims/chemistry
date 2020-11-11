//
// Reactions App
//
  

import SwiftUI

struct TimeChartAxisView<Value>: View where Value: BinaryFloatingPoint {

    @Binding var concentration: Value
    @Binding var time: Value


    private let chartSize: CGFloat = 250
    private let verticalTicks = 10
    private let horizontalTicks = 10
    private let tickSize: CGFloat = 10
    private let gapFromMaxTickToChart: CGFloat = 60
    private let sliderHandleWidth: CGFloat = 40
    private let sliderHandleThickness: CGFloat = 40
    private let sliderLeadingPadding: CGFloat = 70
    private let sliderTrailingPadding: CGFloat = 25

    var body: some View {
        HStack {
            VStack {
                Text("[A]")
                Text("\(Double(concentration), specifier: "%.2f") M").foregroundColor(.orangeAccent)
            }.frame(minWidth: 80)

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

                    Text("Time ") + Text("\(Double(time), specifier: "%.1f") s").foregroundColor(.orangeAccent)
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
            minValue: 0,
            maxValue: 1,
            handleThickness: 20,
            handleColor: Color.orangeAccent,
            handleCornerRadius: 5,
            barThickness: 3,
            barColor: Color.darkGray,
            leadingPadding: sliderLeadingPadding,
            trailingPadding: sliderTrailingPadding,
            orientation: isPortrait ? .portrait : .landscape
        ).frame(width: width, height: height)
    }

    private func indicator(isPortrait: Bool) -> some View {
        let width: CGFloat = isPortrait ? 25 : chartSize
        let height: CGFloat = isPortrait ? chartSize : 25
        return CustomSlider(
            value: isPortrait ? $concentration : $time,
            minValue: 0,
            maxValue: 1,
            handleThickness: 2,
            handleColor: Color.orangeAccent,
            handleCornerRadius: 0,
            barThickness: 0,
            barColor: Color.darkGray,
            leadingPadding: sliderLeadingPadding,
            trailingPadding: sliderTrailingPadding,
            orientation: isPortrait ? .portrait : .landscape
        ).frame(width: width, height: height).disabled(true)
    }
}

struct TimeChartAxisView_Previews: PreviewProvider {
    static var previews: some View {
        TimeChartAxisView(
            concentration: .constant(0.5),
            time: .constant(0.5)
        )
    }
}
