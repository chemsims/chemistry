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

    var shouldDissolveNodes: Bool {
        inputState != .addSaturatedSolute
    }

    var componentWrapper: SolubilityComponentsWrapper

    init() {
        let firstTiming = SolubleReactionSettings.firstReactionTiming
        self.timing = firstTiming
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.componentWrapper = SolubilityComponentsWrapper(
            equilibriumConstant: 0.1,
            startTime: firstTiming.start,
            equilibriumTime: firstTiming.equilibrium
        )
        self.navigation = SolubilityNavigationModel.model(model: self)
    }

    var timing: ReactionTiming {
        didSet {
            self.componentWrapper.startTime = timing.start
            self.componentWrapper.equilibriumTime = timing.equilibrium
        }
    }

    var components: SolubilityComponents {
        componentWrapper.components
    }

    let shakingModel: SoluteBeakerShakingViewModel

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func onParticleEmit() {
        soluteEmitted += 1
    }

    func onParticleWaterEntry() {
        if inputState == .addSaturatedSolute {
            withAnimation(.linear(duration: Double(saturatedDt))) {
                currentTime += saturatedDt
            }
        }
    }

    func onDissolve() {
        guard inputState.addingSolute(type: .primary) else {
            return
        }
        soluteDissolved += 1
        withAnimation(.linear(duration: Double(dt))) {
            currentTime += dt
        }
        if soluteDissolved == soluteToAddForSaturation {
            navigation?.next()
            shakingModel.shouldAddParticle = false
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
        switch inputState {
        case .addSolute:
            return soluteEmitted < soluteToAddForSaturation
        case .addSaturatedSolute:
            return soluteEmitted < soluteToAddForSaturation + saturatedSoluteToAdd
        default:
            return false
        }
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

    private var soluteToAddForSaturation: Int {
        let equation = LinearEquation(x1: 0, y1: 10, x2: 1, y2: 20)
        return equation.getY(at: waterHeightFactor).roundedInt()
    }

    private var dt: CGFloat {
        components.equilibriumTime / CGFloat(soluteToAddForSaturation)
    }

    private var saturatedDt: CGFloat {
        (timing.end - timing.equilibrium) / CGFloat(saturatedSoluteToAdd)
    }
}

enum SolubilityInputState: Equatable {
    case none, addSaturatedSolute
    case addSolute(type: SoluteType)

    func addingSolute(type: SoluteType) -> Bool {
        self == .addSolute(type: type) || (type == .primary && self == .addSaturatedSolute)
    }
}

extension RGB {
    static let saturatedLiquid = RGB(r: 230, g: 203, b: 140)
}
