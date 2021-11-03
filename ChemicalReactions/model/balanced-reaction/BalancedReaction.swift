//
// Reactions App
//

import Foundation
import ReactionsCore

struct BalancedReaction: Equatable {

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

extension BalancedReaction: Identifiable {
    var id: String {
        "\(reactants.id):\(products.id)"
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
    enum ElementType: String {
        case reactant, product

        var label : String {
            rawValue
        }

        var opposite: ElementType {
            switch self {
            case .reactant: return .product
            case .product: return .reactant
            }
        }
    }

    enum ElementCount {
        case one, two
    }

    enum ElementOrder {
        case first, second
    }

    enum Elements: Equatable {
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

extension BalancedReaction.Elements {
    var id: String {
        asArray.map(\.id).reduce("") { $0 + $1 }
    }
}

extension BalancedReaction.Elements {
    var display: TextLine {
        switch self {
        case let .one(element): return element.molecule.textLine
        case let .two(first, second):
            return first.molecule.textLine + " + " + second.molecule.textLine
        }
    }
}

extension BalancedReaction {
    var display: TextLine {
        let r = reactants.display
        let p = products.display
        let markdown = r.asMarkdown + " ➝ " + p.asMarkdown
        let label = r.asString + " yields " + p.asString
        return TextLine(markdown, label: label)
    }
}

extension BalancedReaction: CustomDebugStringConvertible {
    var debugDescription: String {
        display.asString
    }
}
