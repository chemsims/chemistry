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
    @Binding var currentTime: CGFloat?
    let canSetInitialTime: Bool
    let canSetCurrentTime: Bool

    var body: some View {
        GeneralTimeChartView(
            initialConcentration: $initialConcentration,
            initialTime: $initialTime,
            finalConcentration: $finalConcentration,
            finalTime: $finalTime,
            settings: settings,
            concentrationA: concentrationA,
            concentrationB: concentrationB,
            currentTime: $currentTime,
            canSetInitialTime: canSetInitialTime,
            includeSliders: true,
            yLabel: "[A]",
            includeValuesInLabel: true,
            canSetCurrentTime: canSetCurrentTime
        )
    }
}

struct SingleConcentrationPlot: View {
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let finalConcentration: CGFloat?
    let finalTime: CGFloat?
    let settings: TimeChartGeometrySettings
    let concentrationA: ConcentrationEquation
    @Binding var currentTime: CGFloat?
    let yLabel: String
    let canSetCurrentTime: Bool

    var body: some View {
        GeneralTimeChartView(
            initialConcentration: .constant(initialConcentration),
            initialTime: .constant(initialTime),
            finalConcentration: .constant(finalConcentration),
            finalTime: .constant(finalTime),
            settings: settings,
            concentrationA: concentrationA,
            concentrationB: nil,
            currentTime: $currentTime,
            canSetInitialTime: false,
            includeSliders: false,
            yLabel: yLabel,
            includeValuesInLabel: false,
            canSetCurrentTime: canSetCurrentTime
        )
    }
}

struct GeneralTimeChartView: View {

    @Binding var initialConcentration: CGFloat
    @Binding var initialTime: CGFloat

    @Binding var finalConcentration: CGFloat?
    @Binding var finalTime: CGFloat?

    let settings: TimeChartGeometrySettings
    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation?
    @Binding var currentTime: CGFloat?
    let canSetInitialTime: Bool
    let includeSliders: Bool
    let yLabel: String
    let includeValuesInLabel: Bool
    let canSetCurrentTime: Bool

    var body: some View {
        HStack {
            concentrationLabel

            HStack(alignment: .top) {
                if (includeSliders) {
                    concentrationSlider
                }

                VStack {
                    if (currentTime == nil) {
                        chartWithIndicator
                    } else if (finalTime != nil && finalConcentration != nil) {
                        chartWithData(
                            currentTime: unsafeCurrentTimeBinding,
                            finalTime: finalTime!,
                            finalConcentration: finalConcentration!
                        )
                    }
                    if (includeSliders) {
                        timeSlider
                    }
                    timeLabel
                }
            }
        }.lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    private var concentrationLabel: some View {
        VStack(spacing: 1) {
            Text(yLabel)
            if (includeValuesInLabel) {
                HStack(spacing: 1) {
                    animatingConcentration
                        .frame(height: settings.chartSize * 0.18)
                    Text("M")
                }
                .frame(width: settings.yLabelWidth, height: settings.chartSize * 0.18, alignment: .trailing)
                .foregroundColor(.orangeAccent)
            }
        }
        .font(.system(size: settings.labelFontSize))
        .frame(width: settings.yLabelWidth)
    }

    private var timeLabel: some View {
        HStack(spacing: 1) {
            Text("Time")
            if (includeValuesInLabel) {
                HStack(spacing: 1) {
                    animatingTime
                        .frame(width: settings.chartSize * 0.35, alignment: .trailing)
                    Text("s")
                        .fixedSize()
                }
                .foregroundColor(.orangeAccent)
                .frame(height: settings.chartSize * 0.1)
            }
        }.font(.system(size: settings.labelFontSize))
    }


    private var concentrationSlider: some View {
        ConcentrationValueSlider(
            initialConcentration: $initialConcentration,
            finalConcentration: $finalConcentration,
            settings: settings
        )
        .frame(
            width: settings.sliderHandleWidth,
            height: settings.chartSize
        ).modifier(DisabledSliderModifier(disabled: currentTime != nil))
    }

    private var timeSlider: some View {
        TimeValueSlider(
            t1: $initialTime,
            t2: $finalTime,
            settings: settings,
            canSetInitialTime: canSetInitialTime
        ).frame(
            width: settings.chartSize,
            height: settings.sliderHandleWidth
        ).modifier(DisabledSliderModifier(disabled: currentTime != nil))
    }

    private var animatingTime: some View {
        animatingValue(
            equation: IdentityEquation(),
            defaultValue: finalTime ?? initialTime
        )
    }

    private var animatingConcentration: some View {
        animatingValue(
            equation: concentrationA,
            defaultValue: finalConcentration ?? initialConcentration
        )

    }

    private func animatingValue(
        equation: Equation,
        defaultValue: CGFloat
    ) -> some View {
        if (currentTime == nil) {
            return AnyView(Text(defaultValue.str(decimals: 2)))
        }

        return AnyView(
            AnimatingNumberView(
                x: currentTime!,
                equation: equation,
                formatter: { $0.str(decimals: 2)}
            )
        )
    }

    private func chartWithData(
        currentTime: Binding<CGFloat>,
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
            canSetCurrentTime: canSetCurrentTime
        ).frame(width: settings.chartSize, height: settings.chartSize)
    }

    private var unsafeCurrentTimeBinding: Binding<CGFloat> {
        Binding(
            get: { currentTime! },
            set: { currentTime = $0 }
        )
    }


    private var chartWithIndicator: some View {
        let axis = ChartAxisShape(
            verticalTicks: settings.verticalTicks,
            horizontalTicks: settings.horizontalTicks,
            tickSize: settings.tickSize,
            gapToTop: settings.gapFromMaxTickToChart,
            gapToSide: settings.gapFromMaxTickToChart
        )
            .stroke()
            .frame(width: settings.chartSize, height: settings.chartSize)

        if (!includeSliders) {
            return AnyView(axis)
        }
        return AnyView(
            axis
            .overlay(verticalIndicator, alignment: .leading)
            .overlay(horizontalIndicator, alignment: .bottom)
        )
    }

    private var verticalIndicator: some View {
        SliderIndicator(
            value1: initialConcentration,
            value2: finalConcentration,
            showInitialValue: true,
            settings: settings,
            axis: settings.yAxis,
            orientation: .portrait
        ).frame(width: settings.indicatorWidth, height: settings.chartSize)
    }

    private var horizontalIndicator: some View {
        SliderIndicator(
            value1: initialTime,
            value2: finalTime,
            showInitialValue: canSetInitialTime,
            settings: settings,
            axis: settings.xAxis,
            orientation: .landscape
        ).frame(width: settings.chartSize, height: settings.indicatorWidth)
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
        ConcentrationTimeChartView(
            initialConcentration: .constant(1),
            initialTime: .constant(1),
            finalConcentration: .constant(nil),
            finalTime: .constant(nil),
            settings: TimeChartGeometrySettings(
                chartSize: 300
            ),
            concentrationA: ConstantConcentration(value: 1),
            concentrationB: ConstantConcentration(value: 1),
            currentTime: .constant(nil),
            canSetInitialTime: true,
            canSetCurrentTime: true
        )
        .previewLayout(.fixed(width: 500, height: 300))

            SingleConcentrationPlot(
                initialConcentration: 1,
                initialTime: 1,
                finalConcentration: 1,
                finalTime: 1,
                settings: TimeChartGeometrySettings(
                    chartSize: 300
                ),
                concentrationA: ConstantConcentration(value: 1),
                currentTime: .constant(nil),
                yLabel: "foo",
                canSetCurrentTime: true
            ).previewLayout(.fixed(width: 500, height: 300))
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
                    currentTime: .constant(nil),
                    canSetInitialTime: true,
                    canSetCurrentTime: true
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
                    currentTime: .constant(t2!),
                    canSetInitialTime: true,
                    canSetCurrentTime: true
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
