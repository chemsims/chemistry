//
// Reactions App
//


import SwiftUI

struct ZeroOrderReaction: View {

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
            ZeroOrderEquationView(
                emphasiseFilledTerms: reaction.currentTime == nil,
                initialConcentration: reaction.initialConcentration,
                initialTime: reaction.initialTime,
                rate: reaction.rate,
                deltaC: reaction.deltaC,
                deltaT: reaction.deltaT,
                c2: reaction.finalConcentration,
                t2: reaction.finalTime,
                halfTime: reaction.halfTime,
                a0: reaction.a0,
                maxWidth: availableWidth,
                maxHeight: height,
                isShowingTooltip: $isShowingTooltip
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

    static var navigation: ReactionNavigationViewModel<ReactionState> {
        ZeroOrderReactionNavigation.model(
            reaction: ZeroOrderReactionViewModel(),
            persistence: InMemoryReactionInputPersistence()
        )
    }

    static var previews: some View {

        // iPhone SE landscape
        ZeroOrderReaction(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 568, height: 320))

        // iPhone 11 landscape
        ZeroOrderReaction(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 812, height: 375))


        /// iPad mini 4 landscape
        ZeroOrderReaction(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro
        ZeroOrderReaction(
            reaction: navigation.model, navigation: navigation
        ).previewLayout(.fixed(width: 1366, height: 1024))

    }
}
