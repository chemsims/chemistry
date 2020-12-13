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
            
            topStack(settings: settings)

            beaky(settings: settings)
                .padding(.trailing, settings.beakyRightPadding)
                .padding(.bottom, settings.beakyBottomPadding)
            rhsView()
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

    private func topStack(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                    .frame(width: settings.menuTotalWidth)
                FilledBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB: reaction.concentrationEquationB,
                    currentTime: reaction.currentTime
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, settings.beakerLeadingPadding)
                .colorMultiply(reaction.color(for: nil))

                middleCharts(settings: settings)
            }
            .padding(.top, settings.chartsTopPadding)
            Spacer()
        }
    }

    private func middleCharts(settings: OrderedReactionLayoutSettings) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ConcentrationTimeChartView(
                initialConcentration: $reaction.initialConcentration,
                initialTime: $reaction.initialTime,
                finalConcentration: $reaction.finalConcentration,
                finalTime: $reaction.finalTime,
                settings: settings.chartSettings,
                concentrationA: reaction.concentrationEquationA,
                concentrationB: reaction.concentrationEquationB,
                currentTime: $reaction.currentTime,
                canSetInitialTime: canSetInitialTime,
                canSetCurrentTime: reaction.reactionHasEnded
            )
            .frame(width: settings.chartSettings.largeTotalChartWidth)
            .padding(.horizontal, settings.chartHPadding)
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
            )
            .padding(.horizontal, settings.chartHPadding)

            concentrationTable
                .padding(.trailing, settings.tableTrailingPadding)
        }
    }

    private var concentrationTable: some View {
        ConcentrationTable(
            c1: reaction.initialConcentration.str(decimals: 2),
            c2: reaction.finalConcentration?.str(decimals: 2),
            t1: reaction.initialTime.str(decimals: 1),
            t2: reaction.finalTime?.str(decimals: 1),
            cellWidth: settings.tableCellWidth,
            cellHeight: settings.tableCellHeight,
            buttonSize: settings.tableButtonSize
        )
        .font(.system(size: settings.tableFontSize))
    }

    private func cell(value: String) -> some View {
        ZStack {
            Rectangle()
                .stroke()
            Text(value)
        }.frame(width: settings.tableCellWidth, height: settings.tableCellHeight)
    }

}
