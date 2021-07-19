//
// Reactions App
//

import SwiftUI
import ReactionsCore

enum PrimaryIon: String, CaseIterable {
    case hydrogen = "H"
    case hydroxide = "OH"

    var complement: PrimaryIon {
        switch self {
        case .hydrogen: return .hydroxide
        case .hydroxide: return .hydrogen
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .hydrogen: return Labelling.stringToLabel("H^+^")
        case .hydroxide: return Labelling.stringToLabel("OH^-^")
        }

    }

    var rgb: RGB {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }

    var color: Color {
        rgb.color
    }

    var chargedSymbol: AcidOrBase.ChargedSymbol {
        .init(symbol: TextLine(rawValue), charge: self == .hydrogen ? .positive : .negative)
    }
}

enum SecondaryIon: String {

    case Cl, A, Na, I, Br, K, Li, F, CN, HS, B

    var rgb: RGB {
        switch self {
        case .Cl: return .chlorine
        case .I: return .iodine
        case .Li: return .lithium
        case .F: return .ionF
        case .CN: return .cyanide
        case .HS: return .ionHS

        case .A: return .ionA
        case .Br: return .bromine
        case .K: return .potassium
        case .Na: return .sodium
        case .B: return .ionB
        }
    }

    var color: Color {
        rgb.color
    }
}

typealias PrimaryIonValue<Value> = EnumMap<PrimaryIon, Value>
extension EnumMap where Key == PrimaryIon {

    init(
        hydrogen: Value,
        hydroxide: Value
    ) {
        self.init(builder: { element in
            switch element {
            case .hydrogen: return hydrogen
            case .hydroxide: return hydroxide
            }
        })
    }

    var hydrogen: Value {
        value(for: .hydrogen)
    }

    var hydroxide: Value {
        value(for: .hydroxide)
    }
}
