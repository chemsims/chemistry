//
// Reactions App
//

import Foundation
import ReactionsCore
@testable import AcidsBases

extension AcidOrBase {
    static func strongAcid() -> AcidOrBase {
        strongAcid(secondaryIon: .A, color: .black, kA: 0)
    }

    static func strongBase() -> AcidOrBase {
        strongBase(secondaryIon: .A, color: .black, kB: 0)
    }

    static func weakAcid(substanceAddedPerIon: Int) -> AcidOrBase {
        weakAcid(substanceAddedPerIon: NonZeroPositiveInt(substanceAddedPerIon)!)
    }

    static func weakAcid(substanceAddedPerIon: NonZeroPositiveInt) -> AcidOrBase {
        weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: substanceAddedPerIon,
            color: .black,
            kA: 1e-5
        )
    }

    static func weakBase(substanceAddedPerIon: Int) -> AcidOrBase {
        weakBase(substanceAddedPerIon: NonZeroPositiveInt(substanceAddedPerIon)!)
    }
    static func weakBase(substanceAddedPerIon: NonZeroPositiveInt) -> AcidOrBase {
        weakBase(
            secondaryIon: .A,
            substanceAddedPerIon: substanceAddedPerIon,
            color: .black,
            kB: 1
        )
    }
}

