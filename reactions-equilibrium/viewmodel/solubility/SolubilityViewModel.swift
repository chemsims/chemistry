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

    var componentWrapper: SolubilityComponentsWrapper

    init() {
        self.shakingModel = SoluteBeakerShakingViewModel()
        self.componentWrapper = SolubilityComponentsWrapper(
            equilibriumConstant: 0.1,
            startTime: SolubleReactionSettings.firstReactionTiming.start,
            equilibriumTime: SolubleReactionSettings.firstReactionTiming.equilibrium
        )
        self.navigation = SolubilityNavigationModel.model(model: self)
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

    func onDissolve() {
        withAnimation(.linear(duration: Double(dt))) {
            currentTime += dt
        }
    }

    func stopShaking() {
        shakingModel.shake.position.stop()
    }

    var canEmit: Bool {
        soluteEmitted < soluteToAddForSaturation
    }

    var waterColor: Color {
        let initialRGB = RGB.beakerLiquid
        let finalRGB = RGB.saturatedLiquid
        let fraction = min(1, currentTime / components.equilibriumTime)
        return RGB.interpolate(initialRGB, finalRGB, fraction: Double(fraction)).color
    }

    private var soluteEmitted: Int = 0

    var soluteToAddForSaturation: Int {
        let equation = LinearEquation(x1: 0, y1: 10, x2: 1, y2: 20)
        return equation.getY(at: waterHeightFactor).roundedInt()
    }

    var dt: CGFloat {
        components.equilibriumTime / CGFloat(soluteToAddForSaturation)
    }
}

enum SolubilityInputState {
    case none, addSolute
}

extension RGB {
    static let saturatedLiquid = RGB(r: 230, g: 203, b: 140)
}
