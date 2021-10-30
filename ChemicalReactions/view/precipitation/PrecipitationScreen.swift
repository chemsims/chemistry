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
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

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
}

private struct PrecipitationScreenWithLayout: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    let layout: PrecipitationScreenLayout


    // We need to use a ZStack as the beaker should be higher than the
    // reaction definition (as the container tooltip may overlap it), but
    // the selection toggle should be above everything
    var body: some View {
        ZStack {
            reactionDefinition
            bottomStack
            selectionToggleWithBranchMenu
        }
        .frame(width: layout.common.width, height: layout.common.height)
    }

    private var reactionDefinition: some View {
        PrecipitationReactionDefinition(
            reaction: model.chosenReaction,
            showMetal: model.showUnknownMetal,
            emphasiseMetal: model.showUnknownMetal || model.emphasiseUnknownMetalSymbol,
            fontSize: layout.common.reactionDefinitionFontSize
        )
        .frame(height: layout.common.reactionDefinitionHeight)
        .background(Color.white.padding(-0.1 * layout.common.reactionDefinitionHeight))
        .padding(.top, layout.common.reactionDefinitionTopPadding)
        .padding(.leading, layout.common.reactionDefinitionLeadingPadding)
        .colorMultiply(model.highlights.colorMultiply(for: .reactionDefinition))
        .spacing(
            horizontalAlignment: .leading,
            verticalAlignment: .top
        )
    }

    private var selectionToggleWithBranchMenu: some View {
        HStack(spacing: layout.common.branchMenuHSpacing) {
            selectionToggle
            BranchMenu(layout: layout.common.branchMenu)
        }
        .spacing(
            horizontalAlignment: .trailing,
            verticalAlignment: .top
        )
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
            indicatorIsDisabled: true,
            disabledOptions: [],
            onSelection: model.didSelectReaction
        )
        .disabled(model.input != .selectReaction)
        .frame(
            height: layout.common.reactionSelectionToggleHeight,
            alignment: .top
        )
        .colorMultiply(model.highlights.colorMultiply(for: .reactionToggle))
    }

    private var bottomStack: some View  {
        HStack(alignment: .bottom, spacing: 0) {
            PrecipitationBeaker(
                model: model,
                layout: layout
            )
            .accessibilityElement(children: .contain)

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
        .frame(height: layout.common.height)
        .verticalSpacing(alignment: .bottom)
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
            emphasiseMetal: model.showUnknownMetal || model.emphasiseUnknownMetalSymbol,
            fontSize: layout.common.reactionDefinitionFontSize
        )
        .frame(height: layout.common.reactionDefinitionHeight)
        .padding(.top, layout.common.reactionDefinitionTopPadding)
        .background(Color.white.padding(-0.1 * layout.common.reactionDefinitionHeight))
        .colorMultiply(model.highlights.colorMultiply(for: .reactionDefinition))
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
        .colorMultiply(model.highlights.colorMultiply(for: .reactionToggle))
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
            rows: [headerTableRow] + tableRows
        )
        .frame(size: layout.tableSize)
        .accessibilityElement(children: .contain)
        .accessibility(label: Text("Table of elements to their molar mass"))
    }

    private var headerTableRow: Table.Row {
        .init(
            cells: ["Compound", "Molar Mass ($g/mol$)"],
            colorMultiply: model.highlights.colorMultiply(for: .metalTable)
        )
    }

    private var tableRows: [Table.Row] {
        PrecipitationReaction.Metal.allCases.map { metal in
            let compound = model.chosenReaction.unknownReactant.replacingMetal(with: metal)
            let isCorrectMetal = model.chosenReaction.unknownReactant.metal == metal

            var screenElements = [PrecipitationScreenViewModel.ScreenElement.metalTable]
            if isCorrectMetal {
                screenElements.append(.correctMetalRow)
            }

            return .init(
                cells: [compound.name(showMetal: true), "\(compound.molarMass)"],
                emphasised: model.showUnknownMetal && isCorrectMetal,
                colorMultiply: model.highlights.colorMultiply(anyOf: screenElements)
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
        .colorMultiply(model.highlights.colorMultiply(for: nil))
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
                state: model.equationState,
                highlights: model.highlights
            )
            .frame(size: layout.equationSize)
            .accessibilityElement(children: .contain)

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
            height: topOfWaterPosition(rows: rows) + containerAreaMaskOffset
        )
    }

    // We need to move the mask up a little, as the tooltip may go outside
    // of the container view bounds when the container is near the top
    var containerAreaMaskOffset: CGFloat {
        common.reactionDefinitionHeight
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
        let y = min(maxScalesY, scalesY)
        return CGPoint(x: x, y: y)
    }

    private var scalesY: CGFloat {
        if idealScalesY >= minScalesY && idealScalesY <= maxScalesY {
            return idealScalesY
        }
        return (minScalesY + maxScalesY) / 2
    }

    private var idealScalesY: CGFloat {
        common.initialContainerPosition(index: 0).y
    }

    private var minScalesY: CGFloat {
        0.6 * scalesLayout.height
    }

    private var maxScalesY: CGFloat {
        let topOfBeaker = bottomOfBeakerY - common.beakerSettings.beakerHeight
        return topOfBeaker - (0.6 * scalesLayout.height)
    }

    func precipitatePositionInBeaker(rows: CGFloat) -> CGPoint {
        let waterHeight = common.waterHeight(rows: rows)
        return CGPoint(
            x: common.beakerCenterX,
            y: bottomOfBeakerY - (waterHeight / 2)
        )
    }

    var precipitateMaxDragX: CGFloat {
        common.totalBeakerAreaWidth
    }

    func precipitateShapeSize(rows: CGFloat) -> CGSize {
        let size = min(maxPrecipitateShapeWidth, maxPrecipitateShapeHeight(rows: rows))
        return CGSize(width: size, height: size)
    }

    private func maxPrecipitateShapeHeight(rows: CGFloat) -> CGFloat {
        common.waterHeight(rows: rows)
    }

    private var maxPrecipitateShapeWidth: CGFloat {
        common.innerBeakerWidth
    }

    private var bottomOfBeakerY: CGFloat {
        common.beakerAreaHeight - beakerToggleTextHeight - common.beakerBottomPadding
    }

    private var scalesWidth: CGFloat {
        0.5 * common.beakerSettings.beakerWidth
    }

    var handWidth: CGFloat {
        2 * common.containerWidth
    }
}
