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

    func color(for reaction: SolubleReactionType) -> RGB {
        switch self {
        case .primary: return reaction.soluteColor
        case .commonIon: return reaction.commonIonSolute
        case .acid: return RGB.acidSolute
        }
    }
}
