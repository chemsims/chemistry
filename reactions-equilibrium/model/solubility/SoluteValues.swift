//
// Reactions App
//

import ReactionsCore

typealias SoluteValues<Value> = EnumMap<SoluteProductType, Value>

extension EnumMap where Key == SoluteProductType {
    var productA: Value {
        value(for: .A)
    }

    var productB: Value {
        value(for: .B)
    }

    init(
        productA: Value,
        productB: Value
    ) {
        self.init(builder: { element in
            switch element {
            case .A: return productA
            case .B: return productB
            }
        })
    }
}
