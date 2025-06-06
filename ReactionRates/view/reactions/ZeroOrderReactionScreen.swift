//
// Reactions App
//

import SwiftUI

struct ZeroOrderReactionScreen: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State private var isShowingTooltip = false

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            ).onTapGesture {
                if isShowingTooltip {
                    isShowingTooltip = false
                }
            }
        }
    }

    func makeView(settings: OrderedReactionLayoutSettings) -> some View {
        OrderedReactionScreen(
            reaction: reaction,
            settings: settings,
            canSetInitialTime: true,
            showRate: false
        ) {
            equationView(settings: settings)
        }
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        return VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: settings.topStackSize)
            HStack {
                GeometryReader { geometry in
                    ZeroOrderEquationView(
                        emphasiseFilledTerms: reaction.currentTime == nil,
                        reactionHasStarted: reaction.reactionHasStarted,
                        initialConcentration: reaction.input.inputC1,
                        initialTime: reaction.input.inputT1,
                        deltaC: reaction.deltaC,
                        deltaT: reaction.deltaT,
                        c2: reaction.input.inputC2,
                        t2: reaction.input.inputT2,
                        rateColorMultiply: reaction.color(for: .rateConstantEquation),
                        halfLifeColorMultiply: reaction.color(for: .halfLifeEquation),
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height,
                        isShowingTooltip: $isShowingTooltip,
                        currentTime: reaction.currentTime,
                        concentration: reaction.input.concentrationA,
                        reactant: reaction.selectedReaction.display.reactant.name
                    )
                }
                .padding(settings.equationPadding)
                Spacer()
                    .frame(width: settings.beakyBoxTotalWidth)
            }
        }
    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {

    static var model = ZeroOrderReactionViewModel()

    static var previews: some View {

        // iPhone SE landscape
        ZeroOrderReactionScreen(
            reaction: model
        ).previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        ZeroOrderReactionScreen(
            reaction: model
        ).previewLayout(.fixed(width: 812, height: 375))

        /// iPad mini 4 landscape
        ZeroOrderReactionScreen(
            reaction: model
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro
        ZeroOrderReactionScreen(
            reaction: model
        ).previewLayout(.fixed(width: 1366, height: 1024))

    }
}
