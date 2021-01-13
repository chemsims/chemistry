//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionScreen: View {

    @ObservedObject var reaction: FirstOrderReactionViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeBody(
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    private func makeBody(settings: OrderedReactionLayoutSettings) -> some View {
        OrderedReactionScreen(
            reaction: reaction,
            settings: settings,
            canSetInitialTime: reaction.usedReactions.count > 1,
            showRate: true
        ) {
            VStack {
                Spacer()
                    .frame(height: settings.topStackSize)
                HStack(spacing: 0) {
                    logChart(settings: settings)
                        .padding(.top, settings.secondaryChartPadding)
                        .padding(.leading, settings.secondaryChartPadding)

                    equationView(settings: settings)
                        .padding(settings.equationPadding)

                    Spacer()
                        .frame(width: settings.beakyBoxTotalWidth)
                }
            }
        }
    }

    private func logChart(settings: OrderedReactionLayoutSettings) -> some View {
        SingleConcentrationPlot(
            initialConcentration: reaction.input.inputC1,
            initialTime: reaction.input.inputT1,
            finalConcentration: reaction.input.inputC2,
            finalTime: reaction.input.inputT2,
            settings: TimeChartGeometrySettings(
                chartSize: settings.chartSize,
                minConcentration: ReactionSettings.minLogConcentration,
                maxConcentration: ReactionSettings.maxLogConcentration
            ),
            concentrationA: reaction.logAEquation,
            currentTime: $reaction.currentTime,
            yLabel: "ln(A)",
            canSetCurrentTime: reaction.reactionHasEnded,
            highlightChart: reaction.highlight(element: .secondaryChart)
        )
        .colorMultiply(reaction.color(for: .secondaryChart))
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        GeometryReader { geometry in
            FirstOrderEquationView(
                emphasiseFilledTerms: reaction.currentTime == nil,
                c1: reaction.input.inputC1,
                c2: reaction.input.inputC2,
                t: reaction.input.inputT2,
                currentTime: reaction.currentTime,
                concentration: reaction.input.concentrationA,
                reactionHasStarted: reaction.reactionHasStarted,
                rateConstantColor: reaction.color(for: .rateConstantEquation),
                halfLifeColor: reaction.color(for: .halfLifeEquation),
                rateColor: reaction.color(for: .rateEquation),
                maxWidth: geometry.size.width,
                maxHeight: geometry.size.height
            )
        }
    }
}


struct FirstOrderReaction_Previews: PreviewProvider {
    
    static var previews: some View {

        // iPhone SE landscape
        StateWrapper()
            .previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        StateWrapper()
            .previewLayout(.fixed(width: 812, height: 375))

        StateWrapper()
            .previewLayout(.fixed(width: 1024, height: 768))
    }

    struct StateWrapper: View {

        @ObservedObject var foo = FirstOrderReactionNavigation.model(reaction: FirstOrderReactionViewModel(), persistence: InMemoryReactionInputPersistence())

        var body: some View {
            FirstOrderReactionScreen(
                reaction: foo.model as! FirstOrderReactionViewModel
            )
        }
    }
}
