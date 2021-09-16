//
// Reactions App
//


import SwiftUI
import ReactionsCore

struct LimitingReagentScreen: View {

    @ObservedObject var model: LimitingReagentScreenViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            LimitingReagentScreenWithLayout(
                model: model,
                layout: .init(
                    common: .init(
                        geometry: geo,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            )
        }
        .padding(ChemicalReactionsScreenLayout.topLevelScreenPadding)
    }
}

private struct LimitingReagentScreenWithLayout: View {

    @ObservedObject var model: LimitingReagentScreenViewModel
    let layout: LimitingReagentScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            LimitingReagentTopStack(layout: layout)
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                beaker
                Spacer(minLength: 0)
                LimitingReagentRightStack(
                    model: model,
                    layout: layout
                )
            }
        }
    }

    private var beaker: some View {
        LimitingReagentBeaker(
            shakeModel: model.shakeReactantModel,
            layout: layout
        )
    }
}

private struct LimitingReagentTopStack: View {

    let layout: LimitingReagentScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            reactionDefinition
            reactionToggle
        }
    }

    private var reactionDefinition: some View {
        Text("Reaction")
    }

    private var reactionToggle: some View {
        Rectangle()
            .stroke()
            .frame(square: layout.common.reactionSelectionToggleHeight)
    }
}

private struct LimitingReagentRightStack: View {

    @ObservedObject var model: LimitingReagentScreenViewModel
    let layout: LimitingReagentScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            equation
            HStack(spacing: 0) {
                chart
                Spacer(minLength: 0)
                beaky
            }
        }
    }

    private var equation: some View {
        Text("Equation")
    }

    private var chart: some View {
        Text("Chart")
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: model.nextIsDisabled,
            settings: layout.common.beakySettings
        )
    }
}

struct LimitingReagentScreenLayout {
    let common: ChemicalReactionsScreenLayout
}

struct LimitingReagentScreen_Previews: PreviewProvider {
    static var previews: some View {
        LimitingReagentScreen(model: .init())
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
