//
// Reactions App
//
  

import SwiftUI

struct ConcentrationTimeChartView: View {

    @Binding var initialConcentration: CGFloat
    @Binding var initialTime: CGFloat

    @Binding var finalConcentration: CGFloat?
    @Binding var finalTime: CGFloat?

    let minConcentration: CGFloat
    let maxConcentration: CGFloat

    let minTime: CGFloat
    let maxTime: CGFloat

    let minFinalConcentration: CGFloat
    let minFinalTime: CGFloat

    let chartSize: CGFloat

    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation
    let currentTime: CGFloat?
    let headOpacity: Double

    var body: some View {
        makeView(
            using: TimeChartGeometrySettings(
                chartSize: chartSize,
                minConcentration: minConcentration,
                maxConcentration: maxConcentration,
                minTime: minTime,
                maxTime: maxTime,
                minFinalConcentration: minFinalConcentration,
                minFinalTime: minFinalTime
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
                    .foregroundColor(Color.darkGray)

                VStack {
                    if (currentTime == nil) {
                        chartWithIndicator(settings: settings)
                    } else if (finalTime != nil && finalConcentration != nil) {
                        chartWithData(
                            settings: settings,
                            currentTime: currentTime!,
                            finalTime: finalTime!,
                            finalConcentration: finalConcentration!
                        )
                    }

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

    private func chartWithData(
        settings: TimeChartGeometrySettings,
        currentTime: CGFloat,
        finalTime: CGFloat,
        finalConcentration: CGFloat
    ) -> some View {
        ConcentrationPlotView(
            settings: settings,
            concentrationA: concentrationA,
            concentrationB: concentrationB,
            initialConcentration: initialConcentration,
            finalConcentration: finalConcentration,
            initialTime: initialTime,
            currentTime: currentTime,
            finalTime: finalTime,
            headOpacity: headOpacity
        ).frame(width: chartSize, height: chartSize)
    }


    private func chartWithIndicator(settings: TimeChartGeometrySettings) -> some View {
        ChartAxisShape(
            verticalTicks: settings.verticalTicks,
            horizontalTicks: settings.horizontalTicks,
            tickSize: settings.tickSize,
            gapToTop: settings.gapFromMaxTickToChart,
            gapToSide: settings.gapFromMaxTickToChart
        )
            .stroke()
            .overlay(verticalIndicator(settings: settings), alignment: .leading)
            .overlay(horizontalIndicator(settings: settings), alignment: .bottom)
            .frame(width: chartSize, height: chartSize)
    }

    private var concentrationLabel: String {
        let value = finalConcentration ?? initialConcentration
        return "\(value.str(decimals: 2)) M"
    }

    private var timeLabel: String {
        let value = finalTime ?? initialTime
        return "\(value.str(decimals: 1)) s"
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
            axis: isPortrait ? settings.yAxis : settings.xAxis,
            handleThickness: isIndicator ? 3 : settings.handleThickness,
            handleColor: Color.orangeAccent,
            disabledHandleColor: Color.gray,
            handleCornerRadius: isIndicator ? 0 : settings.handleCornerRadius,
            barThickness: isIndicator ? 0 : 3,
            barColor: Color.gray,
            orientation: isPortrait ? .portrait : .landscape,
            primarySliderMin: isPortrait ? settings.minFinalConcentration : settings.minFinalTime,
            primaryValueBoundType: isPortrait ? .upper : .lower
        )
        .disabled(currentTime != nil)
        .compositingGroup()
        .colorMultiply(currentTime == nil ? .white : .gray)
        .opacity(currentTime == nil ? 1 : 0.3)
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
                ConcentrationTimeChartView(
                    initialConcentration: $c1,
                    initialTime: $t1,
                    finalConcentration: .constant(nil),
                    finalTime: .constant(nil),
                    minConcentration: 0,
                    maxConcentration: 1,
                    minTime: 0,
                    maxTime: 10,
                    minFinalConcentration: 0.1,
                    minFinalTime: 1,
                    chartSize: 250,
                    concentrationA: equation,
                    concentrationB: equation2,
                    currentTime: nil,
                    headOpacity: 1
                )

                ConcentrationTimeChartView(
                    initialConcentration: $c1,
                    initialTime: $t1,
                    finalConcentration: $c2,
                    finalTime: $t2,
                    minConcentration: 0,
                    maxConcentration: 1,
                    minTime: 0,
                    maxTime: 10,
                    minFinalConcentration: 0.1,
                    minFinalTime: 1,
                    chartSize: 250,
                    concentrationA: equation,
                    concentrationB: equation2,
                    currentTime: t2!,
                    headOpacity: 1
                )
            }
        }
        private var equation: LinearConcentration {
            LinearConcentration(
                t1: t1,
                c1: c1,
                t2: t2 ?? 0,
                c2: c2 ?? 0
            )
        }

        private var equation2: LinearConcentration {
            LinearConcentration(
                t1: t1,
                c1: c2 ?? 0,
                t2: t2 ?? 0,
                c2: c1
            )
        }
    }
}
