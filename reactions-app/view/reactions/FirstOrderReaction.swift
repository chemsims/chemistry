//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReaction: View {

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
            HStack(spacing: 0) {
                logChart(settings: settings)
                    .padding(.top, settings.chartsTopPadding)

                equationView(settings: settings)
                    .padding(.leading, equationLeadingPadding)
                    .padding(.top, equationLeadingPadding)
            }
        }
    }

    private func logChart(settings: OrderedReactionLayoutSettings) -> some View {
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

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        VStack(spacing: 10) {
            FirstOrderReactionEquation(
                c1: reaction.initialConcentration,
                c2: reaction.finalConcentration,
                t: reaction.finalTime,
                rate: reaction.rate,
                halfTime: reaction.halfTime,
                maxWidth: equationWidth(settings: settings),
                maxHeight: settings.height - settings.beakyBoxTotalHeight
            )//.frame(width: equationWidth(settings: settings)).border(Color.red)
            Spacer()
        }
    }

    private func equationWidth(settings: OrderedReactionLayoutSettings) -> CGFloat {
        if let h = settings.horizontalSize, h == .regular {
            return 0.2 * settings.width
        }
        return 0.26 * settings.width
    }

    var equationLeadingPadding: CGFloat {
        return 5
    }

}

struct OrderedReactionLayoutSettings {
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
    var beakyBoxTotalHeight: CGFloat {
        bubbleHeight + navButtonSize + beakyVSpacing
    }
    var beakyBoxTotalWidth: CGFloat {
        bubbleWidth + (beakyHeight * 0.54) + beakyRightPadding
    }
    var beakyVSpacing: CGFloat {
        return 2
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

        @ObservedObject var foo = FirstOrderReactionNavigationViewModel(reactionViewModel: FirstOrderReactionViewModel())

        var body: some View {
            FirstOrderReaction(
                reaction: foo.reactionViewModel as! FirstOrderReactionViewModel,
                flow: foo
            )
        }
    }
}
