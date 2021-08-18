//
// Reactions App
//

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
