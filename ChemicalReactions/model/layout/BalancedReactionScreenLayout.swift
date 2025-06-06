//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct BalancedReactionScreenLayout {
    let common: ChemicalReactionsScreenLayout
}

// MARK: - molecule table
extension BalancedReactionScreenLayout {

    var moleculeTableRect: CGRect {
        let originX = common.width - moleculeTableSize.width

        let topY = common.reactionSelectionToggleHeight
        let bottomY = common.height - common.beakyBoxHeight
        let centerY = (topY + bottomY) / 2
        let originY = centerY - (moleculeTableSize.height / 2)

        return CGRect(
            origin: CGPoint(x: originX, y: originY),
            size: moleculeTableSize
        )
    }

    var moleculeTableAtomSize: CGFloat {
        let cellWidth = moleculeTableSize.width / 2
        let cellHeight = moleculeTableSize.height / 2

        let atomSizeToCellSize: CGFloat = 0.33

        let maxForWidth = atomSizeToCellSize * cellWidth
        let maxForHeight = atomSizeToCellSize * cellHeight

        return min(maxForWidth, maxForHeight)
    }

    var beakerMoleculeAtomSize: CGFloat {
        0.05 * beakerSize.height
    }

    /// The size of a box around the center of a molecule, which is used to detect
    /// if a molecule is overlapping a beaker at the end of the drag gesture.
    var moleculeBoundingBoxSizeForOverlapDetection: CGFloat {
        1.5 * moleculeTableAtomSize
    }

    /// Size of each label on on the molecule table, before it is rotated
    var moleculeTableLabelSize: CGSize {
        CGSize(
            width: moleculeTableSize.height / 2,
            height: 0.1 * moleculeTableSize.height
        )
    }

    var moleculeTableProductLabelPosition: CGPoint {
        let dy = 0.25 * moleculeTableSize.height
        return moleculeTableRect.origin.offset(dx: 0, dy: dy)
    }

    var moleculeTableReactantLabelPosition: CGPoint {
        let dy = 0.75 * moleculeTableSize.height
        return moleculeTableRect.origin.offset(dx: 0, dy: dy)
    }

    var moleculeTableDividerSize: CGSize {
        CGSize(width: 0.7 * moleculeTableSize.width, height: 1)
    }

    var moleculeTableLabelFontSize: CGFloat {
        0.7 * moleculeTableLabelSize.height
    }

    private var moleculeTableSize: CGSize {
        CGSize(
            width: 0.35 * common.width,
            height: 0.45 * common.height
        )
    }

    private var moleculeTableSizeWithLabels: CGSize {
        // note we add the height of the label size because it is rotated
        // by 90 degrees. Also, only half of the label is outside of the
        // rect, so we only add half of the height.
        return CGSize(
            width: moleculeTableSize.width + (moleculeTableLabelSize.height / 2),
            height: moleculeTableSize.height
        )
    }
}

// MARK: - Beaker
extension BalancedReactionScreenLayout {

    private static let maxBeakerHeightToHeight: CGFloat = 0.5

    var beakerSettings: BeakerSettings {
        .init(width: beakerWidth, hasLip: true)
    }

    var beakerSize: CGSize {
        CGSize(width: beakerWidth, height: beakerHeight)
    }

    var firstBeakerRect: CGRect {
        beakerRect(center: firstBeakerPosition)
    }

    var secondBeakerRect: CGRect {
        beakerRect(center: secondBeakerPosition)
    }

    var firstBeakerPosition: CGPoint {
        CGPoint(x: beakerWidth / 2, y: beakerY)
    }

    var secondBeakerPosition: CGPoint {
        let gapBetweenBeakers = availableWidthForBeakers - (2 * beakerWidth)
        return CGPoint(
            x: firstBeakerPosition.x + gapBetweenBeakers + beakerWidth,
            y: beakerY
        )
    }

    var reactionArrowPosition: CGPoint {
        CGPoint(
            x: (firstBeakerPosition.x + secondBeakerPosition.x) / 2,
            y: firstBeakerPosition.y
        )
    }

    var reactionArrowWidth: CGFloat {
        0.4 * widthBetweenBeakers
    }

    private var widthBetweenBeakers: CGFloat {
        let gapBetweenCenters = secondBeakerPosition.x - firstBeakerPosition.x
        return gapBetweenCenters - beakerWidth
    }

    private func beakerRect(center: CGPoint) -> CGRect {
        CGRect(
            origin: center.offset(dx: -beakerSize.width / 2, dy: -beakerSize.height / 2),
            size: beakerSize
        )
    }

    private var availableWidthForBeakers: CGFloat {
        let rhsWidth = max(common.beakyBoxWidth, moleculeTableSize.width)
        return 0.9 * (common.width - rhsWidth)
    }

    private var beakerY: CGFloat {
        common.height - (beakerHeight / 2)
    }

    private var beakerWidth: CGFloat {
        let idealWidth = 0.45 * availableWidthForBeakers
        let maxHeight = Self.maxBeakerHeightToHeight * common.height
        let maxWidthForMaxHeight = maxHeight / BeakerSettings.heightToWidth
        return min(idealWidth, maxWidthForMaxHeight)
    }

    private var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }
}

// MARK: - Reaction definition
extension BalancedReactionScreenLayout {

    var reactionDefinitionSize: CGSize {
        CGSize(
            width: 0.5 * common.width,
            height: 0.15 * common.height
        )
    }

    var reactionDefinitionToMoleculeVSpacing: CGFloat {
        0.1 * reactionDefinitionSize.height
    }

    var reactionDefinitionMoleculeAtomSize: CGFloat {
        reactionDefinitionSize.height / 5
    }

    var reactionDefinitionFontSize: CGFloat {
        0.3 * reactionDefinitionSize.height
    }
}

// MARK: - Scales
extension BalancedReactionScreenLayout {
    var scalesSize: CGSize {
        CGSize(
            width: MoleculeScalesGeometry.widthToHeight * scalesHeight,
            height: scalesHeight
        )
    }

    var scalesTotalWidth: CGFloat {
        availableWidthForBeakers
    }

    var scalesLabelSize: CGSize {
        CGSize(width: scalesSize.width / 3, height: 0.16 * scalesSize.height)
    }

    var scalesLabelFontSize: CGFloat {
        0.82 * scalesLabelSize.height
    }

    private var scalesHeight: CGFloat {
        let availableHeight = common.height - beakerHeight - reactionDefinitionSize.height
        let idealHeight = 0.8 * availableHeight
        let maxWidth = 0.3 * availableWidthForBeakers
        let maxHeightForMaxWidth = maxWidth / MoleculeScalesGeometry.widthToHeight
        return min(idealHeight, maxHeightForMaxWidth)
    }
}

// MARK: - Misc
extension BalancedReactionScreenLayout {
    var moleculeDragHandSize: CGSize {
        CGSize(width: 1.2 * moleculeTableAtomSize, height: 1.2 * moleculeTableAtomSize)
    }
}
