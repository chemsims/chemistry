//
// Reactions App
//
  

import SwiftUI

class EnergyProfileViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = EnergyProfileStatements.intro
    @Published var selectedCatalyst: Catalyst?
    @Published var activationEnergy: CGFloat = EnergyProfileSettings.initialEa
    @Published var temp2: CGFloat?
    @Published var peakHeightFactor: CGFloat = 1
    @Published var concentrationC: CGFloat = 0
    @Published var allowReactionsToC = false


    func next() {

    }

    func back() {
        if (selectedCatalyst != nil) {
            selectedCatalyst = nil
            activationEnergy = EnergyProfileSettings.initialEa
            allowReactionsToC = false
            statement = EnergyProfileStatements.intro
            withAnimation(.easeOut(duration: 0.6)) {
                peakHeightFactor = 1
                temp2 = nil
                concentrationC = 0
            }
        }
    }

    let temp1: CGFloat = EnergyProfileSettings.initialTemp

    var k1: CGFloat {
        getK(temp: temp1)
    }

    var k2: CGFloat? {
        temp2.map { getK(temp: $0) }
    }

    var rateEquation: ConcentrationEquation? {
        if selectedCatalyst != nil {
            let slope = -activationEnergy / .gasConstant
            return LinearConcentration(m: slope, t1: 1 / temp1, c1: log(k1))
        }
        return nil
    }

    func selectCatalyst(catalyst: Catalyst) -> Void {
        selectedCatalyst = catalyst
        activationEnergy -= catalyst.energyReduction
        let minEnergy = EnergyProfileSettings.initialEa - Catalyst.C.energyReduction
        let energyFactor = (activationEnergy - minEnergy) / (EnergyProfileSettings.initialEa - minEnergy)
        temp2 = temp1
        allowReactionsToC = true
        statement = EnergyProfileStatements.setT2
        animateStateChange {
            peakHeightFactor = energyFactor
        }
    }

    func setConcentrationC(concentration: CGFloat) {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.concentrationC = concentration
        }
        if (concentration > 0.4) {
            statement = EnergyProfileStatements.middle
        }
        if (concentration == 1) {
            statement = EnergyProfileStatements.finished
        }
    }

    private func animateStateChange(stateChange: () -> Void) {
        withAnimation(.easeOut(duration: 0.8)) {
            stateChange()
        }
    }

    private func getK(temp: CGFloat) -> CGFloat {
        EnergyProfileSettings.preExponentFactor * pow(CGFloat(Darwin.M_E), (-1 * activationEnergy) / (temp * .gasConstant))
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
