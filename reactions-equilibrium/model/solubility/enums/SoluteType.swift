//
// Reactions App
//

import ReactionsCore

enum SoluteType {
    case primary, commonIon, acid

    var color: RGB {
        switch self {
        case .primary: return RGB.primarySolute
        case .commonIon: return RGB.commonIonSolute
        case .acid: return RGB.acidSolute
        }
    }
}
