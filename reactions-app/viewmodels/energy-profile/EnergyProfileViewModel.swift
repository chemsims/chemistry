//
// Reactions App
//
  

import SwiftUI

class EnergyProfileViewModel: ObservableObject {

    @Published var selectedCatalyst: Catalyst?
    @Published var activationEnergy: CGFloat = EnergyProfileSettings.initialEa
    @Published var temp2: CGFloat?
    @Published var peakHeightFactor: CGFloat = 1
    @Published var concentrationC: CGFloat = 0

    let preExponentFactor: CGFloat = EnergyProfileSettings.preExponentFactor
    let temp1: CGFloat = EnergyProfileSettings.initialTemp

    var k1: CGFloat {
        getK(temp: temp1)
    }

    var k2: CGFloat? {
        temp2.map { getK(temp: $0) }
    }

    func selectCatalyst(catalyst: Catalyst) -> Void {
        selectedCatalyst = catalyst
        activationEnergy -= catalyst.energyReduction
        let minEnergy = EnergyProfileSettings.initialEa - Catalyst.C.energyReduction
        let energyFactor = (activationEnergy - minEnergy) / (EnergyProfileSettings.initialEa - minEnergy)
        temp2 = temp1
        withAnimation(.easeOut(duration: 0.8)) {
            peakHeightFactor = energyFactor
        }
    }

    func setConcentrationC(concentration: CGFloat) {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.concentrationC = concentration
        }
    }

    private func getK(temp: CGFloat) -> CGFloat {
        preExponentFactor * pow(CGFloat(Darwin.M_E), (-1 * activationEnergy) / (temp * .gasConstant))
    }
}

struct EnergyProfileSettings {
    static let initialEa: CGFloat = 10000
    static let preExponentFactor: CGFloat = 20
    static let initialTemp: CGFloat = 400
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
