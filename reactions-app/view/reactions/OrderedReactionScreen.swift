//
// Reactions App
//
  

import SwiftUI

struct OrderedReactionScreen<Content: View>: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel
    @ObservedObject var navigation: ReactionNavigationViewModel<ReactionState>
    let settings: OrderedReactionLayoutSettings
    let canSetInitialTime: Bool
    let rhsView: () -> Content

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(reaction.color(for: nil))
                .edgesIgnoringSafeArea(.all)
            
            beaker(settings: settings)

            beaky(settings: settings)
                .padding(.trailing, settings.beakyRightPadding)
                .padding(.bottom, settings.beakyBottomPadding)
            rhsView()
        }
    }

    private func makeHView(using settings: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 0) {
            beaker(settings: settings)
            Spacer()
        }
    }

    private func beaky(settings: OrderedReactionLayoutSettings) -> some View {
        BeakyOverlay(
            statement: navigation.statement,
            next: navigation.next,
            back: navigation.back,
            settings: settings
        )
    }

    private func beaker(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            HStack {
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB: reaction.concentrationEquationB,
                    currentTime: reaction.currentTime
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, settings.beakerLeadingPadding)
                .padding(.top, settings.beakerLeadingPadding)
                .colorMultiply(reaction.color(for: nil))

                middleCharts(settings: settings)
            }

            Spacer()

        }
    }

    private func middleCharts(settings: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 20) {
            ConcentrationTimeChartView(
                initialConcentration: $reaction.initialConcentration,
                initialTime: $reaction.initialTime,
                finalConcentration: $reaction.finalConcentration,
                finalTime: $reaction.finalTime,
                settings: TimeChartGeometrySettings(
                    chartSize: settings.chartSize
                ),
                concentrationA: reaction.concentrationEquationA,
                concentrationB: reaction.concentrationEquationB,
                currentTime: $reaction.currentTime,
                canSetInitialTime: canSetInitialTime,
                canSetCurrentTime: reaction.reactionHasEnded
            )
            .colorMultiply(reaction.color(for: .concentrationChart))

            ConcentrationBarChart(
                initialA: reaction.initialConcentration,
                initialTime: reaction.initialTime,
                concentrationA: reaction.concentrationEquationA,
                concentrationB: reaction.concentrationEquationB,
                currentTime: reaction.currentTime,
                settings: BarChartGeometrySettings(
                    chartWidth: settings.chartSize,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minConcentration: ReactionSettings.minConcentration
                )
            ).frame(width: settings.chartSize)
            Spacer()
        }
    }

}
