//
// Reactions App
//
  

import SwiftUI

/// A UIHostingController which can prefer deferring screen edge system gestures
///
/// This uses global state, as the top-level hosting controller must provide the property, rather than in a deeper view
class DeferScreenEdgesHostingController<Content: View>: UIHostingController<Content> {

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        DeferScreenEdgesState.shared.deferEdges
    }

    func didSetEdges() {
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
}


class DeferScreenEdgesState {

    private init() { }

    static let shared = DeferScreenEdgesState()

    var deferEdges: UIRectEdge = [] {
        didSet {
            if (deferEdges != oldValue) {
                didSetEdgesDelegate?()
            }
        }
    }

    var didSetEdgesDelegate: (() -> Void)?
}
