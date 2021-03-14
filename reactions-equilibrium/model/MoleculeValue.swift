//
// Reactions App
//

import Foundation

/// Provides a value of type `value` for each molecule
struct MoleculeValue<Value> {
    let reactantA: Value
    let reactantB: Value
    let productC: Value
    let productD: Value

    init(
        reactantA: Value,
        reactantB: Value,
        productC: Value,
        productD: Value
    ) {
        self.reactantA = reactantA
        self.reactantB = reactantB
        self.productC = productC
        self.productD = productD
    }

    init(builder: (AqueousMolecule) -> Value) {
        self.init(
            reactantA: builder(.A),
            reactantB: builder(.B),
            productC: builder(.C),
            productD: builder(.D)
        )
    }

    func value(for molecule: AqueousMolecule) -> Value {
        switch molecule {
        case .A: return reactantA
        case .B: return reactantB
        case .C: return productC
        case .D: return productD
        }
    }
}

extension MoleculeValue {
    var all: [Value] {
        [reactantA, reactantB, productC, productD]
    }
}
