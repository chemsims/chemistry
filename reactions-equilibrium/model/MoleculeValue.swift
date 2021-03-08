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
}
