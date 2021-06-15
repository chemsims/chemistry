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
}

enum SecondaryIon: String {
    case A, Cl, Br, K, Na, Ba, B


    // TODO use color names which correspond with symbol names
    var rgb: RGB {
        switch self {
        case .A: return RGB.moleculeA
        case .Cl: return RGB.moleculeB
        case .Br: return RGB.moleculeC
        case .K: return RGB.moleculeD
        case .Na: return RGB.moleculeE
        case .Ba: return RGB.moleculeF
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
