//
// Reactions App
//

import CoreGraphics

/// An identifiable point whose position may change
public struct MovingPoint: Identifiable {

    public init(position: CGPoint) {
        self.position = position
    }

    public let id = UUID()
    public var position: CGPoint
}
