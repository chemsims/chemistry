//
// Reactions App
//

import ReactionsCore

enum SoluteType {
    case primary, commonIon, acid

    func color(for reaction: SolubleReactionType) -> RGB {
        switch self {
        case .primary: return reaction.soluteColor
        case .commonIon: return reaction.commonIonSolute
        case .acid: return RGB.acidSolute
        }
    }
}
