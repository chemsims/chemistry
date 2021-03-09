//
// Reactions App
//

import SwiftUI

/// A UIHostingController which can prefer deferring screen edge system gestures
///
/// This uses global state, as the top-level hosting controller must provide the property, rather than in a deeper view
public class DeferScreenEdgesHostingController<Content: View>: UIHostingController<Content> {

    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        DeferScreenEdgesState.shared.deferEdges
    }

    public func didSetEdges() {
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
}

public class DeferScreenEdgesState {

    private init() { }

    public static let shared = DeferScreenEdgesState()

    public var deferEdges: UIRectEdge = [] {
        didSet {
            if deferEdges != oldValue {
                didSetEdgesDelegate?()
            }
        }
    }

    public var didSetEdgesDelegate: (() -> Void)?
}
