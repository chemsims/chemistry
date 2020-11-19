//
// Reactions App
//


import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var beakyModel: ZeroOrderUserFlowViewModel
    @ObservedObject var reactionModel: ZeroOrderReactionViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    init(beakyModel: ZeroOrderUserFlowViewModel) {
        self.beakyModel = beakyModel
        self.reactionModel = beakyModel.reactionViewModel
    }

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    func makeView(settings: OrderedReactionLayoutSettings) -> some View {
        OrderedReactionScreen(
            reaction: reactionModel,
            flow: beakyModel,
            settings: settings,
            canSetInitialTime: true) {
            equationView(settings: settings)
        }
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        let availableWidth = settings.width - settings.beakyBoxTotalWidth - (2 * equationHorizontalPadding)
        let availableHeight = settings.height - settings.beakerHeight - settings.beakerLeadingPadding - (2 * equationVerticalPadding)

        let height = min(availableHeight, settings.height / 2.5)

        return VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: settings.beakerHeight + settings.beakerLeadingPadding)
            ZeroOrderEquationView2(
                emphasiseFilledTerms: reactionModel.currentTime == nil,
                initialConcentration: reactionModel.initialConcentration,
                initialTime: reactionModel.initialTime,
                rate: reactionModel.initialTime,
                deltaC: reactionModel.deltaC,
                deltaT: reactionModel.deltaT,
                c2: reactionModel.deltaC,
                t2: reactionModel.finalTime,
                halfTime: reactionModel.halfTime,
                maxWidth: availableWidth,
                maxHeight: height
            )
            .padding(.vertical, equationVerticalPadding)
            .padding(.horizontal, equationHorizontalPadding)
            Spacer()
        }
    }

    private var equationVerticalPadding: CGFloat {
        10
    }
    private var equationHorizontalPadding: CGFloat {
        5
    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {

    static var previews: some View {

        // iPhone SE landscape
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ZeroOrderReactionViewModel())
        ).previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ZeroOrderReactionViewModel())
        ).previewLayout(.fixed(width: 812, height: 375))


        /// iPad mini 4 landscape
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ZeroOrderReactionViewModel())
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(reactionViewModel: ZeroOrderReactionViewModel())
        ).previewLayout(.fixed(width: 1366, height: 1024))

    }
}
