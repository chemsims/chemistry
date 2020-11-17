//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReaction: View {

    @ObservedObject var reaction: FirstOderViewModel
    @ObservedObject var flow: FirstOrderUserFlowViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeZView(
                settings: NewLayout(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    private func makeZView(settings: NewLayout) -> some View {
        ZStack(alignment: .leading) {
            beaky(settings: settings)
                .padding(.trailing, settings.beakyRightPadding)
                .padding(.bottom, settings.beakyBottomPadding)
            makeHView(using: settings)
        }
    }

    private func makeHView(using settings: NewLayout) -> some View {
        HStack(spacing: 0) {
            beaker(settings: settings)
            Spacer()
            Group {
                middleCharts(settings: settings)
                logChart(settings: settings)
            }.padding(.top, settings.chartsTopPadding)

            equationView(settings: settings)
                .frame(maxWidth: settings.equationWidth)
                .padding(.leading, settings.equationLeadingPadding)
                .padding(.top, settings.equationLeadingPadding)
        }
    }

    private func beaky(settings: NewLayout) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .bottom, spacing: 3) {
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

    private func beaker(settings: NewLayout) -> some View {
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

    private func middleCharts(settings: NewLayout) -> some View {
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
                canSetInitialTime: false
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

    private func logChart(settings: NewLayout) -> some View {
        VStack {
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
            Spacer()
        }
    }

    private func equationView(settings: NewLayout) -> some View {
        VStack(spacing: 10) {
            FirstOrderReactionEquation(
                c1: reaction.initialConcentration,
                c2: reaction.finalConcentration,
                t: reaction.finalTime,
                rate: reaction.rate
            )
            Spacer()
                .frame(height: settings.bubbleHeight + settings.navButtonSize)
        }
    }
}

struct NewLayout {
    let geometry: GeometryProxy
    let horizontalSize: UserInterfaceSizeClass?
    let verticalSize: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }
    var height: CGFloat {
        geometry.size.height
    }

    var bubbleWidth: CGFloat {
        if (vIsRegular && hIsRegular) {
            return 0.25 * width
        }
        return 0.22 * width
    }
    var bubbleHeight: CGFloat {
        if (vIsRegular && hIsRegular) {
            return 1.1 * bubbleWidth
        }
        return 0.8 * bubbleWidth
    }
    var chartSize: CGFloat {
        let maxHeight = 0.32 * height
        let maxWidth = 0.25 * width
        let idealWidth = 0.2 * width
        return min(maxHeight, min(maxWidth, idealWidth))
    }
    var bubbleFontSize: CGFloat {
        bubbleWidth * 0.08
    }
    var beakyHeight: CGFloat {
        0.7 * bubbleHeight
    }
    var navButtonSize: CGFloat {
        bubbleHeight * 0.2
    }
    var bubbleStemWidth: CGFloat {
        SpeechBubbleSettings.getStemWidth(width: bubbleWidth)
    }
    var beakerWidth: CGFloat {
        if let h = horizontalSize, h == .regular {
            return 0.25 * width
        }
        return 0.23 * width
    }
    var beakerHeight: CGFloat {
        beakerWidth * 1.1
    }
    var midChartsLeftPadding: CGFloat {
        chartSize * 0.2
    }
    var chartsTopPadding: CGFloat {
        chartSize * 0.2
    }
    var beakyRightPadding: CGFloat {
        bubbleWidth * 0.3
    }
    var beakyBottomPadding: CGFloat {
        beakyRightPadding * 0.1
    }
    var beakerLeadingPadding: CGFloat {
        20
    }
    var equationWidth: CGFloat {
        if let h = horizontalSize, h == .regular {
            return 0.2 * width
        }
        return 0.23 * width
    }
    var equationLeadingPadding: CGFloat {
        return 5
    }

    private var hIsRegular: Bool {
        if let h = horizontalSize {
            return h == .regular
        }
        return false
    }

    private var vIsRegular: Bool {
        if let v = verticalSize {
            return v == .regular
        }
        return false
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

        @ObservedObject var foo = FirstOrderUserFlowViewModel(reactionViewModel: FirstOderViewModel())

        var body: some View {
            FirstOrderReaction(
                reaction: foo.reactionViewModel as! FirstOderViewModel,
                flow: foo
            )
        }
    }
}
