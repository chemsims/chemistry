//
// Reactions App
//
  

import SwiftUI

struct TimeChartAxisView<Value: BinaryFloatingPoint>: View {

    @Binding var initialConcentration: Value
    @Binding var initialTime: Value

    @Binding var finalConcentration: Value?
    @Binding var finalTime: Value?

    let minConcentration: Value
    let maxConcentration: Value

    let minTime: Value
    let maxTime: Value

    let chartSize: CGFloat

    let concentrationA: ConcentrationEquation
    let finalPlotTime: Double?

    var body: some View {
        makeView(
            using: TimeChartGeometrySettings(
                chartSize: chartSize,
                minConcentration: CGFloat(minConcentration),
                maxConcentration: CGFloat(maxConcentration),
                minTime: CGFloat(minTime),
                maxTime: CGFloat(maxTime)
            )
        )
    }

    private func makeView(using settings: TimeChartGeometrySettings) -> some View {
        HStack {
            VStack {
                Text("[A]")
                Text(concentrationLabel).foregroundColor(.orangeAccent)
            }
            .font(.system(size: settings.labelFontSize))
            .frame(width: settings.yLabelWidth)

            HStack(alignment: .top) {
                axisSlider(isPortrait: true, settings: settings)
                VStack {
                    chartWithData(settings)

                    axisSlider(isPortrait: false, settings: settings)

                    HStack {
                        Text("Time")
                            .frame(width: chartSize / 2, alignment: .trailing)

                        Text(timeLabel)
                            .foregroundColor(.orangeAccent)
                            .frame(width: chartSize / 2, alignment: .leading)
                    }.font(.system(size: settings.labelFontSize))
                }
            }
        }
    }

    private func chartWithData(_ settings: TimeChartGeometrySettings) -> some View {
        ZStack {
            TimeChartAxisShape(
                verticalTicks: settings.verticalTicks,
                horizontalTicks: settings.horizontalTicks,
                tickSize: settings.tickSize,
                gapToTop: settings.gapFromMaxTickToChart,
                gapToSide: settings.gapFromMaxTickToChart
            )
                .stroke()
                .overlay(verticalIndicator(settings: settings), alignment: .leading)
                .overlay(horizontalIndicator(settings: settings), alignment: .bottom)

            ConcentrationEquationPlotter(
                equation: concentrationA,
                yAxis: AxisPositionCalculations(
                    minValuePosition: CGFloat(chartSize - settings.sliderMinValuePadding),
                    maxValuePosition: CGFloat(settings.sliderMaxValuePadding),
                    minValue: CGFloat(minConcentration),
                    maxValue: CGFloat(maxConcentration)
                ),
                xAxis: AxisPositionCalculations(
                    minValuePosition: CGFloat(settings.sliderMinValuePadding),
                    maxValuePosition: CGFloat(chartSize - settings.sliderMaxValuePadding),
                    minValue: CGFloat(minTime),
                    maxValue: CGFloat(maxTime)
                ),
                initialTime: CGFloat(initialTime),
                finalTime: CGFloat(finalPlotTime ?? Double(initialTime))
            ).stroke()
        }.frame(width: chartSize, height: chartSize)
    }

    private var concentrationLabel: String {
        let value = finalConcentration ?? initialConcentration
        return "\(Double(value).str(decimals: 2)) M"
    }

    private var timeLabel: String {
        let value = finalTime ?? initialTime
        return "\(Double(value).str(decimals: 1)) s"
    }

    private func verticalIndicator(settings: TimeChartGeometrySettings) -> some View {
        indicator(isPortrait: true, settings: settings)
    }

    private func horizontalIndicator(settings: TimeChartGeometrySettings) -> some View {
        indicator(isPortrait: false, settings: settings)
    }

    private func axisSlider(isPortrait: Bool, settings: TimeChartGeometrySettings) -> some View {
        let width: CGFloat = isPortrait ? settings.sliderHandleWidth : chartSize
        let height: CGFloat = isPortrait ? chartSize : settings.sliderHandleWidth
        return makeSlider(
            isPortrait: isPortrait,
            settings: settings,
            isIndicator: false
        ).frame(width: width, height: height)
    }

    private func indicator(
        isPortrait: Bool,
        settings: TimeChartGeometrySettings
    ) -> some View {
        let width: CGFloat = isPortrait ? 25 : chartSize
        let height: CGFloat = isPortrait ? chartSize : 25
        return makeSlider(
            isPortrait: isPortrait,
            settings: settings,
            isIndicator: true
        ).frame(width: width, height: height).disabled(true)
    }

    private func makeSlider(
        isPortrait: Bool,
        settings: TimeChartGeometrySettings,
        isIndicator: Bool
    ) -> some View {
        DualValueSlider(
            value1: isPortrait ? $initialConcentration : $initialTime,
            value2: isPortrait ? $finalConcentration : $finalTime,
            axis: isPortrait ? settings.yAxis(Value.init) : settings.xAxis(Value.init),
            handleThickness: isIndicator ? 3 : settings.handleThickness,
            handleColor: Color.orangeAccent,
            disabledHandleColor: Color.gray,
            handleCornerRadius: isIndicator ? 0 : settings.handleCornerRadius,
            barThickness: isIndicator ? 0 : 3,
            barColor: Color.gray,
            orientation: isPortrait ? .portrait : .landscape,
            boundType: isPortrait ? .upper : .lower
        )
    }
}

struct TimeChartAxisView_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    struct ViewWrapper: View {
        @State private var c1: CGFloat = 0.7
        @State private var t1: CGFloat = 2
        @State private var c2: CGFloat? = 0.2
        @State private var t2: CGFloat? = 8

        var body: some View {
            VStack {
                TimeChartAxisView(
                    initialConcentration: $c1,
                    initialTime: $t1,
                    finalConcentration: .constant(nil),
                    finalTime: .constant(nil),
                    minConcentration: 0,
                    maxConcentration: 1,
                    minTime: 0,
                    maxTime: 10,
                    chartSize: 250,
                    concentrationA: LinearConcentration(t1: 0, c1: 0, t2: 1, c2: 1),
                    finalPlotTime: nil
                )

                TimeChartAxisView(
                    initialConcentration: $c1,
                    initialTime: $t1,
                    finalConcentration: $c2,
                    finalTime: $t2,
                    minConcentration: 0,
                    maxConcentration: 1,
                    minTime: 0,
                    maxTime: 10,
                    chartSize: 250,
                    concentrationA: LinearConcentration(
                        t1: Double(t1),
                        c1: Double(c1),
                        t2: Double(t2 ?? 0),
                        c2: Double(c2 ?? 0)
                    ),
                    finalPlotTime: Double(t2 ?? 0)
                )
            }

        }
    }
}
