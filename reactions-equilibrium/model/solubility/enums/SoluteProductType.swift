//
// Reactions App
//

import SwiftUI
import ReactionsCore

enum SoluteProductType: String, CaseIterable {
    case A, B

    var color: Color {
        switch self {
        case .A: return Color.from(RGB.aqMoleculeA)
        case .B: return Color.from(RGB.aqMoleculeB)
        }
    }
}
