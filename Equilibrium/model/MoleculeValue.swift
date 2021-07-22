//
// Reactions App
//

import Foundation
import ReactionsCore

typealias MoleculeValue<Value> = EnumMap<AqueousMolecule, Value>

extension EnumMap where Key == AqueousMolecule {
    init(
        reactantA: Value,
        reactantB: Value,
        productC: Value,
        productD: Value
    ) {
        self.init(builder: { element in
            switch element {
            case .A: return reactantA
            case .B: return reactantB
            case .C: return productC
            case .D: return productD
            }
        })
    }

    var reactantA: Value {
        value(for: .A)
    }

    var reactantB: Value {
        value(for: .B)
    }

    var productC: Value {
        value(for: .C)
    }

    var productD: Value {
        value(for: .D)
    }
}
