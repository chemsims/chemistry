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
            beaky(settings: settings)
                .padding(.trailing, settings.beakyRightPadding)
                .padding(.bottom, settings.beakyBottomPadding)
            makeHView(using: settings)
        }
    }

    private func makeHView(using settings: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 0) {
            beaker(settings: settings)
            Spacer()
            middleCharts(settings: settings)
                .padding(.top, settings.chartsTopPadding)
            rhsView()
        }
    }

    private func beaky(settings: OrderedReactionLayoutSettings) -> some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: settings.beakyVSpacing) {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    SpeechBubble(lines: flow.statement)
                        .frame(width: settings.bubbleWidth, height: settings.bubbleHeight)
                        .font(.system(size: settings.bubbleFontSize))
                    Beaky()
                        .frame(height: settings.beakyHeight)
                }

                HStack {
                    PreviousButton(action: flow.back)
                        .frame(width: settings.navButtonSize, height: settings.navButtonSize)
                    Spacer()
                    NextButton(action: flow.next)
                        .frame(width: settings.navButtonSize, height: settings.navButtonSize)
                }.frame(width: settings.bubbleWidth - settings.bubbleStemWidth)
            }
        }
    }

    private func beaker(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            Spacer()
            FilledBeaker(
                moleculesA: reaction.moleculesA,
                moleculesB: reaction.moleculesB,
                moleculeBOpacity: reaction.moleculeBOpacity
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .padding(.leading, settings.beakerLeadingPadding)
            .padding(.bottom, settings.beakerLeadingPadding)
        }
    }

    private func middleCharts(settings: OrderedReactionLayoutSettings) -> some View {
        VStack(alignment: .trailing, spacing: 0) {

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
        .frame(width: settings.chartSize + settings.midChartsLeftPadding, alignment: .trailing)
    }
}
