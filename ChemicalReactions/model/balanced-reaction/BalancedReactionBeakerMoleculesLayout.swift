//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct BalancedReactionBeakerMoleculeLayout {

    let firstMolecule: BalancedReaction.Molecule
    let secondMolecule: BalancedReaction.Molecule?
    let beakerRect: CGRect
    let beakerSettings: BeakerSettings


    /// Returns the position of the given `molecule` in the beaker, if it can be placed.
    func position(of molecule: BalancedReaction.Molecule, index: Int) -> CGPoint? {
        guard let rect = availableRect(for: molecule) else {
            return nil
        }

        let grid = GridCoordinateList.list(cols: Self.cols, rows: Self.rows)

        guard let cell = grid[safe: index] else {
            return nil
        }

        return TableCellPosition.position(
            in: rect,
            rows: Self.rows,
            cols: Self.cols,
            rowIndex: cell.row,
            colIndex: cell.col
        )
    }

    private func availableRect(for molecule: BalancedReaction.Molecule) -> CGRect? {
        if firstMolecule == molecule {
            return firstMoleculeRect
        } else if let second = secondMolecule, second == molecule {
            return secondMoleculeRect
        }
        return nil
    }

    private var firstMoleculeRect: CGRect {
        if secondMolecule == nil {
            return innerBeakerRect
        }
        return CGRect(
            origin: innerBeakerRect.origin,
            size: CGSize(
                width: innerBeakerRect.width / 2, height: innerBeakerRect.height)
        )
    }

    private var secondMoleculeRect: CGRect {
        firstMoleculeRect.offsetBy(dx: innerBeakerRect.width / 2, dy: 0)
    }

    private var innerBeakerRect: CGRect {
        let totalLipGap = beakerSettings.width - beakerSettings.innerBeakerWidth
        return CGRect(
            origin: beakerRect.origin.offset(dx: totalLipGap / 2, dy: 0),
            size: CGSize(width: beakerSettings.innerBeakerWidth, height: beakerRect.height)
        )
    }
}

extension BalancedReactionBeakerMoleculeLayout {
    static let rows = 4
    static let cols = 2

    fileprivate static let maxCount = cols * rows
}
