//
// Reactions App
//
  

import SwiftUI

struct OrderedReactionScreen<Content: View>: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel
    @ObservedObject var flow: ReactionNavigationViewModel
    let settings: OrderedReactionLayoutSettings
    let canSetInitialTime: Bool
    let rhsView: () -> Content


    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack(alignment: .leading) {
            beaker(settings: settings)
            beaky(settings: settings)
                .padding(.trailing, settings.beakyRightPadding)
                .padding(.bottom, settings.beakyBottomPadding)
            rhsView()
//            makeHView(using: settings)
        }
    }

    private func makeHView(using settings: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 0) {
            beaker(settings: settings)
            Spacer()
//            rhsView()
        }
    }

    private func beaky(settings: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                BeakyBox(
                    statement: flow.statement,
                    next: flow.next,
                    back: flow.back,
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
        VStack {
            HStack {
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    moleculesB: reaction.moleculesB,
                    moleculeBOpacity: reaction.moleculeBOpacity
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, settings.beakerLeadingPadding)
                .padding(.top, settings.beakerLeadingPadding)

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
                currentTime: reaction.currentTime,
                headOpacity: reaction.timeChartHeadOpacity,
                canSetInitialTime: canSetInitialTime
            )

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
