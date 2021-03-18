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

    func map<MappedValue>(_ f: (Value) -> MappedValue) -> MoleculeValue<MappedValue> {
        MoleculeValue<MappedValue>(builder: { f(value(for: $0)) })
    }

    func combine<MappedValue>(
        with other: MoleculeValue<Value>,
        using combiner: (Value, Value) -> MappedValue
    ) -> MoleculeValue<MappedValue> {
        MoleculeValue<MappedValue>(builder: { molecule in
            let lhs = value(for: molecule)
            let rhs = other.value(for: molecule)
            return combiner(lhs, rhs)
        })
    }

    func value(for molecule: AqueousMolecule) -> Value {
        switch molecule {
        case .A: return reactantA
        case .B: return reactantB
        case .C: return productC
        case .D: return productD
        }
    }

    func updating(with newValue: Value, for molecule: AqueousMolecule) -> MoleculeValue<Value> {
        MoleculeValue(builder: {
            $0 == molecule ? newValue : value(for: $0)
        })
    }
}

extension MoleculeValue {
    var all: [Value] {
        [reactantA, reactantB, productC, productD]
    }
}
