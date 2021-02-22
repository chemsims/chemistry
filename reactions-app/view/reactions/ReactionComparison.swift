//
// Reactions App
//

import SwiftUI

struct ReactionComparisonScreen: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel
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
            beaker(settings: settings)
            beaky(settings: settings)
                .padding(.bottom, settings.beakyBottomPadding)
                .padding(.trailing, settings.beakyRightPadding)

            chartsView(
                settings: TimeChartGeometrySettings(chartSize: chartSize(settings: settings))
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
                if reaction.currentTime == nil {
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

                if reaction.currentTime != nil {
                    ConcentrationPlotView(
                        settings: settings,
                        concentrationA: zeroOrder,
                        concentrationB: nil,
                        initialConcentration: c1,
                        finalConcentration: c2,
                        initialTime: 0,
                        currentTime: unsafeCurrentTimeBinding,
                        finalTime: time,
                        canSetCurrentTime: reaction.reactionHasEnded
                    )
                    chartLine(equation: firstOrder, settings: settings)
                    chartLine(equation: secondOrder, settings: settings)
                }

            }.frame(width: settings.chartSize, height: settings.chartSize)

            Spacer()
        }
    }

    private var unsafeCurrentTimeBinding: Binding<CGFloat> {
        Binding(
            get: { reaction.currentTime! },
            set: { reaction.currentTime = $0 }
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

    private func beaker(settings: OrderedReactionLayoutSettings) -> some View {
        HStack {
            VStack {
                Spacer()
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB: reaction.concentrationEquationB,
                    currentTime: reaction.currentTime
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, settings.beakerLeadingPadding)
                .padding(.bottom, settings.beakerLeadingPadding)
            }
            Spacer()
        }
    }

    private func chartLine(
        equation: ConcentrationEquation,
        settings: TimeChartGeometrySettings
    ) -> some View {
        ChartPlotWithHead(
            settings: settings,
            equation: equation,
            initialTime: 0,
            currentTime: unsafeCurrentTimeBinding,
            finalTime: time,
            filledBarColor: Styling.timeAxisCompleteBar,
            headColor: Styling.moleculeA,
            headRadius: settings.chartHeadPrimarySize,
            haloColor: Styling.moleculeAChartHeadHalo,
            canSetCurrentTime: reaction.reactionHasEnded
        ).frame(width: settings.chartSize, height: settings.chartSize)
    }

    private func equationView(
        settings: OrderedReactionLayoutSettings
    ) -> some View {

        let availableWidth = (settings.width - chartSize(settings: settings)) / 2
        let widthLessPadding = availableWidth - (2 * equationPadding(settings: settings))

        let availableHeight = settings.height - settings.beakyBoxTotalHeight
        let heightLessPadding = availableHeight - equationPadding(settings: settings)

        return VStack {
            HStack {
                Spacer()
                RateEquationComparisonView(
                    maxWidth: widthLessPadding,
                    maxHeight: heightLessPadding
                )
            }
            Spacer()
        }
    }

    private var zeroOrder: ConcentrationEquation {
        LinearConcentration(
            t1: 0,
            c1: c1,
            t2: time,
            c2: c2
        )
    }

    private var firstOrder: ConcentrationEquation {
        FirstOrderConcentration(
            c1: c1,
            c2: c2,
            time: time
        )
    }

    private var secondOrder: ConcentrationEquation {
        SecondOrderReactionEquation(
            c1: c1,
            c2: c2,
            time: time
        )
    }

    private func chartSize(settings: OrderedReactionLayoutSettings) -> CGFloat {
        let availableWidth = settings.width - settings.beakerWidth - settings.beakerLeadingPadding - settings.beakyBoxTotalWidth
        let heightAboveBeaky = settings.height - settings.beakyBoxTotalHeight

        if heightAboveBeaky > availableWidth {
            return heightAboveBeaky * 0.8
        }
        return availableWidth * 0.7
    }

    private func equationPadding(
        settings: OrderedReactionLayoutSettings
    ) -> CGFloat {
        settings.chartsTopPadding * 0.5
    }

    private var c1: CGFloat { ReactionComparisonNavigation.c1 }
    private var c2: CGFloat { ReactionComparisonNavigation.c2 }
    private var time: CGFloat { ReactionComparisonNavigation.time }

}

struct ReactionComparison_Previews: PreviewProvider {
    static var previews: some View {
        StateWrapper()
            .previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        StateWrapper()
            .previewLayout(.fixed(width: 812, height: 375))

        StateWrapper()
            .previewLayout(.fixed(width: 1024, height: 768))
    }

    static let reaction = ZeroOrderReactionViewModel()
    static let navigation = ReactionComparisonNavigation.model(reaction: reaction)

    struct StateWrapper: View {
        var body: some View {
            ReactionComparisonScreen(
                reaction: reaction,
                navigation: navigation
            )
        }
    }
}
