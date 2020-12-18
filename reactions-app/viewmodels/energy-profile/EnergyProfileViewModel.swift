//
// Reactions App
//
  

import SwiftUI

class EnergyProfileViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = EnergyProfileStatements.intro
    @Published var temp2: CGFloat?
    @Published private(set) var peakHeightFactor: CGFloat = 1
    @Published var concentrationC: CGFloat = 0
    @Published private(set) var reactionHasStarted = false
    @Published var selectedReaction = ReactionOrder.Zero

    @Published var selectedCatalyst: Catalyst?
    @Published var catalystInProgress: Catalyst?
    @Published var emitCatalyst = false
    @Published var catalystIsShaking = false
    @Published var canSelectCatalyst = false
    @Published var reactionHasEnded = false

    var navigation: ReactionNavigationViewModel<EnergyProfileState>?


    var activationEnergy: CGFloat {
        let reduction = selectedCatalyst?.energyReduction ?? 0
        return selectedReaction.activationEnergy - reduction
    }

    var extraEnergyFactor: CGFloat {
        let temp2 = self.temp2 ?? temp1
        let minEnergy = selectedReaction.minEnergyFactor
        let maxEnergy = selectedReaction.maxEnergyFactor
        let minTemp = EnergyBeakerSettings.minTemp
        let maxTemp = EnergyBeakerSettings.maxTemp

        let tempFactor = (temp2 - minTemp)/(maxTemp - minTemp)
        return minEnergy + (tempFactor * (maxEnergy - minEnergy))
    }

    var initialHeightFactor: CGFloat {
        selectedReaction.eaHeightFactor
    }

    private var dispatchId = UUID()

    var prevScreen: (() -> Void)?
    var nextScreen: (() -> Void)?

    func next() {
        navigation?.next()
    }

    func endReaction() {
        goToEndState()
    }

    private func goToEndState() {
        if (catalystInProgress == nil) {
            catalystInProgress = .C
        }
        if (selectedCatalyst == nil) {
            doSelectCatalyst(catalyst: catalystInProgress ?? .C, withDelay: false)
        }
        reactionHasEnded = true
        concentrationC = 1
        statement = EnergyProfileStatements.finished
    }

    func back() {
        navigation?.back()
    }

    func resetState() {
        withAnimation(.easeOut(duration: 0.75)) {
            catalystIsShaking = false
            catalystInProgress = nil
        }
        reactionHasEnded = false
        canSelectCatalyst = false
        dispatchId = UUID()
        emitCatalyst = false
        selectedCatalyst = nil
        reactionHasStarted = false
        statement = EnergyProfileStatements.intro
        withAnimation(.easeOut(duration: 0.6)) {
            peakHeightFactor = 1
            temp2 = nil
            concentrationC = 0
        }
    }

    let temp1: CGFloat = EnergyBeakerSettings.minTemp

    var k1: CGFloat {
        getK(temp: temp1)
    }

    var k2: CGFloat? {
        temp2.map { getK(temp: $0) }
    }

    var rateEquation: Equation? {
        if selectedCatalyst != nil {
            let slope = -activationEnergy / .gasConstant
            return LinearEquation(m: slope, x1: 1 / temp1, y1: log(k1))
        }
        return nil
    }

    var tempHeightFactor: CGFloat {
        let min: CGFloat = -0.5
        let max: CGFloat = 1.1
        let minT: CGFloat = 400
        let maxT: CGFloat = 600
        let temp = temp2 ?? temp1
        let tFactor = (temp - minT) / (maxT - minT)
        return min + ((max - min) * tFactor)
    }
    
    var canReactToC: Bool {
        tempHeightFactor >= (peakHeightFactor * initialHeightFactor)
    }

    func setCatalystInProgress(catalyst: Catalyst) -> Void {
        let duration = 0.75
        withAnimation(.easeOut(duration: duration)) {
            catalystInProgress = catalyst
        }

        let id = UUID()
        dispatchId = id
        // Allow selecting catalyst a little before the animation ends
        let dispatchDelay = Int(duration * 750)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(dispatchDelay)) {
            guard self.dispatchId == id else {
                return
            }
            self.canSelectCatalyst = true
        }
    }

    func selectCatalyst(catalyst: Catalyst) -> Void {
        doSelectCatalyst(catalyst: catalyst, withDelay: true)
    }
    

    func doSelectCatalyst(
        catalyst: Catalyst,
        withDelay: Bool
    ) {
        emitCatalyst = true
        let id = UUID()
        dispatchId = id
        runCatalystShakingAnimation()
        if (withDelay) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
                guard self.dispatchId == id else {
                    return
                }
                setSelectedCatalystState(catalyst: catalyst)
            }
        } else {
            setSelectedCatalystState(catalyst: catalyst)
        }
    }

    private func setSelectedCatalystState(catalyst: Catalyst) {
        let maxEnergy = selectedReaction.activationEnergy
        let minEnergy = 0.9 * (selectedReaction.activationEnergy - Catalyst.C.energyReduction)
        let resultingEnergy = selectedReaction.activationEnergy - catalyst.energyReduction
        let energyFactor = (resultingEnergy - minEnergy) / (maxEnergy - minEnergy)
        self.temp2 = self.temp1
        self.reactionHasStarted = true
        self.statement = EnergyProfileStatements.setT2
        withAnimation(.easeOut(duration: 0.8)) {
            self.selectedCatalyst = catalyst
            self.peakHeightFactor = energyFactor
        }
    }

    func setConcentrationC(concentration: CGFloat) {
        self.concentrationC = concentration
        if (concentration > 0.4) {
            statement = EnergyProfileStatements.middle
        }
        if (concentration == 1) {
            next()
        }
    }

    private func getK(temp: CGFloat) -> CGFloat {
        selectedReaction.preExponentFactor * pow(CGFloat(Darwin.M_E), (-1 * activationEnergy) / (temp * .gasConstant))
    }

    private func runCatalystShakingAnimation() {
        let animation = Animation.interpolatingSpring(
            stiffness: 100,
            damping: 1.8
        )
        withAnimation(animation) {
            catalystIsShaking = true
        }
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

extension ReactionOrder {
    var preExponentFactor: CGFloat {
        switch (self) {
        case .Zero: return 20
        case .First: return 10
        case .Second: return 5
        }
    }

    var activationEnergy: CGFloat {
        switch (self) {
        case .Zero: return 12000
        case .First: return 10000
        case .Second: return 8000
        }
    }

    var minEnergyFactor: CGFloat {
        switch (self) {
        case .Zero: return 0
        case .First: return 0.1
        case .Second: return 0.2
        }
    }

    var maxEnergyFactor: CGFloat {
        switch(self) {
        case .Zero: return 0.4
        case .First: return 0.7
        case .Second: return 1
        }
    }

    var eaHeightFactor: CGFloat {
        switch (self) {
        case .Zero: return 1
        case .First: return 0.9
        case .Second: return 0.8
        }
    }
}

extension CGFloat {
    static let gasConstant: CGFloat = 8.314
}
