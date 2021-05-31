//
// Reactions App
//

import ReactionsCore

enum AcidOrBaseType: CaseIterable {
    case strongAcid, strongBase, weakAcid, weakBase
}

typealias AcidOrBaseMap<Value> = EnumMap<AcidOrBaseType, Value>
