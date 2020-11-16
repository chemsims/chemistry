//
// Reactions App
//
  

import SwiftUI

struct ConcentrationTimeChartView: View {

    @Binding var initialConcentration: CGFloat
    @Binding var initialTime: CGFloat

    @Binding var finalConcentration: CGFloat?
    @Binding var finalTime: CGFloat?

    let settings: TimeChartGeometrySettings
    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation
    let currentTime: CGFloat?
    let headOpacity: Double

    var body: some View {
        HStack {
            VStack {
                Text("[A]")
                Text(concentrationLabel).foregroundColor(.orangeAccent)
            }
            .font(.system(size: settings.labelFontSize))
            .frame(width: settings.yLabelWidth)

            HStack(alignment: .top) {

                ConcentrationValueSlider(
                    initialConcentration: $initialConcentration,
                    finalConcentration: $finalConcentration,
                    settings: settings
                )
                .frame(
                    width: settings.sliderHandleWidth,
                    height: settings.chartSize
                ).modifier(DisabledSliderModifier(disabled: currentTime != nil))

                VStack {
                    if (currentTime == nil) {
                        chartWithIndicator
                    } else if (finalTime != nil && finalConcentration != nil) {
                        chartWithData(
                            currentTime: currentTime!,
                            finalTime: finalTime!,
                            finalConcentration: finalConcentration!
                        )
                    }

                    TimeValueSlider(
                        t1: $initialTime,
                        t2: $finalTime,
                        settings: settings
                    ).frame(
                        width: settings.chartSize,
                        height: settings.sliderHandleWidth
                    ).modifier(DisabledSliderModifier(disabled: currentTime != nil))

                    HStack {
                        Text("Time")
                            .frame(width: settings.chartSize / 2, alignment: .trailing)

                        Text(timeLabel)
                            .foregroundColor(.orangeAccent)
                            .frame(width: settings.chartSize / 2, alignment: .leading)
                    }.font(.system(size: settings.labelFontSize))
                }
            }
        }
    }

    private func chartWithData(
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
        ).frame(width: settings.chartSize, height: settings.chartSize)
    }


    private var chartWithIndicator: some View {
        ChartAxisShape(
            verticalTicks: settings.verticalTicks,
            horizontalTicks: settings.horizontalTicks,
            tickSize: settings.tickSize,
            gapToTop: settings.gapFromMaxTickToChart,
            gapToSide: settings.gapFromMaxTickToChart
        )
            .stroke()
            .overlay(verticalIndicator, alignment: .leading)
            .overlay(horizontalIndicator, alignment: .bottom)
        .frame(width: settings.chartSize, height: settings.chartSize)
    }

    private var verticalIndicator: some View {
        SliderIndicator(
            value1: initialConcentration,
            value2: finalConcentration,
            settings: settings,
            axis: settings.yAxis,
            orientation: .portrait
        ).frame(width: 25, height: settings.chartSize)
    }

    private var horizontalIndicator: some View {
        SliderIndicator(
            value1: initialTime,
            value2: finalTime,
            settings: settings,
            axis: settings.xAxis,
            orientation: .landscape
        ).frame(width: settings.chartSize, height: 25)
    }

    private var concentrationLabel: String {
        let value = finalConcentration ?? initialConcentration
        return "\(value.str(decimals: 2)) M"
    }

    private var timeLabel: String {
        let value = finalTime ?? initialTime
        return "\(value.str(decimals: 1)) s"
    }
}

struct DisabledSliderModifier: ViewModifier {
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .disabled(disabled)
            .compositingGroup()
            .colorMultiply(disabled ? .gray : .white)
            .opacity(disabled ? 0.3 : 1)
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
                    settings: TimeChartGeometrySettings(
                        chartSize: 300
                    ),
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
                    settings: TimeChartGeometrySettings(
                        chartSize: 300
                    ),
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
