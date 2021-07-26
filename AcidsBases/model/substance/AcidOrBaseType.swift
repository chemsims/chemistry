//
// Reactions App
//

import ReactionsCore

enum AcidOrBaseType: CaseIterable {
    case strongAcid, strongBase, weakAcid, weakBase

    var isAcid: Bool {
        switch self {
        case .strongAcid, .weakAcid: return true
        default: return false
        }
    }

    var isStrong: Bool {
        switch self {
        case .strongAcid, .strongBase: return true
        default: return false
        }
    }
}

typealias AcidOrBaseMap<Value> = EnumMap<AcidOrBaseType, Value>
