//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroBeaker: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        ZStack(alignment: .bottom) {
            beaker
            containers
        }
        .frame(height: layout.common.height)
    }

    private var containers: some View {
        IntroBeakerContainers(
            model: model,
            layout: layout
        )
    }

    private var beaker: some View {
        VStack {
            Spacer()
            AdjustableFluidBeaker(
                rows: $model.rows,
                molecules: model.components.coords.all,
                animatingMolecules: [],
                currentTime: 0,
                settings: AdjustableFluidBeakerSettings(
                    minRows: AcidAppSettings.minBeakerRows,
                    maxRows: AcidAppSettings.maxBeakerRows,
                    beakerWidth: layout.common.beakerWidth,
                    beakerHeight: layout.common.beakerHeight,
                    sliderSettings: layout.common.sliderSettings,
                    sliderHeight: layout.common.sliderHeight
                ),
                canSetLevel: true,
                beakerColorMultiply: .white,
                sliderColorMultiply: .white,
                beakerModifier: AddMoleculesAccessibilityModifier()
            )
        }
        .padding(.bottom, layout.common.beakerBottomPadding)
    }
}

private struct IntroBeakerContainers: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    @GestureState private var pHMeterOffset = CGSize.zero

    var body: some View {
        ZStack {
            phMeter
            container(0)
            container(1)
            container(2)
            container(3)
        }
        .frame(width: totalBeakerWidth)
    }

    private var phMeter: some View {
        PHMeter(
            content: pHMeterIntersectingWater ? "pH: 12" : "",
            fontSize: common.phMeterFontSize
        )
        .frame(size: common.phMeterSize)
        .position(x: phMeterX, y: layout.containerRowYPos)
        .offset(pHMeterOffset)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .updating($pHMeterOffset) { gesture, offset, _ in
                    offset = gesture.translation
                }
        )
        .animation(.easeOut(duration: 0.25))
    }

    private func container(_ index: Int) -> some View {
        ShakingContainerView(
            model: model.addMoleculesModel,
            position: model.addMoleculesModel.motion.position,
            onTap: { },
            initialLocation: CGPoint(
                x: containerX(index),
                y: layout.containerRowYPos
            ),
            containerWidth: common.containerSize.width,
            containerSettings: ParticleContainerSettings(
                labelColor: .red,
                label: "A",
                labelFontColor: .white,
                strokeLineWidth: 0.4
            ),
            moleculeSize: 10,
            moleculeColor: .red,
            rotation: .zero,
            halfXRange: 10,
            halfYRange: 10,
            isSimulator: false
        )
        .font(.system(size: common.containerFontSize))
        .minimumScaleFactor(0.7)
        .frame(
            width: common.beakerSettings.innerBeakerWidth
        )
        .mask(
            VStack(spacing: 0) {
                Rectangle()
                    .frame(
                        width: common.beakerWidth + (2 * common.containerSize.height),
                        height: topOfWater
                    )
                Spacer()
            }
        )
    }

    private var phMeterX: CGFloat {
        let leadingSpacing = common.beakerToolsLeadingPadding
        let phWidth = common.phMeterSize.width
        return leadingSpacing + (phWidth / 2)
    }

    private func containerX(_ index: Int) -> CGFloat {
        let spacing = common.beakerToolsSpacing
        let containerWidth = common.containerSize.width
        let endOfPh = phMeterX + (common.phMeterSize.width / 2)
        let containerStartX = (totalBeakerWidth - moleculesAreaWidth) / 2

        // The ph scale uses the entire beaker width, whereas the containers
        // may only use the inner beaker width, so we must shift the x position
        // of the ph scale into the container frame of reference
        let endOfPhFromContainerStart = endOfPh - containerStartX

        let firstContainerX = endOfPhFromContainerStart + spacing + (containerWidth / 2)

        return firstContainerX + (CGFloat(index) * (spacing + containerWidth))
    }

    private var common: AcidBasesScreenLayout {
        layout.common
    }

    private var moleculesAreaWidth: CGFloat {
        common.beakerSettings.innerBeakerWidth
    }

    private var totalBeakerWidth: CGFloat {
        common.beakerWidth + common.sliderSettings.handleWidth
    }

    private var topOfWater: CGFloat {
        common.topOfWaterPosition(rows: model.rows)
    }

    private var pHMeterIntersectingWater: Bool {
        let waterHeight = common.waterHeight(rows: model.rows)
        let centerWaterX = common.sliderSettings.handleWidth + (common.beakerWidth / 2)
        let centerWaterY = common.height - (waterHeight / 2)

        let pHCenterX = phMeterX + pHMeterOffset.width
        let phCenterY = layout.containerRowYPos + pHMeterOffset.height

        return PHMeter.tipOverlapsArea(
            meterSize: common.phMeterSize,
            areaSize: CGSize(
                width: common.beakerSettings.innerBeakerWidth,
                height: waterHeight
            ),
            meterCenterFromAreaCenter: CGSize(
                width: pHCenterX - centerWaterX,
                height: phCenterY - centerWaterY
            )
        )
    }
}

struct AddMoleculesAccessibilityModifier: ViewModifier {
    // TODO
    func body(content: Content) -> some View {
        content
    }
}

struct IntroBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroBeaker(
                model: IntroScreenViewModel(),
                layout: IntroScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            )
        }
        .previewLayout(.iPhoneSELandscape)
        .padding()
    }
}
