//
// Reactions App
//
  

import SwiftUI

struct SecondOrderReactionView: View {

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
                HStack(spacing: 0) {
                    invChart(settings: settings)
                    equationView(settings: settings)
                        .padding(.leading, 5)
                        .padding(.top, 5)
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
        .padding(.top, settings.chartsTopPadding)
        .padding(.leading, settings.chartsTopPadding / 2)

    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        SecondOrderEquationView2(
            c1: reaction.initialConcentration,
            c2: reaction.finalConcentration,
            rate: reaction.rate,
            t: reaction.finalTime,
            halfTime: reaction.halfTime,
            maxWidth: equationWidth(settings: settings),
            maxHeight: availableHeight(settings: settings)
        )
    }

    private func equationWidth(settings: OrderedReactionLayoutSettings) -> CGFloat {
        let freeWidth = availableWidth(settings: settings) / 2
        return freeWidth
    }

    private func barChartSize(settings: OrderedReactionLayoutSettings) -> CGFloat {
        let maxHeight = availableHeight(settings: settings) - (settings.chartsTopPadding)
        let maxWidth = availableWidth(settings: settings) / 3
        return min(maxHeight, maxWidth)
    }

    private func availableWidth(settings: OrderedReactionLayoutSettings) -> CGFloat {
        settings.width - settings.beakyBoxTotalWidth
    }

    private func availableHeight(settings: OrderedReactionLayoutSettings) -> CGFloat {
        settings.height - settings.beakerHeight - settings.beakerLeadingPadding
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
    static let navigation = SecondOrderReactionNavigation.model(reaction: reaction)

    struct StateWrapper: View {
        var body: some View {
            SecondOrderReactionView(
                reaction: reaction,
                navigation: navigation
            )
        }
    }
}
