//
// Reactions App
//

import Foundation

struct SoluteValues<Value> {
    let productA: Value
    let productB: Value

    init(productA: Value, productB: Value) {
        self.productA = productA
        self.productB = productB
    }

    init(builder: (SoluteProductType) -> Value) {
        self.init(productA: builder(.A), productB: builder(.B))
    }

    static func constant(_ value: Value) -> SoluteValues {
        SoluteValues(builder: { _ in value })
    }

    func map<MappedValue>(_ f: (Value) -> MappedValue) -> SoluteValues<MappedValue> {
        SoluteValues<MappedValue>(productA: f(productA), productB: f(productB))
    }

    func value(for element: SoluteProductType) -> Value {
        switch element {
        case .A: return productA
        case .B: return productB
        }
    }

    var all: [Value] {
        [productA, productB]
    }
}
