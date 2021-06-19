//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroBeaker: View {

    @ObservedObject var model: IntroScreenViewModel
    @ObservedObject var components: IntroScreenComponents
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
            components: components,
            shakeModel: model.addMoleculesModel,
            layout: layout
        )
    }

    private var beaker: some View {
        VStack {
            Spacer()
            AdjustableFluidBeaker(
                rows: $model.rows,
                molecules: components.coords.all,
                animatingMolecules: [],
                currentTime: 0,
                settings: layout.common.adjustableBeakerSettings,
                canSetLevel: model.inputState == .setWaterLevel,
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
    @ObservedObject var components: IntroScreenComponents
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<AcidOrBaseType>
    let layout: IntroScreenLayout

    @GestureState private var pHMeterOffset = CGSize.zero

    var body: some View {
        ZStack {
            phMeter
            container(.strongAcid, 0)
            container(.strongBase, 1)
            container(.weakAcid, 2)
            container(.weakBase, 3)
        }
        .frame(width: totalBeakerWidth)
    }

    private var phMeter: some View {
        DraggablePhMeter(
            labelWhenIntersectingWater: phString,
            layout: layout.common,
            initialPosition: CGPoint(x: phMeterX, y: layout.containerRowYPos),
            rows: model.rows
        )
    }

    private func container(
        _ type: AcidOrBaseType,
        _ index: Int
    ) -> some View {
        let substance = model.selectedSubstances.value(for: type)
        return AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            onTap: { didTapContainer(type, index) },
            initialLocation: containerLocation(type, index),
            type: type,
            label: substance?.symbol ?? "",
            color: substance?.color ?? RGB.placeholderContainer.color,
            rows: model.rows,
            disabled: model.inputState != .addSubstance(type: type)
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
        let firstContainerX = endOfPh + spacing + (containerWidth / 2)

        return firstContainerX + (CGFloat(index) * (spacing + containerWidth))
    }

    private var common: AcidBasesScreenLayout {
        layout.common
    }

    private var totalBeakerWidth: CGFloat {
        common.beakerWidth + common.sliderSettings.handleWidth
    }

    private var phString: TextLine {
        let ph = components.concentration(ofIon: .hydrogen).p
        return "pH: \(ph.rounded(decimals: 1))"
    }

    private func containerLocation(
        _ element: AcidOrBaseType,
        _ index: Int
    ) -> CGPoint {
        if shakeModel.activeMolecule == element {
            return CGPoint(
                x: centerWaterX,
                y: layout.activeContainerYPos
            )
        }
        return CGPoint(
            x: containerX(index),
            y: layout.containerRowYPos
        )
    }

    private var centerWaterX: CGFloat {
         common.sliderSettings.handleWidth + (common.beakerWidth / 2)
    }
}

extension IntroBeakerContainers {
    private func didTapContainer(
        _ element: AcidOrBaseType,
        _ index: Int
    ) {
        guard shakeModel.activeMolecule != element else {
            shakeModel.model(for: element).manualAdd(amount: 5)
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            shakeModel.activeMolecule = element
        }
        shakeModel.start(
            for: element,
            at: containerLocation(element, index),
            bottomY: layout.common
                .topOfWaterPosition(rows: model.rows),
            halfXRange: common.containerShakeHalfXRange,
            halfYRange: common.containerShakeHalfYRange
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
                components: IntroScreenViewModel().components,
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
