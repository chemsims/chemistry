//
// Reactions App
//

import SwiftUI
import ReactionsCore


enum SoluteType {
    case primary, commonIon, acid

    var image: String {
        switch self {
        case .primary: return "soluteAB"
        case .commonIon: return "soluteCB"
        case .acid: return "acidH"
        }
    }
}

class SolubilityViewModel: ObservableObject {

    @Published var statement = [TextLine]()
    private(set) var navigation: NavigationModel<SolubilityScreenState>?

    @Published var waterHeightFactor: CGFloat = 0.5
    @Published var inputState = SolubilityInputState.none
    @Published var activeSolute: SoluteType?

    @Published var currentTime: CGFloat = 0
    
    @Published var shouldRemoveSolute = false
    @Published var shouldAddRemovedSolute = false

    @Published var beakerSoluteState = BeakerSoluteState.addingSolute(type: .primary, clearPrevious: false)

    var soluteCounts: SoluteContainer
    @Published var components: SolubilityComponents

    init() {
        let firstTiming = SolubleReactionSettings.firstReactionTiming
        self.timing = firstTiming
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.soluteCounts = SoluteContainer(maxAllowed: 0)
        self.components = SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues.constant(0),
            startTime: firstTiming.start,
            equilibriumTime: firstTiming.equilibrium
        )
        self.navigation = SolubilityNavigationModel.model(model: self)
        self.soluteCounts.maxAllowed = self.soluteToAddForSaturation
    }

    var timing: ReactionTiming {
        didSet {
            setComponents()
        }
    }

    let shakingModel: SoluteBeakerShakingViewModel

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func onParticleEmit(soluteType: SoluteType) {
        soluteCounts.didEmit()
    }

    func onParticleWaterEntry(soluteType: SoluteType) {
        if inputState == .addSaturatedSolute {
            withAnimation(.linear(duration: Double(saturatedDt))) {
                currentTime += saturatedDt
            }
        }
    }

    func onDissolve(soluteType: SoluteType) {
        guard inputState == .addSolute(type: soluteType) else {
            return
        }

        soluteCounts.didDissolve()
        switch soluteType {
        case .primary: primarySoluteDissolved()
        case .commonIon: commonIonSoluteDissolved()
        case .acid: break
        }
    }

    private func primarySoluteDissolved() {
        let newTime = soluteCounts.dissolvedFraction * (timing.equilibrium - timing.start)
        let dt = newTime - currentTime

        withAnimation(.linear(duration: Double(dt))) {
            currentTime = newTime
        }
        if !soluteCounts.canDissolve {
            navigation?.next()
            shakingModel.shouldAddParticle = false
        }
    }

    private func commonIonSoluteDissolved() {
        b0 = SolubleReactionSettings.maxInitialBConcentration * soluteCounts.dissolvedFraction
    }

    var b0: CGFloat = 0 {
        didSet {
            setComponents()
        }
    }

    func startShaking() {
        shakingModel.shake.position.start()
    }

    func stopShaking() {
        shakingModel.shake.position.stop()
    }

    func resetParticles() {
        soluteEmitted = 0
        soluteDissolved = 0
    }

    var canEmit: Bool {
        inputState.isAddingSolute && soluteCounts.canEmit
//        switch inputState {
//        case .addSolute:
//            return soluteEmitted < soluteToAddForSaturation
//        case .addSaturatedSolute:
//            return soluteEmitted < soluteToAddForSaturation + saturatedSoluteToAdd
//        default:
//            return false
//        }
    }

    var waterColor: Color {
        let initialRGB = RGB.beakerLiquid
        let finalRGB = RGB.saturatedLiquid
        let fraction = min(1, currentTime / components.equilibriumTime)
        return RGB.interpolate(initialRGB, finalRGB, fraction: Double(fraction)).color
    }

    private var soluteEmitted: Int = 0
    private var soluteDissolved: Int = 0
    private let saturatedSoluteToAdd: Int = 5

    var soluteToAddForSaturation: Int {
        let equation = LinearEquation(x1: 0, y1: 10, x2: 1, y2: 20)
        return equation.getY(at: waterHeightFactor).roundedInt()
    }

    private var dt: CGFloat {
        components.equilibriumTime / CGFloat(soluteToAddForSaturation)
    }

    private var saturatedDt: CGFloat {
        (timing.end - timing.equilibrium) / CGFloat(saturatedSoluteToAdd)
    }

    private func setComponents() {
        self.components = SolubilityComponents(
            equilibriumConstant: 0.1,
            initialConcentration: SoluteValues(productA: 0, productB: b0),
            startTime: timing.start,
            equilibriumTime: timing.equilibrium
        )
    }
}

class SoluteContainer {

    var maxAllowed: Int

    init(maxAllowed: Int, isSaturated: Bool = false) {
        self.maxAllowed = maxAllowed
        if isSaturated {
            emitted = maxAllowed
            dissolved = maxAllowed
        }
    }

    private var emitted: Int = 0
    private var dissolved: Int = 0

    func didEmit() {
        emitted += 1
    }

    func didDissolve() {
        dissolved += 1
    }

    func reset() {
        emitted = 0
        dissolved = 0
    }

    var canEmit: Bool {
        emitted < maxAllowed
    }

    var canDissolve: Bool {
        dissolved < maxAllowed
    }

    var dissolvedFraction: CGFloat {
        CGFloat(dissolved) / CGFloat(maxAllowed)
    }
}

enum SolubilityInputState: Equatable {
    case none, addSaturatedSolute
    case addSolute(type: SoluteType)

    var isAddingSolute: Bool {
        if case .addSolute = self {
            return true
        }
        return self == .addSaturatedSolute
    }

    func addingSolute(type: SoluteType) -> Bool {
        self == .addSolute(type: type) || (type == .primary && self == .addSaturatedSolute)
    }
}

extension RGB {
    static let saturatedLiquid = RGB(r: 230, g: 203, b: 140)
}
