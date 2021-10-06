//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PrecipitationScreen: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            PrecipitationScreenWithLayout(
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

private struct PrecipitationScreenWithLayout: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    let layout: PrecipitationScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            PrecipitationTopStack(
                model: model,
                layout: layout
            )
            .zIndex(1)

            Spacer(minLength: 0)

            HStack(spacing: 0) {
                PrecipitationBeaker(
                    model: model,
                    layout: layout
                )
                Spacer(minLength: 0)

                PrecipitationMiddleStack(
                    model: model,
                    components: model.components,
                    layout: layout
                )

                Spacer(minLength: 0)
                PrecipitationRightStack(
                    model: model,
                    components: model.components,
                    layout: layout
                )
            }
        }
    }
}

private struct PrecipitationTopStack: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    let layout: PrecipitationScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            reactionDefinition
            Spacer(minLength: 0)
            selectionToggle
        }
        .padding(.leading, layout.common.menuSize + layout.common.menuHPadding)
        .font(.system(size: layout.common.reactionDefinitionFontSize))
    }

    private var reactionDefinition: some View {
        PrecipitationReactionDefinition(
            reaction: model.chosenReaction,
            showMetal: model.showUnknownMetal,
            fontSize: layout.common.reactionDefinitionFontSize
        )
        .frame(height: layout.common.reactionDefinitionHeight)
        .padding(.top, layout.common.reactionDefinitionTopPadding)
    }

    private var selectionToggle: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: model.availableReactions,
            isToggled: .constant(model.input == .selectReaction),
            selection: $model.chosenReaction,
            height: layout.common.reactionSelectionToggleHeight,
            animation: nil,
            displayString: { $0.name(showMetal: false) },
            label: { $0.name(showMetal: false).label },
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

private struct PrecipitationMiddleStack: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    @ObservedObject var components: PrecipitationComponents
    let layout: PrecipitationScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            table
            Spacer(minLength: 0)
            chart
        }
    }

    private var table: some View {
        Table(
            rows: [.init(cells: ["Compound", "Molar Mass (g/mol)"])] + tableRows
        )
        .frame(size: layout.tableSize)
    }

    private var tableRows: [Table.Row] {
        PrecipitationReaction.Metal.allCases.map { metal in
            let compound = model.chosenReaction.unknownReactant.replacingMetal(with: metal)
            return .init(
                cells: [compound.name(showMetal: true), "\(compound.molarMass)"],
                emphasised: model.showUnknownMetal && metal == model.chosenReaction.unknownReactant.metal
            )
        }
    }

    private var chart: some View {
        ReactionProgressChart(
            model: components.reactionProgressModel,
            geometry: layout.common.reactionProgressGeometry(
                PrecipitationComponents.Molecule.self
            )
        )
    }
}

private struct PrecipitationRightStack: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    @ObservedObject var components: PrecipitationComponents
    let layout: PrecipitationScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            PrecipitationEquationView(
                data: model.equationData,
                reactionProgress: components.reactionProgress,
                state: model.equationState
            )
            .frame(size: layout.equationSize)

            Spacer(minLength: 0)

            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: model.nextIsDisabled,
                settings: layout.common.beakySettings
            )
        }
    }
}

struct PrecipitationScreenLayout {
    let common: ChemicalReactionsScreenLayout

    var beakerToggleTextHeight: CGFloat {
        0.1 * common.beakerSettings.beakerHeight
    }

    var beakerToggleFontSize: CGFloat {
        0.5 * beakerToggleTextHeight
    }

    var fillableBeakerSettings: FillableBeakerSettings {
        .init(beakerWidth: common.beakerSettings.beakerWidth)
    }

    func containerAreaMask(rows: CGFloat) -> CGSize {
        CGSize(
            width: common.containerMaskWidth,
            height: topOfWaterPosition(rows: rows)
        )
    }

    func topOfWaterPosition(rows: CGFloat) -> CGFloat {
        let commonTop = common.topOfWaterPosition(rows: rows)
        return commonTop - beakerToggleTextHeight
    }

    func topLeftOfWater(rows: CGFloat) -> CGPoint {
        let x = common.beakerHandleWidth + common.beakerLipWidthLeft
        let y = topOfWaterPosition(rows: rows)
        return CGPoint(x: x, y: y)
    }

    var tableSize: CGSize {
        let availableWidth = common.width - common.totalBeakerAreaWidth - common.beakyBoxWidth

        return CGSize(
            width: 0.7 * availableWidth,
            height: 0.35 * common.height
        )
    }

    var equationSize: CGSize {
        let availableHeight = common.height - common.beakyBoxHeight - common.reactionSelectionToggleHeight
        return CGSize(
            width: common.beakyBoxWidth,
            height: 0.85 * availableHeight
        )
    }

    var scalesLayout: DigitalScalesLayout {
        .init(width: scalesWidth)
    }

    var scalesRect: CGRect {
        let scalesHeight = scalesLayout.height
        return CGRect(
            origin: scalesPosition.offset(dx: -(scalesWidth / 2), dy: -(scalesHeight / 2)),
            size: CGSize(width: scalesWidth, height: scalesHeight)
        )
    }

    var scalesPosition: CGPoint {
        let x = common.totalBeakerAreaWidth - (scalesWidth / 2)
        let scalesHeight = scalesLayout.height

        let beakerHeight = common.beakerSettings.beakerHeight
        let topOfBeaker = bottomOfBeakerY - beakerHeight

        let minY = scalesHeight / 2
        let maxY = topOfBeaker - (scalesHeight / 2)

        let y = (minY + maxY) / 2
        return CGPoint(x: x, y: y)
    }

    func precipitatePositionInBeaker(rows: CGFloat) -> CGPoint {
        let waterHeight = common.waterHeight(rows: rows)
        return CGPoint(
            x: common.beakerCenterX,
            y: bottomOfBeakerY - (waterHeight / 2)
        )
    }

    private var bottomOfBeakerY: CGFloat {
        common.beakerAreaHeight - beakerToggleTextHeight
    }

    private var scalesWidth: CGFloat {
        0.5 * common.beakerSettings.beakerWidth
    }
}

struct PrecipitationScreen_Previews: PreviewProvider {
    static var previews: some View {
        PrecipitationScreen(model: .init())
    }
}
