//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChemicalReactionsScreenLayout {
    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    static let topLevelScreenPadding: CGFloat = 10
}

// MARK: - Beaky
extension ChemicalReactionsScreenLayout {

    var beakyBoxHeight: CGFloat {
        0.35 * height
    }

    var beakyBoxWidth: CGFloat {
        0.33 * width
    }

    var beakySettings: BeakyGeometrySettings {
        BeakyGeometrySettings(
            width: beakyBoxWidth,
            height: beakyBoxHeight
        )
    }
}

// MARK: - Reaction selection
extension ChemicalReactionsScreenLayout {
    var reactionSelectionToggleHeight: CGFloat {
        0.05 * height
    }

    var reactionDefinitionHeight: CGFloat {
        menuSize
    }

    var reactionDefinitionTopPadding: CGFloat {
        menuHPadding - Self.topLevelScreenPadding
    }

    var reactionDefinitionLeadingPadding: CGFloat {
        menuSize + menuHPadding
    }

    var reactionDefinitionFontSize: CGFloat {
        0.8 * reactionDefinitionHeight
    }
}

// MARK: - Beaker
extension ChemicalReactionsScreenLayout {
    var beakerSettings: AdjustableFluidBeakerSettings {
        .init(
            minRows: ChemicalReactionsSettings.minRows,
            maxRows: ChemicalReactionsSettings.maxRows,
            beakerWidth: beakerWidth,
            beakerHeight: beakerHeight,
            sliderSettings: beakerSliderSettings,
            sliderHeight: beakerSliderHeight
        )
    }

    func topOfWaterPosition(rows: CGFloat) -> CGFloat {
        let topFromSlider = beakerSliderAxis.getPosition(at: rows)
        return beakerAreaHeight - beakerBottomPadding - beakerSliderHeight + topFromSlider
    }

    func waterHeight(rows: CGFloat) -> CGFloat {
        beakerSettings.waterHeight(rows: rows)
    }

    var totalBeakerAreaWidth: CGFloat {
        beakerSliderSettings.handleWidth + beakerWidth
    }

    var beakerAreaHeight: CGFloat {
        height - max(reactionDefinitionHeight, reactionSelectionToggleHeight)
    }

    var beakerBottomPadding: CGFloat {
        if verticalSizeClass.contains(.regular) {
            return reactionProgressAxisHeight
        }
        return 0
    }

    private var beakerWidth: CGFloat {
        0.23 * width
    }

    private var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var innerBeakerWidth: CGFloat {
        beakerGeometry.innerBeakerWidth
    }

    var beakerLipWidthLeft: CGFloat {
        beakerGeometry.lipRadius + beakerGeometry.lipWidthLeft
    }

    var beakerGeometry: BeakerSettings {
        BeakerSettings(width: beakerWidth, hasLip: true)
    }

    private var beakerSliderHeight: CGFloat {
        0.8 * beakerHeight
    }

    private var beakerSliderAxis: LinearAxis<CGFloat> {
        beakerSettings.sliderAxis
    }

    var beakerSliderSettings: SliderGeometrySettings {
        .init(handleWidth: 0.13 * beakerWidth)
    }

    var beakerCenterX: CGFloat {
        beakerHandleWidth + (beakerWidth / 2)
    }

    var beakerHandleWidth: CGFloat {
        beakerSliderSettings.handleWidth
    }
}


// MARK: - Containers
extension ChemicalReactionsScreenLayout {
    var containerWidth: CGFloat {
        0.13 * beakerWidth
    }

    private var containerHeight: CGFloat {
        containerWidth * ParticleContainer.heightToWidth
    }

    var containerFontSize: CGFloat {
        0.3 * containerWidth
    }

    var containerMoleculeSize: CGFloat {
        innerBeakerWidth / CGFloat(MoleculeGridSettings.cols)
    }

    var containerShakeHalfXRange: CGFloat {
        (innerBeakerWidth - containerMoleculeSize) / 2
    }

    var containerShakeHalfYRange: CGFloat {
        containerHeight
    }

    func containerMaskSize(rows: CGFloat) -> CGSize {
        CGSize(
            width: containerMaskWidth,
            height: containerAreaHeight(rows: rows)
        )
    }

    func containerAreaHeight(rows: CGFloat) -> CGFloat {
        topOfWaterPosition(rows: rows)
    }


    // We add the container height on the beaker width, as the edge of a
    // rotated container would otherwise be clipped when moved to the
    // leading/trailing edge of the frame
    var containerMaskWidth: CGFloat {
        beakerWidth + containerHeight
    }

    func containerPosition(index: Int, active: Bool) -> CGPoint {
        active ? activeContainerPosition : initialContainerPosition(index: index)
    }

    func initialContainerPosition(index: Int) -> CGPoint {
        CGPoint(x: initialContainerX(index: index), y: initialContainerY)
    }

    private func initialContainerX(index: Int) -> CGFloat {
        let startOfBeaker = beakerSliderSettings.handleWidth
        let firstContainerX = startOfBeaker + (containerWidth / 2)
        let spacing = 1.5 * containerWidth

        return firstContainerX + (CGFloat(index) * spacing)
    }

    var activeContainerPosition: CGPoint {
        CGPoint(x: beakerCenterX, y: activeContainerY)
    }

    private var initialContainerY: CGFloat {
        let topSpace = max(reactionSelectionToggleHeight, reactionDefinitionHeight)
        let ideal = topSpace + containerHeight
        let minY = height - beakerBottomPadding - beakerHeight - maxInitialContainerYDistanceFromBeaker - containerHeight
        return max(minY, ideal)
    }

    private var maxInitialContainerYDistanceFromBeaker: CGFloat {
        125
    }

    private var activeContainerY: CGFloat {
        initialContainerY + (0.75 * containerHeight)
    }

    var containerLineWidth: CGFloat {
        0.4
    }
}

// MARK: - Reaction progress chart
extension ChemicalReactionsScreenLayout {
    func reactionProgressGeometry<MoleculeType: CaseIterable>(
        _ type: MoleculeType.Type
    ) -> ReactionProgressChartGeometry<MoleculeType> {
        let chartSize = 0.35 * height
        return ReactionProgressChartGeometry(
            chartSize: chartSize,
            moleculeType: type,
            topPadding: 0.1 * chartSize
        )
    }

    private var reactionProgressAxisHeight: CGFloat {
        reactionProgressGeometry(LimitingReagentComponents.Element.self).axisLayout.height
    }
}
