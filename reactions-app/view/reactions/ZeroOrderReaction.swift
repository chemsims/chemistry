//
// Reactions App
//


import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var beakyModel: ZeroOrderUserFlowViewModel
    @ObservedObject var reactionModel: ReactionViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    init(beakyModel: ZeroOrderUserFlowViewModel) {
        self.beakyModel = beakyModel
        self.reactionModel = beakyModel.reactionViewModel
    }

    var body: some View {
        GeometryReader { geometry in
            body2(
                settings:
                    OrderedReactionLayoutSettings(geometry: geometry,
                              horizontalSize: horizontalSizeClass,
                              verticalSize: verticalSizeClass
                    )
            )
        }
    }

    func body2(settings: OrderedReactionLayoutSettings) -> some View {
        OrderedReactionScreen(
            reaction: reactionModel,
            flow: beakyModel,
            settings: settings
        ) {
            Text("foo")
//            equationView(settings: settings)
        }
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 3) {
                ZeroOrderEquationFilled(scale: 1.5)
                ZeroOrderEquationBlank(
                    scale: 1.5,
                    emphasiseFilledTerms: reactionModel.currentTime == nil,
                    initialConcentration: reactionModel.initialConcentration,
                    initialTime: reactionModel.initialTime,
                    rate: reactionModel.rate,
                    deltaC: reactionModel.deltaC,
                    deltaT: reactionModel.deltaT,
                    c2: reactionModel.finalConcentration,
                    t2: reactionModel.finalTime
                )
            }
            VStack(alignment: .leading, spacing: 1.5) {
                ZeroOrderReactionHalftimeView(scale: 1.5)
                ZeroOrderReactionHalftimeBlank(
                    scale: 2,
                    initialConcentration: reactionModel.initialConcentration,
                    rate: reactionModel.rate,
                    halfTime: reactionModel.halfTime
                )
            }
            Spacer()
                .frame(height: settings.bubbleHeight + settings.navButtonSize)
        }
    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {

    static var previews: some View {

        // iPhone SE landscape
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ReactionViewModel())
        ).previewLayout(.fixed(width: 568, height: 320))


        /// iPad mini 4 landscape
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ReactionViewModel())
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ReactionViewModel())
        ).previewLayout(.fixed(width: 1366, height: 1024))

    }
}
