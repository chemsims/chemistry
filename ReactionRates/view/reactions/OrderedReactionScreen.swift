//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct OrderedReactionScreen<Content: View>: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel
    let settings: OrderedReactionLayoutSettings
    let canSetInitialTime: Bool
    let showRate: Bool
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
                .zIndex(1)

            beaky(settings: settings)
                .padding(.trailing, settings.beakyRightPadding)
                .padding(.bottom, settings.beakyBottomPadding)
            rhsView()
        }
    }

    private func beaky(settings: OrderedReactionLayoutSettings) -> some View {
        BeakyOverlay(
            statement: reaction.statement,
            next: reaction.next,
            back: reaction.back,
            nextIsDisabled: reaction.canSelectReaction,
            settings: settings.beakyGeometrySettings
        )
    }

    private func topStack(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                    .frame(width: settings.menuTotalWidth)
                ReactionsRateBeaker(
                    moleculesA: reaction.moleculesA,
                    concentrationB: reaction.input.concentrationB,
                    currentTime: reaction.currentTime,
                    reactionPair: reaction.selectedReaction.display,
                    finalTime: reaction.input.inputT2
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .colorMultiply(reaction.color(for: nil))

                middleCharts(settings: settings)
            }
            .padding(.top, settings.topPadding)
            Spacer()
        }
    }

    private func middleCharts(settings: OrderedReactionLayoutSettings) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ConcentrationTimeChartView(
                initialConcentration: $reaction.input.inputC1,
                initialTime: $reaction.input.inputT1,
                finalConcentration: $reaction.input.inputC2,
                finalTime: $reaction.input.inputT2,
                settings: settings.chartSettings,
                concentrationA: reaction.input.concentrationA,
                concentrationB: reaction.input.concentrationB,
                currentTime: $reaction.currentTime,
                canSetInitialTime: canSetInitialTime,
                canSetCurrentTime: reaction.reactionHasEnded,
                highlightChart: reaction.highlight(element: .concentrationChart),
                highlightLhsCurve: reaction.highlight(element: .rateCurveLhs),
                highlightRhsCurve: reaction.highlight(element: .rateCurveRhs),
                canSetC2: reaction.selectedReaction != .B,
                canSetT2: reaction.selectedReaction != .C,
                showDataAtT2: reaction.showDataAtT2,
                input: reaction.input,
                display: reaction.selectedReaction.display
            )
            .frame(width: settings.chartSettings.largeTotalChartWidth)
            .padding(.horizontal, settings.chartHPadding)
            .colorMultiply(reaction.color(for: [.concentrationChart, .rateCurveLhs, .rateCurveRhs]))
            .disabled(reaction.inputsAreDisabled)
            .accessibility(sortPriority: 3)

            ConcentrationBarChart(
                initialA: reaction.input.inputC1,
                initialTime: reaction.input.inputT1,
                concentrationA: reaction.input.concentrationA,
                concentrationB: reaction.input.concentrationB,
                currentTime: reaction.currentTime,
                display: reaction.selectedReaction.display,
                settings: BarChartGeometry(
                    chartWidth: settings.chartSize,
                    minYValue: ReactionSettings.Axis.minC,
                    maxYValue: ReactionSettings.Axis.maxC
                )
            )
            .padding(.horizontal, settings.chartHPadding)
            .colorMultiply(reaction.color(for: []))
            .accessibilityElement(children: .contain)
            .accessibility(sortPriority: 2)

            topRightControls
                .padding(.trailing, settings.tableTrailingPadding)
                .accessibility(sortPriority: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private var topRightControls: some View {
        VStack(alignment: .trailing, spacing: 0.5 * settings.tableButtonSize) {
            BranchMenu(layout: settings.branchMenu)
                .zIndex(2)
                .offset(x: 1)
            reactionToggle
                .zIndex(1)
            concentrationTable
        }
    }

    private var reactionToggle: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: ReactionType.allCases,
            isToggled: $reaction.showReactionSelection,
            selection: $reaction.pendingReactionSelection,
            height: settings.tableButtonSize,
            animation: nil,
            displayString: { TextLine($0.name) },
            label: { $0.label },
            disabledOptions: Array(reaction.usedReactions),
            onSelection: reaction.forcedNext
        )
        .frame(height: settings.tableButtonSize, alignment: .top)
        .colorMultiply(reaction.color(for: .reactionToggle))
        .disabled(!reaction.canSelectReaction)
    }

    private var concentrationTable: some View {
        ConcentrationTable(
            c1: reaction.input.inputC1.str(decimals: 2),
            c2: reaction.input.inputC2?.str(decimals: 2),
            t1: reaction.input.inputT1.str(decimals: 1),
            t2: reaction.input.inputT2?.str(decimals: 1),
            rate1: reaction.input.rateAtT1?.str(decimals: 3),
            rate2: reaction.input.rateAtT2?.str(decimals: 3),
            showTime: !showRate,
            showRate: showRate,
            cellWidth: settings.tableCellWidth,
            cellHeight: settings.tableCellHeight,
            buttonSize: settings.tableButtonSize,
            highlighted: reaction.highlight(element: .concentrationTable)
        )
        .font(.system(size: settings.tableFontSize))
        .disabled(reaction.inputsAreDisabled)
    }

    private func cell(value: String) -> some View {
        ZStack {
            Rectangle()
                .stroke()
            Text(value)
        }.frame(width: settings.tableCellWidth, height: settings.tableCellHeight)
    }
}

struct OrderedReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            OrderedReactionScreen(
                reaction: ZeroOrderReactionViewModel(),
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: nil,
                    verticalSize: nil
                ),
                canSetInitialTime: false,
                showRate: false
            ) {
                VStack {
                    Spacer()
                    Text("Hello, world")
                }
            }
        }
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
