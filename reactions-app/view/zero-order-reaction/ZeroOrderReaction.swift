//
// Reactions App
//


import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var beakyModel: ZeroOrderBeakyViewModel
    @ObservedObject var reactionModel: ReactionViewModel
    init(beakyModel: ZeroOrderBeakyViewModel) {
        self.beakyModel = beakyModel
        self.reactionModel = beakyModel.reactionViewModel
    }

    var body: some View {
        GeometryReader { geometry in
            makeView(using: LayoutSettings(geometry: geometry))
        }
    }

    private func makeView(using settings: LayoutSettings) -> some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                FilledBeaker(
                    moleculesA: reactionModel.moleculesA,
                    moleculesB: reactionModel.moleculesB,
                    moleculeBOpacity: reactionModel.moleculeBOpacity
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, 60)
                .padding(.bottom, 60)
            }

            VStack(alignment: .trailing) {

                ConcentrationTimeChartView(
                    initialConcentration: $reactionModel.initialConcentration,
                    initialTime: $reactionModel.initialTime,
                    finalConcentration: $reactionModel.finalConcentration,
                    finalTime: $reactionModel.finalTime,
                    minConcentration: ReactionSettings.minConcentration,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minTime: ReactionSettings.minTime,
                    maxTime: ReactionSettings.maxTime,
                    minFinalConcentration: ReactionSettings.minFinalConcentration,
                    minFinalTime: ReactionSettings.minFinalTime,
                    chartSize: settings.chartsWidth,
                    concentrationA: reactionModel.concentrationEquationA,
                    concentrationB: reactionModel.concentrationEquationB,
                    currentTime: reactionModel.currentTime
                )

                ConcentrationBarChart(
                    initialA: reactionModel.initialConcentration,
                    initialTime: reactionModel.initialTime,
                    concentrationA: reactionModel.concentrationEquationA,
                    concentrationB: reactionModel.concentrationEquationB,
                    currentTime: reactionModel.currentTime,
                    settings: BarChartGeometrySettings(
                        chartWidth: settings.chartsWidth,
                        maxConcentration: ReactionSettings.maxConcentration,
                        minConcentration: ReactionSettings.minConcentration
                    )
                ).frame(width: settings.chartsWidth)
            }
            .padding(.leading, -20)
            .padding(.trailing, 30)

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    ZeroOrderEquationFilled(scale: settings.equationScale)
                    ZeroOrderEquationBlank(
                        scale: settings.equationScale,
                        initialConcentration: reactionModel.initialConcentration,
                        initialTime: reactionModel.initialTime,
                        rate: reactionModel.rate,
                        deltaC: reactionModel.deltaC,
                        deltaT: reactionModel.deltaT,
                        c2: reactionModel.finalConcentration,
                        t2: reactionModel.finalTime
                    )
                }
                VStack(alignment: .leading, spacing: 3) {
                    ZeroOrderReactionHalftimeView(scale: settings.equationScale)
                    ZeroOrderReactionHalftimeBlank(
                        scale: settings.equationScale,
                        initialConcentration: reactionModel.initialConcentration,
                        rate: reactionModel.rate,
                        halfTime: reactionModel.halfTime
                    )
                }

                HStack(alignment: .bottom, spacing: 3) {
                    SpeechBubble(lines: beakyModel.statement)
                        .frame(width: settings.bubbleWidth, height: settings.bubbleHeight)
                        .font(.system(size: settings.bubbleFontSize))
                    Beaky()
                        .frame(height: settings.beakyHeight)
                }

                HStack {
                    PreviousButton(action: beakyModel.back)
                        .frame(width: settings.navButtonWidth, height: settings.navButtonWidth)
                    Spacer()
                    NextButton(action: beakyModel.next)
                        .frame(width: settings.navButtonWidth, height: settings.navButtonWidth)
                }.frame(width: settings.bubbleWidth - settings.bubbleStemWidth)


            }
        }
    }
}

struct LayoutSettings {
    let geometry: GeometryProxy
    var width: CGFloat {
        geometry.size.width
    }
    var height: CGFloat {
        geometry.size.height
    }

    var beakerHeight: CGFloat {
        width * 0.28
    }
    var beakerWidth: CGFloat {
        beakerHeight * 0.9
    }

    var chartsWidth: CGFloat {
        beakerWidth * 0.8
    }

    var bubbleWidth: CGFloat {
        0.24 * width
    }
    var bubbleHeight: CGFloat {
        bubbleWidth * 1.1
    }
    var bubbleFontSize: CGFloat {
        0.016 * width
    }

    // TODO - refactor this out of here
    var bubbleStemWidth: CGFloat {
        bubbleWidth * 0.2
    }

    var beakyHeight: CGFloat {
        bubbleHeight * 0.55
    }
    var navButtonWidth: CGFloat {
        bubbleWidth * 0.15
    }

    var equationScale: CGFloat {
        let scaleAt1024: CGFloat = 1.0 // iPad mini landscape
        let scaleAt1366: CGFloat = 1.6 // iPad 12.9 inch landscape
        let m = (scaleAt1366 - scaleAt1024) / CGFloat(1366 - 1024)
        let c = 1 - (m * 1024)
        return (m * width) + c

    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {

    static var previews: some View {
        /// iPad mini 4 landscape
        ZeroOrderReaction(
            beakyModel: ZeroOrderBeakyViewModel(reactionViewModel: ReactionViewModel())
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro
        ZeroOrderReaction(
            beakyModel: ZeroOrderBeakyViewModel(reactionViewModel: ReactionViewModel())
        ).previewLayout(.fixed(width: 1366, height: 1024))

    }
}
