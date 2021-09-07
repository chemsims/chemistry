//
// Reactions App
//

import SwiftUI

public struct MoleculeScalesGeometry {
    let width: CGFloat
    let height: CGFloat

    /// Ideal width to height ratio
    public static let widthToHeight: CGFloat = 1.657

    static let lineWidth: CGFloat = 0.8

    var maxRotationAngle: CGFloat {
        let maxForRight = Self.maxRotationForRightHand(
            rotationY: rotationY,
            singleArmWidth: armWidth / 2
        ).degrees
        let maxForLeft = Self.maxRotationForLeftHand(
            maxHeight: height - rotationY,
            singleArmWidth: armWidth / 2,
            basketHeight: basketHeight
        ).degrees
        return CGFloat(min(maxForLeft, maxForRight))
    }

    var rotationCenter: CGPoint {
        CGPoint(x: width / 2, y: rotationY)
    }

    private var rotationY: CGFloat {
        0.247 * height
    }

    var armWidth: CGFloat {
        width - basketWidth
    }

    var basketWidth: CGFloat {
        0.391 * height
    }

    var basketHeight: CGFloat {
        MoleculeScaleBasketGeometry.heightToWidth * basketWidth
    }

    var basketYOffset: CGFloat {
        basketHeight / 2
    }
 
    var badgeSize: CGFloat {
        0.5 * basketWidth
    }

    var badgeFontSize: CGFloat {
        0.75 * badgeSize
    }
}

extension MoleculeScalesGeometry {
    static func maxRotationForRightHand(
        rotationY: CGFloat,
        singleArmWidth: CGFloat
    ) -> Angle {
        Angle(radians: Double(asin(rotationY / singleArmWidth)))
    }


    static func maxRotationForLeftHand(
        maxHeight: CGFloat,
        singleArmWidth: CGFloat,
        basketHeight: CGFloat
    ) -> Angle {
        let sinTheta = (maxHeight - basketHeight) / singleArmWidth
        return Angle(radians: Double(asin(sinTheta)))
    }
}


struct MoleculeScaleBasketGeometry {

    static let heightToWidth: CGFloat = 1.11

    let width: CGFloat
    let height: CGFloat

    var moleculesBottomPadding: CGFloat {
        0.9 * basketHeight
    }

    var basketHeight: CGFloat {
        Self.basketHeightToTotalWidth * width
    }

    var singleMoleculePileSize: CGFloat {
        let availableWidth = width
        let availableHeight = height - basketHeight
        return min(availableWidth, availableHeight)
    }

    private static let basketHeightToTotalWidth: CGFloat = 0.21

}
