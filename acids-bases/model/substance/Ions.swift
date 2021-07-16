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

// old cases

    case Cl, A, Na, I, Br, K, Li, F, CN, HS, B


    // TODO use color names which correspond with symbol names
    var rgb: RGB {
        switch self {
        case .Cl: return RGB.moleculeB
        case .I: return RGB.moleculeD
        case .Li: return RGB.moleculeI
        case .F: return RGB.indicator
        case .CN: return RGB.hydrogenDarker
        case .HS: return RGB.moleculeA

        case .A: return RGB.moleculeA
        case .Br: return RGB.moleculeC
        case .K: return RGB.moleculeD
        case .Na: return RGB.moleculeE
        case .B: return RGB.moleculeG
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
