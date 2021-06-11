//
// Reactions App
//

import Foundation
import ReactionsCore
@testable import acids_bases

extension AcidOrBase {
    static func strongAcid() -> AcidOrBase {
        strongAcid(secondaryIon: .A, color: .blue, kA: 0)
    }

    static func strongBase() -> AcidOrBase {
        strongBase(secondaryIon: .A, color: .red, kB: 0)
    }

    static func weakAcid(substanceAddedPerIon: Int) -> AcidOrBase {
        weakAcid(substanceAddedPerIon: NonZeroPositiveInt(substanceAddedPerIon)!)
    }

    static func weakAcid(substanceAddedPerIon: NonZeroPositiveInt) -> AcidOrBase {
        weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: substanceAddedPerIon,
            color: .blue,
            kA: 1
        )
    }

    static func weakBase(substanceAddedPerIon: Int) -> AcidOrBase {
        weakBase(substanceAddedPerIon: NonZeroPositiveInt(substanceAddedPerIon)!)
    }
    static func weakBase(substanceAddedPerIon: NonZeroPositiveInt) -> AcidOrBase {
        weakBase(
            secondaryIon: .A,
            substanceAddedPerIon: substanceAddedPerIon,
            color: .red,
            kB: 1
        )
    }
}

