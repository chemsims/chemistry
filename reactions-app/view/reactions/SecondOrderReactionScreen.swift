//
// Reactions App
//
  

import SwiftUI

struct SecondOrderReactionScreen: View {

    @ObservedObject var reaction: SecondOrderReactionViewModel
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
                    invChart(settings: settings)
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

    private func invChart(settings: OrderedReactionLayoutSettings) -> some View {
        SingleConcentrationPlot(
            initialConcentration: reaction.input.inputC1,
            initialTime: reaction.input.inputT1,
            finalConcentration: reaction.input.inputC2,
            finalTime: reaction.input.inputT2,
            settings: TimeChartGeometrySettings(
                chartSize: settings.chartSize,
                minConcentration: ReactionSettings.minInverseConcentration,
                maxConcentration: ReactionSettings.maxInverseConcentration
            ),
            concentrationA: reaction.inverseAEquation,
            currentTime: $reaction.currentTime,
            yLabel: "1/[A]",
            canSetCurrentTime: reaction.reactionHasEnded,
            highlightChart: reaction.highlight(element: .secondaryChart),
            showDataAtT2: reaction.showDataAtT2,
            input: reaction.input
        )
        .colorMultiply(reaction.color(for: .secondaryChart))
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        GeometryReader { geometry in
            SecondOrderEquationView(
                emphasiseFilledTerms: reaction.currentTime == nil,
                c1: reaction.input.inputC1,
                c2: reaction.input.inputC2,
                t: reaction.input.inputT2,
                currentTime: reaction.currentTime,
                concentration: reaction.input.concentrationA,
                reactionHasStarted: reaction.reactionHasStarted,
                maxWidth: geometry.size.width,
                maxHeight: geometry.size.height,
                rateConstantColor: reaction.color(for: .rateConstantEquation),
                halfLifeColor: reaction.color(for: .halfLifeEquation),
                rateColor: reaction.color(for: .rateEquation)
            )
        }
    }
}

struct SecondOrderReaction_Previews: PreviewProvider {
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

    static let reaction = SecondOrderReactionViewModel()

    struct StateWrapper: View {
        var body: some View {
            SecondOrderReactionScreen(
                reaction: reaction
            )
        }
    }
}
