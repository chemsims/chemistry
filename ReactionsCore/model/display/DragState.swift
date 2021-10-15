//
// Reactions App
//

import CoreGraphics

public enum DragState: Equatable {

    /// Element is not being dragged
    case none

    /// Element is being dragged with the given offset
    case dragging(offset: CGSize)
}

extension DragState {
    public var offset: CGSize {
        switch self {
        case .none: return .zero
        case let .dragging(offset): return offset
        }
    }
}
