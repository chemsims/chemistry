//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReaction: View {

    @ObservedObject var reaction: FirstOderViewModel
    @ObservedObject var flow: FirstOrderUserFlowViewModel

    var body: some View {
        GeometryReader { geometry in
            newView(settings: LayoutSettings(geometry: geometry))
        }
    }

    private func beaky(settings: LayoutSettings) -> some View {
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
                        .frame(width: settings.navButtonWidth, height: settings.navButtonWidth)
                    Spacer()
                    NextButton(action: flow.next)
                        .frame(width: settings.navButtonWidth, height: settings.navButtonWidth)
                }.frame(width: settings.bubbleWidth - settings.bubbleStemWidth)
            }
        }
    }

    private func newView(settings: LayoutSettings) -> some View {
        ZStack {
            beaky(settings: settings)
            makeView(using: settings)
        }
    }

    private func beaker(settings: LayoutSettings) -> some View {
        VStack {
            Spacer()
            FilledBeaker(
                moleculesA: reaction.moleculesA,
                moleculesB: reaction.moleculesB,
                moleculeBOpacity: reaction.moleculeBOpacity
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
    }

    private func middleCharts(settings: LayoutSettings) -> some View {
        VStack(alignment: .trailing) {

            ConcentrationTimeChartView(
                initialConcentration: $reaction.initialConcentration,
                initialTime: $reaction.initialTime,
                finalConcentration: $reaction.finalConcentration,
                finalTime: $reaction.finalTime,
                settings: TimeChartGeometrySettings(
                    chartSize: settings.chartsWidth
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
                    chartWidth: settings.chartsWidth,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minConcentration: ReactionSettings.minConcentration
                )
            ).frame(width: settings.chartsWidth)
            Spacer()
        }
        .padding(.leading, -70)
        .padding(.top)
    }

    private func logChart(settings: LayoutSettings) -> some View {
        VStack {
            SingleConcentrationPlot(
                initialConcentration: reaction.initialConcentration,
                initialTime: reaction.initialTime,
                finalConcentration: reaction.finalConcentration,
                finalTime: reaction.finalTime,
                settings: TimeChartGeometrySettings(
                    chartSize: settings.chartsWidth,
                    minConcentration: ReactionSettings.minLogConcentration,
                    maxConcentration: ReactionSettings.maxLogConcentration
                ),
                concentrationA: reaction.logAEquation,
                currentTime: reaction.currentTime,
                headOpacity: reaction.timeChartHeadOpacity,
                yLabel: "ln(A)"
            )
            Spacer()
        }.padding(.top)
    }

    private func makeView(using settings: LayoutSettings) -> some View {
        HStack(spacing: 0) {
            beaker(settings: settings)
            middleCharts(settings: settings)
            logChart(settings: settings)
            equationView(settings: settings)
        }.frame(width: settings.width, height: settings.height)
    }

    private func equationView(settings: LayoutSettings) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            FirstOrderReactionEquation(
                c1: reaction.initialConcentration,
                c2: reaction.finalConcentration,
                t: reaction.finalTime,
                rate: reaction.rate
            ).frame(height: settings.height - settings.bubbleHeight - settings.navButtonWidth)
            Spacer()
        }
    }
}

struct FirstOrderReaction_Previews: PreviewProvider {
    
    static var previews: some View {
        StateWrapper()
            .previewLayout(.fixed(width: 896, height: 312))
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
