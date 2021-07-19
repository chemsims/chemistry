//
// Reactions App
//

import Foundation
import ReactionsCore

enum SubstancePart: Int, CaseIterable, Identifiable {
    case substance, primaryIon, secondaryIon

    var id: Int {
        rawValue
    }
}

enum ExtendedSubstancePart: EnumMappable {
    case substance, secondaryIon, hydrogen, hydroxide
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

extension PrimaryIon {
    var extendedSubstancePart: ExtendedSubstancePart {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }
}
