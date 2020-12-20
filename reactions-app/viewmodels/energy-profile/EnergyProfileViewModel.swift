//
// Reactions App
//
  

import SwiftUI

class EnergyProfileViewModel: ObservableObject {

    let persistence: ReactionInputPersistence
    init(persistence: ReactionInputPersistence) {
        self.persistence = persistence
    }

    var interactionEnabled: Bool = true
    @Published var reactionState = EnergyReactionState.pending
    @Published var statement = [SpeechBubbleLine]()
    @Published var temp2: CGFloat?
    @Published var peakHeightFactor: CGFloat = 1
    @Published var concentrationC: CGFloat = 0
    @Published var selectedReaction = ReactionOrder.Zero

    @Published var emitCatalyst = false
    @Published var catalystIsShaking = false
    @Published var canSelectCatalyst = false
    @Published var catalystsAreDisabled = false

    @Published var catalystState = CatalystState.disabled

    @Published var highlightedElements = [EnergyProfileScreenElement]()
    @Published var canSetReaction = true
    @Published var canSetTemp = false

    var catalystToSelect: Catalyst?

    var navigation: NavigationViewModel<EnergyProfileState>?

    var activationEnergy: CGFloat {
        let reduction = catalystState.selected?.energyReduction ?? 0
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

    func saveCatalyst() {
        if let catalyst = catalystState.selected {
            persistence.setUsed(catalyst: catalyst)
        }
    }

    var availableCatalysts: [Catalyst] {
        let notUsed = Catalyst.allCases.filter { !persistence.hasUsed(catalyst: $0) }
        if (notUsed.isEmpty) {
            return Catalyst.allCases
        }
        return notUsed
    }

    func back() {
        navigation?.back()
    }

    let temp1: CGFloat = EnergyBeakerSettings.minTemp

    var k1: CGFloat {
        getK(temp: temp1)
    }

    var k2: CGFloat? {
        temp2.map { getK(temp: $0) }
    }

    var rateEquation: Equation? {
        if catalystState.selected != nil {
            return LinearEquation(m: slope, x1: 1 / temp1, y1: log(k1))
        }
        return nil
    }

    var slope: CGFloat {
        -activationEnergy / .gasConstant
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
        if (availableCatalysts.contains(catalyst)) {
            catalystToSelect = catalyst
            navigation?.next()
        } else {
            statement = EnergyProfileStatements.chooseADifferentCatalyst
        }
    }

    func doSetCatalystInProgress(catalyst: Catalyst) {
        let duration = 0.75
        withAnimation(.easeOut(duration: duration)) {
            catalystState = .pending(catalyst: catalyst)
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
        next()
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

    func setSelectedCatalystState(catalyst: Catalyst) {
        let maxEnergy = selectedReaction.activationEnergy
        let minEnergy = 0.9 * (selectedReaction.activationEnergy - Catalyst.C.energyReduction)
        let resultingEnergy = selectedReaction.activationEnergy - catalyst.energyReduction
        let energyFactor = (resultingEnergy - minEnergy) / (maxEnergy - minEnergy)
        withAnimation(.easeOut(duration: 0.8)) {
            self.catalystState = .selected(catalyst: catalyst)
            self.peakHeightFactor = energyFactor
        }
    }

    func setConcentrationC(concentration: CGFloat) {
        self.concentrationC = concentration
        if (concentration == 1) {
            next()
        } else if (concentration >= 0.25) {
            statement = EnergyProfileStatements.reactionInProgress
            highlightedElements = []
        }
    }

    private func getK(temp: CGFloat) -> CGFloat {
        selectedReaction.preExponentFactor * pow(CGFloat(Darwin.M_E), (-1 * activationEnergy) / (temp * .gasConstant))
    }

    func runCatalystShakingAnimation() {
        let animation = Animation.interpolatingSpring(
            stiffness: 100,
            damping: 1.8
        )
        withAnimation(animation) {
            catalystIsShaking = true
        }
    }

    func color(for element: EnergyProfileScreenElement?) -> Color {
        if (highlight(element: element)) {
            return .white
        }
        return Styling.inactiveScreenElement
    }

    func highlight(element: EnergyProfileScreenElement?) -> Bool {
        if (highlightedElements.isEmpty) {
            return true
        }
        if let element = element, highlightedElements.contains(element) {
            return true
        }
        return false
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

extension CatalystState {
    var pending: Catalyst? {
        switch (self) {
        case let .pending(catalyst): return catalyst
        default: return nil
        }
    }

    var selected: Catalyst? {
        switch (self) {
        case let .selected(catalyst): return catalyst
        default: return nil
        }
    }
}
