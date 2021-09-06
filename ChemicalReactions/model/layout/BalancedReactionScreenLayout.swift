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
        let originY = common.height - common.beakyBoxHeight - moleculeTableSize.height
        return CGRect(
            origin: CGPoint(x: originX, y: originY),
            size: moleculeTableSize
        )
    }

    var moleculeTableAtomSize: CGFloat {
        let cellWidth = moleculeTableSize.width / 2
        let cellHeight = moleculeTableSize.height / 2

        let atomSizeToCellSize: CGFloat = 0.3

        let maxForWidth = atomSizeToCellSize * cellWidth
        let maxForHeight = atomSizeToCellSize * cellHeight

        return min(maxForWidth, maxForHeight)
    }

    private var moleculeTableSize: CGSize {
        CGSize(
            width: 0.35 * common.width,
            height: 0.5 * common.height
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
