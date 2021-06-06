//
// Reactions App
//

import Foundation
import ReactionsCore

enum SubstancePart: CaseIterable {
    case substance, primaryIon, secondaryIon
}
typealias SubstanceValue<Value> = EnumMap<SubstancePart, Value>
extension EnumMap where Key == SubstancePart {

    init(
        substance: Value,
        primaryIon: Value,
        secondaryIon: Value
    ) {
        self.init(builder: {
            switch $0 {
            case .substance: return substance
            case .primaryIon: return primaryIon
            case .secondaryIon: return secondaryIon
            }
        })
    }

    var substance: Value {
        value(for: .substance)
    }

    var primaryIon: Value {
        value(for: .primaryIon)
    }

    var secondaryIon: Value {
        value(for: .secondaryIon)
    }
}
