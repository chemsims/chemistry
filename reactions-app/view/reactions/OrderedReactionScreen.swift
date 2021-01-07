//
// Reactions App
//
  

import SwiftUI

struct OrderedReactionScreen<Content: View>: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel
    @ObservedObject var navigation: NavigationViewModel<ReactionState>
    let settings: OrderedReactionLayoutSettings
    let canSetInitialTime: Bool
    let showRate: Bool
    let rhsView: () -> Content

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State private var reactionSelectionIsToggled: Bool = false

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
            statement: reaction.statement,
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
                    concentrationB: reaction.input.concentrationB,
                    currentTime: reaction.currentTime
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
                canSetT2: reaction.selectedReaction != .C
            )
            .frame(width: settings.chartSettings.largeTotalChartWidth)
            .padding(.horizontal, settings.chartHPadding)
            .colorMultiply(reaction.color(for: [.concentrationChart, .rateCurveLhs, .rateCurveRhs]))
            .disabled(reaction.inputsAreDisabled)

            ConcentrationBarChart(
                initialA: reaction.input.inputC1,
                initialTime: reaction.input.inputT1,
                concentrationA: reaction.input.concentrationA,
                concentrationB: reaction.input.concentrationB,
                currentTime: reaction.currentTime,
                settings: BarChartGeometrySettings(
                    chartWidth: settings.chartSize,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minConcentration: ReactionSettings.minConcentration
                )
            )
            .padding(.horizontal, settings.chartHPadding)

            topRightControls
                .padding(.trailing, settings.tableTrailingPadding)
        }
    }

    private var topRightControls: some View {
        VStack(alignment: .trailing, spacing: 0.5 * settings.tableButtonSize) {
            reactionToggle.zIndex(1)
            concentrationTable
        }
    }

    private var reactionToggle: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: OrderedReactionSet.allCases,
            isToggled:  $reactionSelectionIsToggled,
            selection: $reaction.selectedReaction,
            height: settings.tableButtonSize,
            displayString: { $0.name}
        )
        .frame(height: settings.tableButtonSize, alignment: .top)
        .disabled(!reaction.canSelectReaction)
    }

    private var concentrationTable: some View {
        ConcentrationTable(
            c1: reaction.input.inputC1.str(decimals: 2),
            c2: reaction.input.inputC2?.str(decimals: 2),
            t1: reaction.input.inputT1.str(decimals: 1),
            t2: reaction.input.inputT2?.str(decimals: 1),
            rate: reaction.input.concentrationA?.rateEquation,
            currentTime: reaction.currentTime,
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
                navigation: NavigationViewModel(
                    model: ZeroOrderReactionViewModel(),
                    states: [ReactionState()]
                ),
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
