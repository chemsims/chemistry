//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubleBeakerView: View {

    let model: SolubilityViewModel
    let shakeModel: SoluteBeakerShakingViewModel
    let settings: SolubilityScreenLayoutSettings

    var body: some View {
        GeometryReader { geo in
            SolubleBeakerViewWithGeometry(
                model: model,
                shakeModel: shakeModel,
                position: shakeModel.shake.position,
                settings: settings,
                geometry: geo
            )
            .frame(width: settings.soluble.beakerWidth)
        }
    }
}

private struct SolubleBeakerViewWithGeometry: View {

    @ObservedObject var model: SolubilityViewModel
    @ObservedObject var shakeModel: SoluteBeakerShakingViewModel
    @ObservedObject var position: CoreMotionPositionViewModel
    let settings: SolubilityScreenLayoutSettings
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
                container(solute: .primary, index: 0)
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

                container(solute: .commonIon, index: 1)
                container(solute: .acid, index: 2)
            }
            Spacer()
        }
        .frame(width: settings.soluble.beaker.beaker.innerBeakerWidth)
    }

    private var beaker: some View {
        HStack(alignment: .bottom, spacing: 0) {
            slider

            FillableBeaker(
                waterColor: model.waterColor,
                waterHeight: waterHeight,
                highlightBeaker: true,
                settings: settings.soluble.beaker
            ) {
                scene
            }
        }
    }

    private var slider: some View {
        CustomSlider(
            value: $model.waterHeightFactor,
            axis: sliderAxis,
            orientation: .portrait,
            includeFill: true,
            settings: settings.common.sliderSettings,
            disabled: false,
            useHaptics: true
        )
        .frame(
            width: settings.common.sliderSettings.handleWidth,
            height: settings.soluble.sliderHeight
        )
        .padding(.bottom, settings.soluble.sliderBottomPadding)
    }

    private var scene: some View {
        SolubleBeakerSceneRepresentable(
            size: CGSize(
                width: settings.soluble.beaker.beaker.innerBeakerWidth,
                height: geometry.size.height
            ),
            particlePosition: skParticlePosition,
            soluteWidth: settings.soluble.soluteWidth,
            waterHeight: waterHeight,
            canEmit: model.canEmit,
            onEmit: model.onParticleEmit,
            onDissolve: model.onDissolve,
            shouldAddParticle: $shakeModel.shouldAddParticle
        ).frame(
            width: settings.soluble.beaker.beaker.innerBeakerWidth,
            height: geometry.size.height
        )
    }

    private func container(solute: SoluteType, index: Int) -> some View {
        let isActive = model.activeSolute == solute
        return Image(solute.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: settings.soluble.containerWidth)
            .rotationEffect(isActive ? .degrees(135) : .zero)
            .position(
                isActive ? activeContainerLocation : standardContainerLocation(index: index)
            )
            .scaleEffect(isActive ? 1.2 : 1)
            .zIndex(isActive ? 1 : 0)
    }

    private func standardContainerLocation(index: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(index + 1) * settings.soluble.beaker.beaker.innerBeakerWidth / 4,
            y: settings.soluble.containerWidth * 1.5
        )
    }

    private var activeContainerLocation: CGPoint {
        let initX = settings.soluble.beaker.beaker.innerBeakerWidth / 2
        let initY: CGFloat = settings.soluble.containerWidth * 3.5
        return CGPoint(x: initX, y: initY)
            .offset(
                dx: position.xOffset * settings.soluble.beaker.beaker.innerBeakerWidth / 2,
                dy: position.yOffset * settings.soluble.containerWidth
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

    private var waterHeight: CGFloat {
        settings.waterHeightAxis.getPosition(at: model.waterHeightFactor)
    }

    private var sliderAxis: AxisPositionCalculations<CGFloat> {
        func position(_ waterHeight: CGFloat) -> CGFloat {
            settings.soluble.beaker.beakerHeight - waterHeight - settings.soluble.sliderBottomPadding
        }
        return AxisPositionCalculations(
            minValuePosition: position(settings.waterHeightAxis.minValuePosition),
            maxValuePosition: position(settings.waterHeightAxis.maxValuePosition),
            minValue: settings.waterHeightAxis.minValue,
            maxValue: settings.waterHeightAxis.maxValue
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

    var beaker: FillableBeakerSettings {
        FillableBeakerSettings(beakerWidth: beakerWidth)
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

    var sliderHeight: CGFloat {
        0.9 * beaker.beakerHeight
    }

    var sliderBottomPadding: CGFloat {
        (beaker.beakerHeight - sliderHeight) / 2
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
        GeometryReader { geo in
            SolubleBeakerView(
                model: SolubilityViewModel(),
                shakeModel: SoluteBeakerShakingViewModel(),
                settings: SolubilityScreenLayoutSettings(geometry: geo)
            )
        }.previewLayout(.iPhone8Landscape)
    }
}
