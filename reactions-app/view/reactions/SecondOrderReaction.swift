//
// Reactions App
//
  

import SwiftUI

struct SecondOrderReactionView: View {

    @ObservedObject var reaction: SecondOrderReactionViewModel
    @ObservedObject var navigation: SecondOrderReactionNavigationViewModel
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
            flow: navigation,
            settings: settings,
            canSetInitialTime: false
        ) {
            HStack(spacing: 0) {
                invChart(settings: settings)
            }
        }
    }

    private func invChart(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
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
                currentTime: reaction.currentTime,
                headOpacity: reaction.timeChartHeadOpacity,
                yLabel: "1/[A]"
            )
            .padding(.top, settings.chartsTopPadding)
            Spacer()
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
    static let navigation = SecondOrderReactionNavigationViewModel(reactionViewModel: reaction)

    struct StateWrapper: View {
        var body: some View {
            SecondOrderReactionView(
                reaction: reaction,
                navigation: navigation
            )
        }
    }
}
