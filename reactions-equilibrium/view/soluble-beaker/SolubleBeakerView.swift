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
        .zIndex(10)
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
            shakeText
                .opacity(model.showShakeText ? 1 : 0)

            HStack(spacing: 0) {
                Spacer()
                    .frame(width: settings.common.sliderSettings.handleWidth)
                containers
            }
        }
    }

    private var shakeText: some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                ShakeText()
                Spacer()
                    .frame(height: 1.1 * settings.common.beakerHeight)
            }
        }
        .frame(width: settings.totalBeakerWidth)
        .font(.system(size: settings.common.shakeTextFontSize))
    }

    private var containers: some View {
        VStack(spacing: 0) {
            ZStack {
                container(solute: .primary, index: 0)
                container(solute: .commonIon, index: 1)
                container(solute: .acid, index: 2)

                // NB: There was a strange bug when conditionally including this view, which
                // causes it to not show, and container opacity to remain < 1, when navigating back
                // and forward quickly on the add solute state
                milligramsLabel
                    .opacity(showMilligramsLabel ? 1 : 0)
                        .zIndex(2)

            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(containerLabel))
            Spacer()
        }
        .frame(width: settings.soluble.beaker.beaker.innerBeakerWidth)
    }

    private var containerLabel: String {
        let salt = model.selectedReaction.products.salt
        let commonSalt = model.selectedReaction.products.commonSalt
        let acid = "H+"
        let all = StringUtil.combineStringsWithFinalAnd([salt, commonSalt, acid])
        return "Three containers for solutes \(all)"
    }

    private var showMilligramsLabel: Bool {
        func isAdding(_ solute: SoluteType) -> Bool {
            model.inputState == .addSolute(type: solute)
        }
        return isAdding(.primary) || isAdding(.commonIon)
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
            .colorMultiply(model.highlights.colorMultiply(for: nil))
        }
    }

    private var slider: some View {
        CustomSlider(
            value: $model.waterHeightFactor,
            axis: sliderAxis,
            orientation: .portrait,
            includeFill: true,
            settings: settings.common.sliderSettings,
            disabled: model.inputState != .setWaterLevel,
            useHaptics: true,
            formatAccessibilityValue: {
                LinearEquation(
                    x1: 0,
                    y1: settings.minWaterHeightFraction,
                    x2: 1,
                    y2: settings.maxWaterHeightFraction
                ).getY(at: $0).percentage
            }
        )
        .frame(
            width: settings.common.sliderSettings.handleWidth,
            height: settings.soluble.sliderHeight
        )
        .padding(.bottom, settings.soluble.sliderBottomPadding)
        .background(Color.white.padding(-3))
        .colorMultiply(model.highlights.colorMultiply(for: .waterSlider))
        .accessibility(label: Text("Slider to set height of water in beaker"))
    }

    private var scene: some View {
        ZStack {
            // Note - attaching the modifiers from this host view onto the
            // scene below results in a bug where the scene disappears as of iOS 14.5
            SolubleBeakerAccessibilityHostView(model: model)

            SolubleBeakerSceneRepresentable(
                size: CGSize(
                    width: settings.soluble.beaker.beaker.innerBeakerWidth,
                    height: geometry.size.height
                ),
                particlePosition: skParticlePosition,
                soluteWidth: settings.soluble.soluteWidth,
                waterHeight: waterHeight,
                model: model,
                shouldAddParticle: $shakeModel.shouldAddParticle,
                addManualParticle: $model.addVoiceOverParticle
            )
        }
        .frame(
            width: settings.soluble.beaker.beaker.innerBeakerWidth,
            height: geometry.size.height
        )
        .accessibilityElement(children: .combine)
    }

    private func container(solute: SoluteType, index: Int) -> some View {
        let isActive = model.activeSolute.value == solute

        return ParticleContainer(
            settings: ParticleContainerSettings(
                labelColor: solute.color(for: model.selectedReaction).color,
                label: labelName(for: solute),
                strokeLineWidth: 0.4
            )
        )
        .compositingGroup()
        .colorMultiply(isActive ? .white : Styling.inactiveContainerMultiply)
        .animation(nil)
        .shadow(radius: isActive ? 3 : 0)
        .foregroundColor(.white)
        .font(.system(size: settings.soluble.containerFontSize))
        .frame(width: settings.soluble.containerWidth)
        .rotationEffect(isActive ? .degrees(135) : .zero)
        .position(
            isActive ? activeContainerLocation : standardContainerLocation(index: index)
        )
        .scaleEffect(isActive ? 1.2 : 1)
        .zIndex(model.activeSolute.showSoluteOnTop(solute) ? 1 : 0)
        .onTapGesture {
            guard model.inputState.addingSolute(type: solute) else {
                return
            }
            if isActive {
                shakeModel.manualAdd()
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    model.activeSolute.setValue(solute)
                }
                model.startShaking()
            }
        }
    }

    private var milligramsLabel: some View {
        HStack(spacing: 2) {
            AnimatingNumber(
                x: model.milligramsSoluteAdded,
                equation: LinearEquation(m: 1, x1: 0, y1: 0),
                formatter: { mg in
                    "+\(mg.str(decimals: 0))"
                },
                alignment: .leading
            )
            .frame(
                width: 2.4 * settings.soluble.containerWidth,
                height: 1.2 * settings.soluble.containerWidth
            )
            Text("mg")
        }
        .font(.system(size: 0.75 * settings.soluble.containerWidth))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .foregroundColor(
            (model.activeSolute.value ?? .primary).color(for: model.selectedReaction).color
        )
        .background(
            RoundedRectangle(cornerRadius: 0.2 * settings.soluble.containerWidth)
                .foregroundColor(.white)
                .opacity(0.95)
        )
        .colorMultiply(model.highlights.colorMultiply(for: nil))
        .position(activeContainerLocation)
        .offset(x: 4 * settings.soluble.containerWidth)
    }

    private func labelName(for soluteType: SoluteType) -> String {
        switch soluteType {
        case .primary: return model.selectedReaction.products.salt
        case .commonIon: return model.selectedReaction.products.commonSalt
        case .acid: return "H+"
        }
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

private extension ValueWithPrevious where Value == SoluteType? {
    func showSoluteOnTop(_ solute: SoluteType) -> Bool {
        value == solute || (value == nil && oldValue == solute)
    }
}

private struct SolubleBeakerAccessibilityHostView: View {

    @ObservedObject var model: SolubilityViewModel

    var body: some View {
        Rectangle()
            .opacity(0)
            .accessibility(label: Text(label))
            .modifyIf(labelValue != nil) {
                $0.updatingAccessibilityValue(
                    x: model.currentTime,
                    format: getBeakerLabelValue
                )
            }
            .modifyIf(action != nil) {
                $0.accessibilityAction(named: Text(action!.0)) {
                    action!.1()
                }
            }
    }

    private var label: String {
        model.beakerLabel.label(model: model)
    }

    private var action: (String, () -> Void)? {
        model.beakerLabel.action(model: model)
    }

    private var labelValue: String? {
        model.beakerLabel.value(at: model.currentTime, model: model)
    }

    private func getBeakerLabelValue(at time: CGFloat) -> String {
        model.beakerLabel.value(at: time, model: model) ?? ""
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

    var containerFontSize: CGFloat {
        0.7 * containerWidth
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

    func start() {
        shouldAddParticle = false
        shake.position.start()
    }

    func stop() {
        shouldAddParticle  = false
        shake.position.stop()
    }

    func didShake() {
        DispatchQueue.main.async { [weak self] in
            self?.shouldAddParticle = true
        }
    }
}

private extension SoluteBeakerShakingViewModel {
    static let shakingSettings = CoreMotionShakingBehavior(
        minTimeInterval: 0.25,
        maxTimeInterval: 0.75,
        minRotationThreshold: 1,
        maxRotationRate: 15
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
        }
        .padding()
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
