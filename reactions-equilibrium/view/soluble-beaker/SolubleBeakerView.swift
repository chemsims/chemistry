//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubleBeakerView: View {

    let waterColor: Color
    let model: SoluteBeakerShakingViewModel
    let settings: SolubleBeakerSettings

    var body: some View {
        GeometryReader { geo in
            SolubleBeakerViewWithGeometry(
                waterColor: waterColor,
                shakeModel: model,
                position: model.shake.position,
                settings: settings,
                geometry: geo
            )
            .frame(width: settings.beakerWidth)
        }
        .onAppear {
            model.shake.position.start(
                halfXRange: settings.beaker.beaker.innerBeakerWidth / 2,
                halfYRange: settings.containerYRange / 2
            )
        }
    }
}

private struct SolubleBeakerViewWithGeometry: View {

    let waterColor: Color
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
        VStack(spacing: 0) {
            ZStack {
                container(name: "soluteAB")
                    .position(activeContainerLocation)
            }
            Spacer()
        }
        .frame(width: settings.beaker.beaker.innerBeakerWidth)
    }

    private var beaker: some View {
        FillableBeaker(
            waterColor: waterColor,
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

    private var activeContainerLocation: CGPoint {
        let initX = settings.beaker.beaker.innerBeakerWidth / 3
        let initY: CGFloat = settings.containerWidth * 3
        return CGPoint(x: initX, y: initY)
            .offset(dx: position.xOffset, dy: position.yOffset)
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
        0.15 * beakerWidth
    }

    var containerYRange: CGFloat {
        2 * containerWidth
    }

    var soluteWidth: CGFloat {
        0.8 * containerWidth
    }
}

class SoluteBeakerShakingViewModel: NSObject, CoreMotionShakingDelegate, ObservableObject {

    @Published var shouldAddParticle: Bool = true

    let shake: CoreMotionShakingViewModel

    override init() {
        self.shake = CoreMotionShakingViewModel(settings: Self.shakingSettings)
        super.init()
        self.shake.delegate = self
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
            waterColor: Styling.beakerLiquid,
            model: SoluteBeakerShakingViewModel(),
            settings: SolubleBeakerSettings(
                beakerWidth: 200,
                waterHeight: 100
            )
        )
        .frame(width: 200, height: 500)
    }
}
