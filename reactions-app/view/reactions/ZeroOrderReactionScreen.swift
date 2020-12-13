//
// Reactions App
//


import SwiftUI

struct ZeroOrderReactionScreen: View {

    @ObservedObject var reaction: ZeroOrderReactionViewModel
    @ObservedObject var navigation: ReactionNavigationViewModel<ReactionState>

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
                if (isShowingTooltip) {
                    isShowingTooltip = false
                }
            }
        }
    }

    func makeView(settings: OrderedReactionLayoutSettings) -> some View {
        OrderedReactionScreen(
            reaction: reaction,
            navigation: navigation,
            settings: settings,
            canSetInitialTime: true
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
                        initialConcentration: reaction.initialConcentration,
                        initialTime: reaction.initialTime,
                        deltaC: reaction.deltaC,
                        deltaT: reaction.deltaT,
                        c2: reaction.finalConcentration,
                        t2: reaction.finalTime,
                        rateColorMultipy: reaction.color(for: .rateEquation),
                        halfLifeColorMultiply: reaction.color(for: .halfLifeEquation),
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height,
                        isShowingTooltip: $isShowingTooltip,
                        currentTime: reaction.currentTime,
                        concentration: reaction.concentrationEquationA
                    )
                }
                .padding(.vertical, equationPadding(settings: settings))
                .padding(.horizontal, equationPadding(settings: settings))
                Spacer()
                    .frame(width: settings.beakyBoxTotalWidth)
            }
        }
    }

    private func equationPadding(settings: OrderedReactionLayoutSettings) -> CGFloat {
        0.1 * settings.chartSize
    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {

    static var navigation: ReactionNavigationViewModel<ReactionState> {
        ZeroOrderReactionNavigation.model(
            reaction: ZeroOrderReactionViewModel(),
            persistence: InMemoryReactionInputPersistence()
        )
    }

    static var previews: some View {

        // iPhone SE landscape
        ZeroOrderReactionScreen(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        ZeroOrderReactionScreen(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 812, height: 375))


        /// iPad mini 4 landscape
        ZeroOrderReactionScreen(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro
        ZeroOrderReactionScreen(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 1366, height: 1024))

    }
}
