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
            LimitingReagentTopStack(model: model, layout: layout)
                .zIndex(1)
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                beaker
                Spacer(minLength: 0)
                LimitingReagentRightStack(
                    model: model,
                    components: model.components,
                    layout: layout
                )
            }
        }
    }

    private var beaker: some View {
        LimitingReagentBeaker(
            model: model,
            layout: layout
        )
    }
}

private struct LimitingReagentTopStack: View {

    @ObservedObject var model: LimitingReagentScreenViewModel
    let layout: LimitingReagentScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            reactionDefinition
            Spacer(minLength: 0)
            reactionToggle
        }
        .padding(.leading, layout.common.menuSize + layout.common.menuHPadding)
    }

    private var reactionDefinition: some View {
        TextLinesView(
            line: model.reaction.reactionDisplayWithElementState,
            fontSize: layout.common.reactionDefinitionFontSize
        )
        .frame(height: layout.common.reactionDefinitionHeight)
    }

    private var reactionToggle: some View {
        DropDownSelectionView(
            title: " Choose a reaction",
            options: LimitingReagentReaction.availableReactions,
            isToggled: .constant(model.input == .selectReaction),
            selection: $model.reaction,
            height: layout.common.reactionDefinitionHeight,
            widthToHeight: 12,
            animation: nil,
            displayString: { $0.displayString },
            label: { $0.label },
            disabledOptions: [],
            onSelection: model.next
        )
        .disabled(model.input != .selectReaction)
        .frame(
            height: layout.common.reactionSelectionToggleHeight,
            alignment: .top
        )
    }
}

private struct LimitingReagentRightStack: View {

    @ObservedObject var model: LimitingReagentScreenViewModel
    @ObservedObject var components: LimitingReagentComponents
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
        LimitingReagentEquationView(
            data: components.equationData,
            reactionProgress: components.reactionProgress,
            showTheoreticalData: model.equationState >= .showTheoreticalData,
            showActualData: model.equationState >= .showActualData
        )
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
