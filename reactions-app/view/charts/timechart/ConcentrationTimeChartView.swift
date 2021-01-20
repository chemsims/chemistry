//
// Reactions App
//
  

import SwiftUI

// TODO remove values which can be obtained from reactionInput
struct ConcentrationTimeChartView: View {
    @Binding var initialConcentration: CGFloat
    @Binding var initialTime: CGFloat

    @Binding var finalConcentration: CGFloat?
    @Binding var finalTime: CGFloat?

    let settings: TimeChartGeometrySettings
    let concentrationA: Equation?
    let concentrationB: Equation?
    @Binding var currentTime: CGFloat?
    let canSetInitialTime: Bool
    let canSetCurrentTime: Bool
    let highlightChart: Bool
    let highlightLhsCurve: Bool
    let highlightRhsCurve: Bool

    let canSetC2: Bool
    let canSetT2: Bool
    let showDataAtT2: Bool

    let input: ReactionInputModel
    let display: ReactionPairDisplay

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
            yLabel: "[\(display.reactant.name)]",
            includeValuesInLabel: true,
            canSetCurrentTime: canSetCurrentTime,
            highlightChart: highlightChart,
            highlightLhsCurve: highlightLhsCurve,
            highlightRhsCurve: highlightRhsCurve,
            canSetC2: canSetC2,
            canSetT2: canSetT2,
            showDataAtT2: showDataAtT2,
            input: input,
            display: display
        )
    }
}

struct SingleConcentrationPlot: View {
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let finalConcentration: CGFloat?
    let finalTime: CGFloat?
    let settings: TimeChartGeometrySettings
    let concentrationA: Equation?
    @Binding var currentTime: CGFloat?
    let yLabel: String
    let canSetCurrentTime: Bool
    let highlightChart: Bool
    let showDataAtT2: Bool
    let input: ReactionInputModel
    let display: ReactionPairDisplay

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
            canSetCurrentTime: canSetCurrentTime,
            highlightChart: highlightChart,
            highlightLhsCurve: false,
            highlightRhsCurve: false,
            canSetC2: true,
            canSetT2: true,
            showDataAtT2: showDataAtT2,
            input: input,
            display: display
        )
    }
}

struct GeneralTimeChartView: View {

    @Binding var initialConcentration: CGFloat
    @Binding var initialTime: CGFloat

    @Binding var finalConcentration: CGFloat?
    @Binding var finalTime: CGFloat?

    let settings: TimeChartGeometrySettings
    let concentrationA: Equation?
    let concentrationB: Equation?
    @Binding var currentTime: CGFloat?
    let canSetInitialTime: Bool
    let includeSliders: Bool
    let yLabel: String
    let includeValuesInLabel: Bool
    let canSetCurrentTime: Bool

    let highlightChart: Bool
    let highlightLhsCurve: Bool
    let highlightRhsCurve: Bool

    let canSetC2: Bool
    let canSetT2: Bool

    let showDataAtT2: Bool

    let input: ReactionInputModel
    let display: ReactionPairDisplay

    var body: some View {
        HStack(spacing: settings.chartHStackSpacing) {
            concentrationLabel

            HStack(alignment: .top, spacing: settings.chartHStackSpacing) {
                if (includeSliders) {
                    concentrationSlider
                }

                VStack(spacing: settings.chartVStackSpacing) {
                    if (showIndicatorLines) {
                        chartWithIndicator
                    } else if (
                        finalTime != nil &&
                            finalConcentration != nil &&
                            concentrationA != nil
                    ) {
                        ZStack {
                            if (showDataAtT2) {
                                chartWithData(
                                    concentrationA: concentrationA!,
                                    currentTime: unsafeT2Binding,
                                    finalTime: finalTime!,
                                    finalConcentration: finalConcentration!
                                )
                            }

                            if (currentTime != nil) {
                                chartWithData(
                                    concentrationA: concentrationA!,
                                    currentTime: unsafeCurrentTimeBinding,
                                    finalTime: finalTime!,
                                    finalConcentration: finalConcentration!
                                )
                            }
                        }
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

    private var showIndicatorLines: Bool {
        if (showDataAtT2) {
            return finalTime == nil
        }
        return currentTime == nil
    }

    private var concentrationLabel: some View {
        VStack(spacing: 1) {
            Text(yLabel)
                .fixedSize()
            if (includeValuesInLabel) {
                HStack(spacing: 1) {
                    animatingConcentration
                        .frame(
                            width: settings.yLabelWidth * 0.7,
                            height: settings.chartSize * 0.18, alignment: .leading
                        )
                    Text("M")
                        .fixedSize()
                }
                .foregroundColor(.orangeAccent)
            }
        }
        .font(.system(size: settings.labelFontSize))
        .frame(width: settings.yLabelWidth)
        .minimumScaleFactor(1)
    }

    private var timeLabel: some View {
        HStack(spacing: 1) {
            Text("Time")
                .fixedSize()
            if (includeValuesInLabel) {
                HStack(spacing: 1) {
                    animatingTime
                        .frame(width: settings.chartSize * 0.25, alignment: .leading)
                        .padding(.leading, settings.chartSize * 0.05)
                    Text("s")
                        .fixedSize()
                }
                .foregroundColor(.orangeAccent)
            }
        }
        .frame(height: settings.xLabelHeight)
        .font(.system(size: settings.labelFontSize))
        .minimumScaleFactor(1)
    }

    private var concentrationSlider: some View {
        ConcentrationValueSlider(
            initialConcentration: $initialConcentration,
            finalConcentration: canSetC2 ? $finalConcentration : .constant(nil),
            c1Disabled: finalConcentration != nil,
            c1Limits: limits.c1Limits,
            c2Limits: limits.c2Limits,
            settings: settings
        )
        .frame(
            width: settings.sliderHandleWidth,
            height: settings.chartSize
        ).modifier(
            DisabledSliderModifier(disabled: currentTime != nil)
        )
    }

    private var timeSlider: some View {
        TimeValueSlider(
            t1: $initialTime,
            t2: canSetT2 ? $finalTime : .constant(nil),
            canSetInitialTime: canSetInitialTime,
            t1Disabled: finalTime != nil,
            t1Limits: limits.t1Limits,
            t2Limits: limits.t2Limits,
            settings: settings
        ).frame(
            width: settings.chartSize,
            height: settings.sliderHandleWidth
        ).modifier(DisabledSliderModifier(disabled: currentTime != nil))
    }

    private var animatingTime: some View {
        animatingValue(
            equation: IdentityEquation(),
            defaultValue: finalTime ?? initialTime,
            decimals: 1
        )
    }

    private var animatingConcentration: some View {
        animatingValue(
            equation: concentrationA,
            defaultValue: finalConcentration ?? initialConcentration,
            decimals: 2
        )
    }

    private func animatingValue(
        equation: Equation?,
        defaultValue: CGFloat,
        decimals: Int
    ) -> some View {
        if (currentTime == nil || equation == nil) {
            return
                AnyView(
                    Text(defaultValue.str(decimals: decimals))
                        .minimumScaleFactor(0.5)
                )
        }

        return AnyView(
            AnimatingNumber(
                x: currentTime!,
                equation: equation!,
                formatter: { $0.str(decimals: decimals)},
                alignment: .leading
            ).minimumScaleFactor(0.5)
        )
    }

    private func chartWithData(
        concentrationA: Equation,
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
            canSetCurrentTime: canSetCurrentTime,
            highlightChart: highlightChart,
            highlightLhsCurve: highlightLhsCurve,
            highlightRhsCurve: highlightRhsCurve,
            display: display
        ).frame(
            width: settings.chartSize,
            height: settings.chartSize
        )
    }

    private var unsafeCurrentTimeBinding: Binding<CGFloat> {
        Binding(
            get: { currentTime! },
            set: { currentTime = $0 }
        )
    }

    private var unsafeT2Binding: Binding<CGFloat> {
        Binding(
            get: { initialTime },
            set: { initialTime = $0 }
        )
    }

    private var chartWithIndicator: some View {
        let axis = ZStack {
            Rectangle()
                .fill(Color.white)
            ChartAxisShape(
                verticalTicks: settings.verticalTicks,
                horizontalTicks: settings.horizontalTicks,
                tickSize: settings.tickSize,
                gapToTop: settings.gapFromMaxTickToChart,
                gapToSide: settings.gapFromMaxTickToChart
            ).stroke()
        }.frame(width: settings.chartSize, height: settings.chartSize)

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

    private var limits: ReactionInputLimits {
        input.limits(cAbsoluteSpacing: cAbsoluteSpacing, tAbsoluteSpacing: tAbsoluteSpacing)
    }

    private var cAbsoluteSpacing: CGFloat {
        settings.yAxis.valueForDistance(spacing)
    }

    private var tAbsoluteSpacing: CGFloat {
        settings.xAxis.valueForDistance(spacing)
    }

    private var spacing: CGFloat {
        settings.inputSpacing
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
            concentrationA: ConstantEquation(value: 1),
            concentrationB: ConstantEquation(value: 1),
            currentTime: .constant(nil),
            canSetInitialTime: true,
            canSetCurrentTime: true,
            highlightChart: false,
            highlightLhsCurve: false,
            highlightRhsCurve: false,
            canSetC2: true,
            canSetT2: true,
            showDataAtT2: false,
            input: ReactionInputAllProperties(order: .Zero),
            display: ReactionType.A.display
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
                concentrationA: ConstantEquation(value: 1),
                currentTime: .constant(nil),
                yLabel: "foo",
                canSetCurrentTime: true,
                highlightChart: true,
                showDataAtT2: false,
                input: ReactionInputAllProperties(order: .Zero),
                display: ReactionType.A.display
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
                    canSetCurrentTime: true,
                    highlightChart: false,
                    highlightLhsCurve: false,
                    highlightRhsCurve: false,
                    canSetC2: true,
                    canSetT2: true,
                    showDataAtT2: false,
                    input: ReactionInputAllProperties(order: .Zero),
                    display: ReactionType.A.display
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
                    canSetCurrentTime: true,
                    highlightChart: false,
                    highlightLhsCurve: false,
                    highlightRhsCurve: false,
                    canSetC2: true,
                    canSetT2: true,
                    showDataAtT2: false,
                    input: ReactionInputAllProperties(order: .Zero),
                    display: ReactionType.A.display
                )
            }
        }
        private var equation: ConcentrationEquation {
            ZeroOrderConcentration(
                t1: t1,
                c1: c1,
                t2: t2 ?? 0,
                c2: c2 ?? 0
            )
        }

        private var equation2: ConcentrationEquation {
            ZeroOrderConcentration(
                t1: t1,
                c1: c2 ?? 0,
                t2: t2 ?? 0,
                c2: c1
            )
        }
    }
}
