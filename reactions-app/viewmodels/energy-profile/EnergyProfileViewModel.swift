//
// Reactions App
//
  

import SwiftUI

class EnergyProfileViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = EnergyProfileStatements.intro
    @Published var activationEnergy: CGFloat = EnergyProfileSettings.initialEa
    @Published var temp2: CGFloat?
    @Published var peakHeightFactor: CGFloat = 1
    @Published var concentrationC: CGFloat = 0
    @Published var allowReactionsToC = false

    @Published var selectedCatalyst: Catalyst?
    @Published var catalystInProgress: Catalyst?
    @Published var emitCatalyst = false

    private var dispatchId = UUID()

    var goToPreviousScreen: (() -> Void)?

    func next() {

    }

    // TODO - just make this reset the state
    func back() {
        if (catalystInProgress == nil) {
            if let goToPrevious = goToPreviousScreen {
                goToPrevious()
            }
        } else {
            dispatchId = UUID()
            catalystInProgress = nil
            emitCatalyst = false
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

    func setCatalystInProgress(catalyst: Catalyst) -> Void {
        catalystInProgress = catalyst
    }

    func selectCatalyst(catalyst: Catalyst) -> Void {
        emitCatalyst = true
        let id = UUID()
        dispatchId = id
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            guard self.dispatchId == id else {
                return
            }
//            self.emitCatalyst = false
            self.activationEnergy -= catalyst.energyReduction
            let minEnergy = EnergyProfileSettings.initialEa - Catalyst.C.energyReduction
            let energyFactor = (self.activationEnergy - minEnergy) / (EnergyProfileSettings.initialEa - minEnergy)
            self.temp2 = self.temp1
            self.allowReactionsToC = true
            self.statement = EnergyProfileStatements.setT2
            self.animateStateChange {
                self.selectedCatalyst = catalyst
                self.peakHeightFactor = energyFactor
            }
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
