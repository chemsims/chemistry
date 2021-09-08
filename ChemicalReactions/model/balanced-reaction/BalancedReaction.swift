//
// Reactions App
//

import Foundation

struct BalancedReaction {

    init(reactants: Elements, products: Elements) {
        assert(Self.moleculesAreValid(reactants: reactants, products: products))
        self.reactants = reactants
        self.products = products
    }

    let reactants: Elements
    let products: Elements

    func elements(ofType type: ElementType) -> Elements {
        switch type {
        case .reactant: return reactants
        case .product: return products
        }
    }
}

extension BalancedReaction {
    private static func moleculesAreValid(reactants: Elements, products: Elements) -> Bool {
        let reactantMolecules = Set(reactants.asArray.map(\.molecule))
        let productMolecules = Set(products.asArray.map(\.molecule))
        return reactantMolecules.intersection(productMolecules).isEmpty
    }
}

extension BalancedReaction {
    enum ElementType {
        case reactant, product
    }

    enum ElementCount {
        case one, two
    }

    enum ElementOrder {
        case first, second
    }

    enum Elements {
        case one(element: Element)
        case two(first: Element, second: Element)

        var count: ElementCount {
            switch self {
            case .one: return .one
            case .two: return .two
            }
        }

        var first: Element {
            switch self {
            case let .one(element): return element
            case let .two(first, _): return first
            }
        }

        var second: Element? {
            if case let .two(_, second) = self {
                return second
            }
            return nil
        }

        var asArray: [Element] {
            switch self {
            case let .one(element): return [element]
            case let .two(first, second): return [first, second]
            }
        }
    }
}

extension BalancedReaction {
    var setOfAtoms: Set<Atom> {
        let reactantAtoms = reactants.asArray.flatMap { $0.molecule.atoms }.map(\.atom)
        let productAtoms = products.asArray.flatMap { $0.molecule.atoms }.map(\.atom)
        return Set(reactantAtoms + productAtoms)
    }
}
