//
// Reactions App
//
  

import SwiftUI

struct SecondOrderReactionScreen: View {

    @ObservedObject var reaction: SecondOrderReactionViewModel
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
        OrderedReactionScreen(
            reaction: reaction,
            navigation: navigation,
            settings: settings,
            canSetInitialTime: false
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
            initialConcentration: reaction.initialConcentration,
            initialTime: reaction.initialTime,
            finalConcentration: reaction.finalConcentration,
            finalTime: reaction.finalTime,
            settings: TimeChartGeometrySettings(
                chartSize: settings.chartSize,
                minConcentration: ReactionSettings.minInverseConcentration,
                maxConcentration: ReactionSettings.maxInverseConcentration
            ),
            concentrationA: reaction.inverseAEquation,
            currentTime: $reaction.currentTime,
            yLabel: "1/[A]",
            canSetCurrentTime: reaction.reactionHasEnded
        )
        .colorMultiply(reaction.color(for: .secondaryChart))
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        GeometryReader { geometry in
            SecondOrderEquationView(
                emphasiseFilledTerms: reaction.currentTime == nil,
                c1: reaction.initialConcentration,
                c2: reaction.finalConcentration,
                t: reaction.finalTime,
                currentTime: reaction.currentTime,
                concentration: reaction.concentrationEquationA,
                reactionHasStarted: reaction.reactionHasStarted,
                maxWidth: geometry.size.width,
                maxHeight: geometry.size.height,
                rateConstantColor: reaction.color(for: .rateConstantEquation),
                halfLifeColor: reaction.color(for: .halfLifeEquation)
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
    static let navigation = SecondOrderReactionNavigation.model(
        reaction: reaction,
        persistence: InMemoryReactionInputPersistence()
    )

    struct StateWrapper: View {
        var body: some View {
            SecondOrderReactionScreen(
                reaction: reaction,
                navigation: navigation
            )
        }
    }
}
