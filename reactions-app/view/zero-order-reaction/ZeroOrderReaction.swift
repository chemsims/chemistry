//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var moleculeConcentration: ReactionViewModel

    var body: some View {
        GeometryReader { geometry in
            makeView(using: LayoutSettings(geometry: geometry))
        }
    }

    private func makeView(using settings: LayoutSettings) -> some View {
        HStack {
            VStack {
                Spacer()
                FilledBeaker(
                    molecules: [(Styling.moleculeA, moleculeConcentration.molecules)]
                )
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)
                .padding(.leading, 60)
                .padding(.bottom, 60)
            }

            VStack {
                Spacer()

                TimeChartAxisView(
                    concentration: $moleculeConcentration.concentration,
                    time: $moleculeConcentration.initialTime,
                    minConcentration: ReactionSettings.minConcentration,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minTime: ReactionSettings.minTime,
                    maxTime: ReactionSettings.maxTime
                )


                ConcentrationBarChart(
                    concentrationA: ValueRange(
                        value: moleculeConcentration.concentration,
                        minValue: ReactionSettings.minConcentration,
                        maxValue: ReactionSettings.maxConcentration
                    ),
                    chartWidth: settings.chartsWidth
                )
            }

        }
    }

    var body2: some View {
        VStack {
            HStack {
                TimeChartAxisView(
                    concentration: $moleculeConcentration.concentration,
                    time: $moleculeConcentration.initialTime,
                    minConcentration: ReactionSettings.minConcentration,
                    maxConcentration: ReactionSettings.maxConcentration,
                    minTime: ReactionSettings.minTime,
                    maxTime: ReactionSettings.maxTime
                )

                ConcentrationBarChart(
                    concentrationA: ValueRange(
                        value: moleculeConcentration.concentration,
                        minValue: ReactionSettings.minConcentration,
                        maxValue: ReactionSettings.maxConcentration
                    ),
                    chartWidth: 300
                )
            }

            VStack(alignment: .leading) {
                ZeroOrderEquationFilled()
                ZeroOrderEquationTerm2Blank(
                    initialConcentration: moleculeConcentration.concentration,
                    intialTime: moleculeConcentration.initialTime
                )
            }



            FilledBeaker(molecules: [(Styling.moleculeA, moleculeConcentration.molecules)])
                .frame(width: 350, height: 420)
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
        width * 0.3
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
}

struct ZeroOrderReaction_Previews: PreviewProvider {
    static var previews: some View {
        ZeroOrderReaction(
            moleculeConcentration: ReactionViewModel()
        ).previewLayout(.fixed(width: 1024, height: 768))
    }
}
