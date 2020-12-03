//
// Reactions App
//


import SwiftUI

struct ReactionComparisonScreen2: View {

    @ObservedObject var reaction: ReactionComparisonViewModel
    @ObservedObject var navigation: ReactionNavigationViewModel<ReactionState>

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    private func makeView(settings: OrderedReactionLayoutSettings) -> some View {
        ZStack {
            beakers(settings: settings)
            beaky(settings: settings)
                .padding(.bottom, settings.beakyBottomPadding)
                .padding(.trailing, settings.beakyRightPadding)

            chartsView2(
                settings: TimeChartGeometrySettings(chartSize: chartSize(settings: settings)),
                settings2: settings
            ).padding(.top, settings.chartsTopPadding)

            equationView(settings: settings)
                .padding(.horizontal, equationPadding(settings: settings))
                .padding(.top, equationPadding(settings: settings))
        }
    }

    private func chartsView(
        settings: TimeChartGeometrySettings
    ) -> some View {
        VStack {
            ZStack {
                if (reaction.currentTime == nil) {
                    ChartAxisShape(
                       verticalTicks: settings.verticalTicks,
                       horizontalTicks: settings.horizontalTicks,
                       tickSize: settings.tickSize,
                       gapToTop: settings.gapFromMaxTickToChart,
                       gapToSide: settings.gapFromMaxTickToChart
                   )
                   .stroke()

                    CircleIconButton(
                        action: navigation.next,
                        systemImage: Icons.rightArrow,
                        background: .clear,
                        border: .black,
                        foreground: .orangeAccent
                    )
                    .frame(width: settings.chartSize * 0.5)
                }

                if (reaction.currentTime != nil) {
                    ConcentrationPlotView(
                        settings: settings,
                        concentrationA: zeroOrder,
                        concentrationB: nil,
                        initialConcentration: 1,
                        finalConcentration: 0.1,
                        initialTime: 0,
                        currentTime: unsafeCurrentTimeBinding,
                        finalTime: 1,
                        canSetCurrentTime: reaction.reactionHasEnded,
                        minTime: reaction.zeroOrderInput.t1,
                        maxTime: reaction.zeroOrderInput.t2
                    )
                    chartLine(
                        equation: firstOrder,
                        input: reaction.firstOrderInput,
                        settings: settings
                    )
                    chartLine(
                        equation: secondOrder,
                        input: reaction.secondOrderInput,
                        settings: settings
                    )
                }

            }.frame(width: settings.chartSize, height: settings.chartSize)

        }
    }

    private func chartsView2(settings: TimeChartGeometrySettings, settings2: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 1) {
            Spacer()
            VStack(spacing: 1) {
                Text("[A]")
                    .foregroundColor(.black)
                concentrationLabel(equation: zeroOrder, settings: settings)
                concentrationLabel(equation: firstOrder, settings: settings)
                concentrationLabel(equation: secondOrder, settings: settings)
            }
            .foregroundColor(.orangeAccent)
            VStack(spacing: 1) {
                chartsView(settings: settings)
                Text("Time (s)")
                animatingValue(equation: IdentityEquation(), defaultValue: 0, decimals: 1)
                    .frame(width: settings.chartSize * 0.2, height: settings.chartSize * 0.18, alignment: .leading)
                    .padding(.leading, settings.chartSize * 0.05)
                    .foregroundColor(.orangeAccent)
            }
            Spacer()
                .frame(width: equationWidth(settings: settings2) + (2 * equationPadding(settings: settings2)))
        }
        .font(.system(size: settings.labelFontSize * 0.8))
        .lineLimit(1)
    }

    private func concentrationLabel(
        equation: Equation,
        settings: TimeChartGeometrySettings
    ) -> some View {
        animatingValue(
            equation: equation,
            defaultValue: equation.getY(at: 0),
            decimals: 2
        )
        .frame(
            width: settings.chartSize * 0.22,
            height: settings.chartSize * 0.2,
            alignment: .leading
        )
        .padding(.leading, settings.chartSize * 0.05)
    }

    private func animatingValue(
        equation: Equation,
        defaultValue: CGFloat?,
        decimals: Int
    ) -> some View {
        if (reaction.currentTime == nil) {
            return AnyView(Text(defaultValue?.str(decimals: decimals) ?? ""))
        }
        return AnyView(
            AnimatingNumber(
                x: reaction.currentTime!,
                equation: equation,
                formatter: { $0.str(decimals: decimals)},
                alignment: .leading
            )
        )
    }

    private var unsafeCurrentTimeBinding: Binding<CGFloat> {
        Binding(
            get: { reaction.currentTime ?? reaction.initialTime },
            set: { reaction.currentTime = $0 }
        )
    }

    private func currentTimeBindingWithLimits(
        minValue: CGFloat,
        maxValue: CGFloat
    ) -> Binding<CGFloat> {
        Binding(
            get: {
                let value = reaction.currentTime ?? reaction.initialTime
                return min(maxValue, max(value, minValue))
            },
            set: {
                reaction.currentTime = $0
            }
        )
    }

    private func beaky(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                BeakyBox(
                    statement: navigation.statement,
                    next: navigation.next,
                    back: navigation.back,
                    verticalSpacing: settings.beakyVSpacing,
                    bubbleWidth: settings.bubbleWidth,
                    bubbleHeight: settings.bubbleHeight,
                    beakyHeight: settings.beakyHeight,
                    fontSize: settings.bubbleFontSize,
                    navButtonSize: settings.navButtonSize,
                    bubbleStemWidth: settings.bubbleStemWidth
                )
            }
        }
    }

    private func beakers(settings: OrderedReactionLayoutSettings) -> some View {
        HStack {
            VStack {
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB:
                        bConcentration(
                            aConcentration: zeroOrder,
                            input: reaction.zeroOrderInput
                        ),
                    currentTime: reaction.currentTime
                )
                .frame(width: settings.beakerWidth * 0.85)
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB:
                        bConcentration(
                            aConcentration: firstOrder,
                            input: reaction.firstOrderInput
                        ),
                    currentTime: reaction.currentTime
                )
                .frame(width: settings.beakerWidth * 0.85)
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB:
                        bConcentration(
                            aConcentration: secondOrder,
                            input: reaction.secondOrderInput
                        ),
                    currentTime: reaction.currentTime
                )
                .frame(width: settings.beakerWidth * 0.85)
            }.padding()
            Spacer()
        }
    }

    private func chartLine(
        equation: ConcentrationEquation,
        input: ReactionInput,
        settings: TimeChartGeometrySettings
    ) -> some View {
        ChartPlotWithHead(
            settings: settings,
            equation: equation,
            initialTime: 0,
            currentTime: unsafeCurrentTimeBinding,
            finalTime: 1,
            filledBarColor: Styling.timeAxisCompleteBar,
            headColor: Styling.moleculeA,
            headRadius: settings.chartHeadPrimarySize,
            haloColor: Styling.moleculeAChartHeadHalo,
            canSetCurrentTime: reaction.reactionHasEnded,
            minTime: input.t1,
            maxTime: input.t2
        ).frame(width: settings.chartSize, height: settings.chartSize)
    }

    private func equationView(
        settings: OrderedReactionLayoutSettings
    ) -> some View {
        VStack {
            HStack {
                Spacer()
                RateEquationComparisonView(
                    maxWidth: equationWidth(settings: settings),
                    maxHeight: equationHeight(settings: settings)
                )
            }
            Spacer()
        }
    }

    private func equationWidth(settings: OrderedReactionLayoutSettings) -> CGFloat {
        let availableWidth = (settings.width - chartSize(settings: settings)) / 2
        return availableWidth - (2 * equationPadding(settings: settings))
    }

    private func equationHeight(settings: OrderedReactionLayoutSettings) -> CGFloat {
        let availableHeight = settings.height - settings.beakyBoxTotalHeight
        return availableHeight - equationPadding(settings: settings)
    }

    private var zeroOrder: ConcentrationEquation  {
        reaction.zeroOrder
    }

    private var firstOrder: ConcentrationEquation {
        reaction.firstOrder
    }

    private var secondOrder: ConcentrationEquation {
        reaction.secondOrder
    }

    private func bConcentration(
        aConcentration: ConcentrationEquation,
        input: ReactionInput
    ) -> ConcentrationEquation {
        ConcentrationBEquation(
            concentrationA: aConcentration,
            initialAConcentration: input.c1
        )
    }


    private func chartSize(settings: OrderedReactionLayoutSettings) -> CGFloat {
        let availableWidth = settings.width - settings.beakerWidth - settings.beakerLeadingPadding - settings.beakyBoxTotalWidth
        let heightAboveBeaky = settings.height - settings.beakyBoxTotalHeight

        if (heightAboveBeaky > availableWidth) {
            return heightAboveBeaky * 0.8
        }
        return availableWidth * 0.7
    }

    private func equationPadding(
        settings: OrderedReactionLayoutSettings
    ) -> CGFloat {
        settings.chartsTopPadding * 0.5
    }

}

struct ReactionComparison2_Previews: PreviewProvider {
    static var previews: some View {
        StateWrapper()
            .previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        StateWrapper()
            .previewLayout(.fixed(width: 812, height: 375))

        StateWrapper()
            .previewLayout(.fixed(width: 1024, height: 768))
    }

    static let reaction = ReactionComparisonViewModel(persistence: InMemoryReactionInputPersistence())
    static let navigation = ReactionComparisonNavigation.model(reaction: reaction)

    struct StateWrapper: View {
        var body: some View {
            ReactionComparisonScreen2(
                reaction: reaction,
                navigation: navigation
            )
        }
    }
}
