//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionView: View {

    @ObservedObject var reaction: FirstOrderReactionViewModel
    @ObservedObject var flow: FirstOrderReactionNavigationViewModel
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
            flow: flow,
            settings: settings,
            canSetInitialTime: false
        ) {
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    logChart(settings: settings)
                        .padding(.top, settings.chartsTopPadding)
                        .padding(.leading, settings.chartsTopPadding)

                    equationView(settings: settings)
                        .padding(.leading, equationLeadingPadding)
                        .padding(.top, equationLeadingPadding)
                }
            }

        }
    }

    private func logChart(settings: OrderedReactionLayoutSettings) -> some View {
        SingleConcentrationPlot(
            initialConcentration: reaction.initialConcentration,
            initialTime: reaction.initialTime,
            finalConcentration: reaction.finalConcentration,
            finalTime: reaction.finalTime,
            settings: TimeChartGeometrySettings(
                chartSize: settings.chartSize,
                minConcentration: ReactionSettings.minLogConcentration,
                maxConcentration: ReactionSettings.maxLogConcentration
            ),
            concentrationA: reaction.logAEquation,
            currentTime: reaction.currentTime,
            headOpacity: reaction.timeChartHeadOpacity,
            yLabel: "ln(A)"
        )
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        FirstOrderEquationView2(
            c1: reaction.initialConcentration,
            c2: reaction.finalConcentration,
            t: reaction.finalTime,
            rate: reaction.rate,
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

    var equationLeadingPadding: CGFloat {
        return 5
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

        @ObservedObject var foo = FirstOrderReactionNavigationViewModel(reactionViewModel: FirstOrderReactionViewModel())

        var body: some View {
            FirstOrderReactionView(
                reaction: foo.reactionViewModel as! FirstOrderReactionViewModel,
                flow: foo
            )
        }
    }
}
