//
// Reactions App
//

import Foundation

public func within<Value: Comparable>(min: Value, max: Value, value: Value) -> Value {
    Swift.min(max, Swift.max(min, value))
}
