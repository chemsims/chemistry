//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubleBeakerView: View {

    let model: SolubilityViewModel
    let shakeModel: SoluteBeakerShakingViewModel
    let settings: SolubleBeakerSettings

    var body: some View {
        GeometryReader { geo in
            SolubleBeakerViewWithGeometry(
                model: model,
                shakeModel: shakeModel,
                position: shakeModel.shake.position,
                settings: settings,
                geometry: geo
            )
            .frame(width: settings.beakerWidth)
        }
    }
}

private struct SolubleBeakerViewWithGeometry: View {

    @ObservedObject var model: SolubilityViewModel
    @ObservedObject var shakeModel: SoluteBeakerShakingViewModel
    @ObservedObject var position: CoreMotionPositionViewModel
    let settings: SolubleBeakerSettings
    let geometry: GeometryProxy

    var body: some View {
        ZStack(alignment: .bottom) {
            beaker
            containers
        }
    }

    private var containers: some View {
        let isActive = model.activeSolute == SoluteType.primary
        return VStack(spacing: 0) {
            ZStack {
                container(name: "soluteAB")
                    .rotationEffect(isActive ? .degrees(135) : .zero)
                    .position(
                        isActive ? activeContainerLocation : standardContainerLocation
                    )
                    .scaleEffect(isActive ? 1.2 : 1)
                    .onTapGesture {
                        guard model.inputState == .addSolute else {
                            return
                        }
                        if isActive {
                            shakeModel.manualAdd()
                        } else {
                            withAnimation(.easeOut(duration: 0.5)) {
                                model.activeSolute = .primary
                            }
                            shakeModel.shake.position.start()
                        }
                    }
            }
            Spacer()
        }
        .frame(width: settings.beaker.beaker.innerBeakerWidth)
    }

    private var beaker: some View {
        FillableBeaker(
            waterColor: Styling.beakerLiquid,
            highlightBeaker: true,
            settings: settings.beaker
        ) {
            scene
        }
    }

    private var scene: some View {
        SolubleBeakerSceneRepresentable(
            size: CGSize(
                width: settings.beaker.beaker.innerBeakerWidth,
                height: geometry.size.height
            ),
            particlePosition: skParticlePosition,
            soluteWidth: settings.soluteWidth,
            waterHeight: settings.waterHeight,
            onDissolve: model.onDissolve,
            shouldAddParticle: $shakeModel.shouldAddParticle
        ).frame(
            width: settings.beaker.beaker.innerBeakerWidth,
            height: geometry.size.height
        )
    }

    private func container(name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: settings.containerWidth)
    }

    private var standardContainerLocation: CGPoint {
        CGPoint(
            x: settings.beaker.beaker.innerBeakerWidth / 3,
            y: settings.containerWidth * 1.5
        )
    }

    private var activeContainerLocation: CGPoint {
        let initX = settings.beaker.beaker.innerBeakerWidth / 2
        let initY: CGFloat = settings.containerWidth * 3.5
        return CGPoint(x: initX, y: initY)
            .offset(
                dx: position.xOffset * settings.beaker.beaker.innerBeakerWidth / 2,
                dy: position.yOffset * settings.containerWidth
            )
    }

    // Maps active container location into the SpriteKit frame of reference.
    // i.e., y = 0 at the bottom of the screen
    private var skParticlePosition: CGPoint {
        CGPoint(
            x: activeContainerLocation.x,
            y: geometry.size.height - activeContainerLocation.y
        )
    }
}

extension SolubleBeakerViewWithGeometry {
    private func waterColor(for countOfSolute: Int, maxCount: Int) -> Color {
        return Styling.beakerLiquid
    }
}

struct SolubleBeakerSettings {

    let beakerWidth: CGFloat
    let waterHeight: CGFloat

    var beaker: FillableBeakerSettings {
        FillableBeakerSettings(
            beakerWidth: beakerWidth,
            waterHeight: waterHeight
        )
    }

    var containerWidth: CGFloat {
        0.13 * beakerWidth
    }

    var containerYRange: CGFloat {
        2 * containerWidth
    }

    var soluteWidth: CGFloat {
        0.8 * containerWidth
    }
}

class SoluteBeakerShakingViewModel: NSObject, CoreMotionShakingDelegate, ObservableObject {

    @Published var shouldAddParticle: Bool = false

    let shake: CoreMotionShakingViewModel

    override init() {
        self.shake = CoreMotionShakingViewModel(settings: Self.shakingSettings)
        super.init()
        self.shake.delegate = self
    }

    func manualAdd() {
        self.shouldAddParticle = true
    }

    func didShake() {
        DispatchQueue.main.async { [weak self] in
            self?.shouldAddParticle = true
        }
    }
}

private extension SoluteBeakerShakingViewModel {
    static let shakingSettings = CoreMotionShakingBehavior(
        minTimeInterval: 0.5,
        maxTimeInterval: 1,
        minRotationThreshold: 2,
        maxRotationRate: 10
    )
}

struct SolubleBeakerView_Previews: PreviewProvider {
    static var previews: some View {
        SolubleBeakerView(
            model: SolubilityViewModel(),
            shakeModel: SoluteBeakerShakingViewModel(),
            settings: SolubleBeakerSettings(
                beakerWidth: 200,
                waterHeight: 100
            )
        )
        .frame(width: 200, height: 500)
    }
}
