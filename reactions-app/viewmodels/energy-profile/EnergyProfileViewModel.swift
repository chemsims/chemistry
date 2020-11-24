//
// Reactions App
//
  

import SwiftUI

class EnergyProfileViewModel: ObservableObject {

    @Published var selectedCatalyst: Catalyst?

    let preExponentFactor: CGFloat = 20
    @Published var activationEnergy: CGFloat = 10000
    let temp1: CGFloat = 400

    var k1: CGFloat {
        getK(temp: temp1)
    }

    func selectCatalyst(catalyst: Catalyst) -> Void {
        selectedCatalyst = catalyst
        activationEnergy -= catalyst.energyReduction
    }

    @Published var temp2: CGFloat?

    var k2: CGFloat? {
        temp2.map { getK(temp: $0) }
    }

    private func getK(temp: CGFloat) -> CGFloat {
        preExponentFactor * pow(CGFloat(Darwin.M_E), (-1 * activationEnergy) / (temp * .gasConstant))
    }
}

extension Catalyst {
    var energyReduction: CGFloat {
        switch (self) {
        case .A: return 3000
        case .B: return 4000
        case .C: return 6000
        }
    }
}


extension CGFloat {
    static let gasConstant: CGFloat = 8.314
}
