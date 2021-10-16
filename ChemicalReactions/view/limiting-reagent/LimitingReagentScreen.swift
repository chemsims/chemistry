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
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)
            
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
}

private struct LimitingReagentScreenWithLayout: View {

    @ObservedObject var model: LimitingReagentScreenViewModel
    let layout: LimitingReagentScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            LimitingReagentTopStack(model: model, layout: layout)
                .zIndex(1)
                .accessibility(sortPriority: 1)
            Spacer(minLength: 0)
            HStack(alignment: .bottom, spacing: 0) {
                beaker
                    .accessibilityElement(children: .contain)
                    .accessibility(sortPriority: 2)

                Spacer(minLength: 0)

                LimitingReagentRightStack(
                    model: model,
                    components: model.components,
                    layout: layout
                )
                .accessibilityElement(children: .contain)
                .accessibility(sortPriority: 3)
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
            line: reactionLine,
            fontSize: layout.common.reactionDefinitionFontSize
        )
        .frame(height: layout.common.reactionDefinitionHeight)
        .background(Color.white.padding(-0.1 * layout.common.reactionDefinitionHeight))
        .colorMultiply(model.highlights.colorMultiply(for: .reactionDefinitionStates))
    }

    private var reactionLine: TextLine {
        if model.highlights.elements.contains(.reactionDefinitionStates) {
            return model.reaction.reactionDisplayWithEmphasisedElementState
        }
        return model.reaction.reactionDisplayWithElementState
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
            indicatorIsDisabled: true,
            disabledOptions: [],
            onSelection: model.didSelectReaction
        )
        .disabled(model.input != .selectReaction)
        .frame(
            height: layout.common.reactionSelectionToggleHeight,
            alignment: .top
        )
        .colorMultiply(model.highlights.colorMultiply(for: .selectReaction))
    }
}

private struct LimitingReagentRightStack: View {

    @ObservedObject var model: LimitingReagentScreenViewModel
    @ObservedObject var components: LimitingReagentComponents
    let layout: LimitingReagentScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            equation
                .accessibility(sortPriority: 1)
            HStack(alignment: .bottom, spacing: 0) {
                Spacer(minLength: 0)
                chart
                    .accessibility(sortPriority: 2)
                Spacer(minLength: 0)
                beaky
                    .accessibility(sortPriority: 3)
            }
        }
    }

    private var equation: some View {
        LimitingReagentEquationView(
            data: components.equationData,
            reactionProgress: components.reactionProgress,
            showTheoreticalData: model.equationState >= .showTheoreticalData,
            showActualData: model.equationState >= .showActualData,
            highlights: model.highlights
        )
    }

    private var chart: some View {
        ReactionProgressChart(
            model: components.reactionProgressModel,
            geometry: layout.common.reactionProgressGeometry(LimitingReagentComponents.Element.self)
        )
        .colorMultiply(model.highlights.colorMultiply(for: nil))
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
