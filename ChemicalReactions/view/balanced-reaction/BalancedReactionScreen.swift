//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BalancedReactionScreen: View {

    @ObservedObject var model: BalancedReactionScreenViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            SizedBalancedReactionScreen(
                model: model,
                moleculeModel: model.moleculePosition,
                layout: BalancedReactionScreenLayout(
                    common: ChemicalReactionsScreenLayout(
                        geometry: geo,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            )
        }
    }
}

private struct SizedBalancedReactionScreen: View {

    @ObservedObject var model: BalancedReactionScreenViewModel
    @ObservedObject var moleculeModel: BalancedReactionMoleculePositionViewModel
    let layout: BalancedReactionScreenLayout

    var body: some View {
        ZStack {
            emptyBeakers

            BalancedReactionTopStack(
                model: moleculeModel,
                layout: layout
            )

            beaky

            BalancedReactionScreen.BalancedReactionScreenMolecules(
                model: model,
                moleculeModel: moleculeModel,
                layout: layout
            )

            reactionSelection
        }
    }

    private var emptyBeakers: some View {
        Group {
            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.firstBeakerPosition)

            EmptyBeaker(settings: layout.beakerSettings)
                .frame(size: layout.beakerSize)
                .position(layout.secondBeakerPosition)
        }
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: !model.canGoNext,
            settings: layout.common.beakySettings
        )
        .spacing(horizontalAlignment: .trailing, verticalAlignment: .bottom)
    }

    private var reactionSelection: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: BalancedReaction.availableReactions,
            isToggled: .constant(model.inputState == .selectReaction),
            selection: $model.reaction,
            height: 20,
            animation: nil,
            displayString: { $0.display },
            label: { $0.display.label },
            disabledOptions: model.unavailableReactions,
            onSelection: model.didSelectReaction
        )
        .disabled(model.inputState != .selectReaction)
        .spacing(horizontalAlignment: .trailing, verticalAlignment: .top)
    }
}

private struct BalancedReactionTopStack: View {

    @ObservedObject var model: BalancedReactionMoleculePositionViewModel
    let layout: BalancedReactionScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                BalancedReactionDefinition(
                    model: model.reactionBalancer,
                    layout: layout
                )

                scales

                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
    }

    private var scales: some View {
        BalancedReactionScales(
            model: .init(balancer: model.reactionBalancer),
            layout: layout
        )
    }
}

struct BalancedReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BalancedReactionScreen(
                model: BalancedReactionScreenViewModel()
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
