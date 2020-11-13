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
                    molecules: [(Styling.moleculeA, reactionModel.molecules)]
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, 60)
                .padding(.bottom, 60)
            }

            VStack(alignment: .trailing) {

                TimeChartAxisView(
                    initialConcentration: $reactionModel.initialConcentration,
                    initialTime: $reactionModel.initialTime,
                    finalConcentration: $reactionModel.finalConcentration,
                    finalTime: $reactionModel.finalTime,
                    minConcentration: ReactionSettings.minConcentration,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minTime: ReactionSettings.minTime,
                    maxTime: ReactionSettings.maxTime,
                    chartSize: settings.chartsWidth,
                    concentrationA: reactionModel.concentrationEquationA,
                    finalPlotTime: reactionModel.finalTime
                )

                ConcentrationBarChart(
                    concentrationA: ValueRange(
                        value: reactionModel.initialConcentration,
                        minValue: ReactionSettings.minConcentration,
                        maxValue: ReactionSettings.maxConcentration
                    ),
                    chartWidth: settings.chartsWidth
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

                SpeechBubble(lines: beakyModel.statement)
                    .frame(width: 220, height: 300)


                Button(action: beakyModel.next) {
                    Text("next")
                }

                Button(action: beakyModel.back) {
                    Text("back")
                }

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

    var beakerCenterX: CGFloat {
        let leftGap = width * 0.1
        return leftGap + (beakerWidth / 2)
    }

    var beakerCenterY: CGFloat {
        let bottomGap = height * 0.1
        return height - bottomGap - (beakerHeight / 2)
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

        ZeroOrderReaction(
            beakyModel: ZeroOrderBeakyViewModel(reactionViewModel: ReactionViewModel())
        ).previewLayout(.fixed(width: 1024, height: 768))

    }
}
